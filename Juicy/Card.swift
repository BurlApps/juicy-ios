//
//  Card.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/6/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class Card: NSObject {
    var id: String?
    var age: Int?
    var likes: Int?
    var image: UIImage?
    var juicy: Bool?
    var created: NSDate?
    var creator: User?
    var aboutUsers: [User]?
    
    convenience init(options: PFObject) {
        self.init(options: options)
        
        self.id = options["objectId"] as? String
        self.age = options["age"] as? Int
        self.likes = options["likes"] as? Int
        self.image = options["image"] as? UIImage
        self.juicy = options["juicy"] as? Bool
        self.created = options["createdAt"] as? NSDate
        self.creator = options["creator"] as? User
    }

    // TODO: Should I use PFRelations?
//    func getAboutUsers() -> [User] {
//        var cards: [Card] = []
//        var query: PFQuery = PFQuery(className: "Cards")
//        
//        query.whereKey("Ids", equalTo: self.id)
//        query.orderByDescending("createdAt")
//        
//        for object in query.findObjects() {
//            let card = Card(options: object as PFObject)
//            cards.append(card)
//        }
//        
//        return cards
//    }
}
