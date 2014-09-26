//
//  Friends.swift
//  Juicy
//
//  Created by Brian Vallelunga on 9/25/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class Friends {
    
    // MARK: Class Structs
    struct Friend {
        var user: User!
        var range: NSRange!
    }
    
    struct Response {
        var content: [[String: AnyObject]]!
        var friends: [Friend]!
        var aboutUsers: [User]!
    }
    
    // MARK: Private Instance Variables
    var friends: [User] = []
    var contacts: [String] = []
    
    // MARK: Instance Variables
    func isFriend(range: NSRange, ranges: NSMutableArray, text: String, oldLength: Int) -> Bool {
        let letters = NSCharacterSet.letterCharacterSet()
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        
        if range.location != Foundation.NSNotFound {
            for tempRange in ranges {
                let newRange = tempRange as NSRange
                
                if range.location == newRange.location {
                    return false
                }
            }
            
            let length = range.location + range.length
            let unicodeScalars = text.unicodeScalars
            let lastChar = unicodeScalars[unicodeScalars.endIndex].value
            
            return !ranges.containsObject(range) &&
                (range.location == 0 || text[range.location - 1] == " ") &&
                (length == oldLength || (!letters.longCharacterIsMember(lastChar) && !digits.longCharacterIsMember(lastChar)))
        } else {
            return false
        }
    }
    
    func friendsInMessage(text: String) -> [Friend] {
        let lowerText = NSString(string: text.lowercaseString)
        var friends: [Friend] = []
        var ranges = NSMutableArray()
        
        // Search By Registered Users
        if !self.friends.isEmpty {
            for friend in self.friends {
                let range = lowerText.rangeOfString(friend.name.lowercaseString)
                
                if self.isFriend(range, ranges: ranges, text: text, oldLength: lowerText.length)  {
                    friends.append(Friend(user: friend, range: range))
                    ranges.addObject(range)
                }
            }
        }
        
        // Search By Contact List
        if !self.contacts.isEmpty {
            for contact in self.contacts {
                let range = lowerText.rangeOfString(contact.lowercaseString)
                
                if self.isFriend(range, ranges: ranges, text: text, oldLength: lowerText.length)  {
                    friends.append(Friend(user: nil, range: range))
                    ranges.addObject(range)
                }
            }
        }
        
        friends.sort({ $0.range.location < $1.range.location })
        return friends
    }
    
    func friendsMessage(text: NSString) -> Response {
        var content: [[String: AnyObject]] = []
        var aboutUsers: [User] = []
        var friends = self.friendsInMessage(text)
        
        if friends.isEmpty {
            content.append([
                "message": text,
                "color": false
            ])
        } else {
            for (index, friend) in enumerate(friends) {
                var endRange: NSRange;
                let range = friend.range
                let endLocation = range.location + range.length
                
                if friend.user != nil {
                    aboutUsers.append(friend.user)
                }
                
                if index == 0 && range.location != 0 {
                    content.append([
                        "message": text.substringWithRange(_NSRange(location: 0, length: range.location)),
                        "color": false
                    ])
                }
                
                content.append([
                    "message": text.substringWithRange(range),
                    "color": true
                ])
                
                if index == (friends.count - 1) {
                    endRange = _NSRange(location: endLocation, length: text.length - endLocation)
                } else {
                    endRange = _NSRange(location: endLocation, length: friends[index + 1].range.location - endLocation)
                }
                
                if endRange.length > 0 {
                    content.append([
                        "message": text.substringWithRange(endRange),
                        "color": false
                    ])
                }
            }
        }

        return Response(content: content, friends: friends, aboutUsers: aboutUsers)
    }
}
