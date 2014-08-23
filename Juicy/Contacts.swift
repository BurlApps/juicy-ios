//
//  Contacts.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/18/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import AddressBook

class Contacts {
    
    // MARK: Class Structs
    struct Phone {
        var name: String!
        var phone: String!
    }
    
    struct Contact {
        var name: String!
        var email: String!
        var phones: [Phone] = []
    }
    
    // MARK: Private Instance Variables
    private var addressBook: ABAddressBookRef!
    private enum Access {
        case Granted, Denied
    }
    
    // MARK: Initializer
    init() {
    
    }

    // MARK: Private Instance Methods
    private func extractABAddressBookRef(abRef: Unmanaged<ABAddressBookRef>!) -> ABAddressBookRef! {
        if let ab = abRef {
            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
        }
        return nil
    }
    
    private func authorizeUser(callback: (status: Access) -> Void) {
        if ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.NotDetermined {
            var errorRef: Unmanaged<CFError>? = nil
            addressBook = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
            ABAddressBookRequestAccessWithCompletion(addressBook, { success, error in
                if error == nil {
                    if success {
                        callback(status: Access.Granted)
                    } else {
                        callback(status: Access.Denied)
                        println(error)
                    }
                } else {
                    println(error)
                }
            })
        } else if ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Authorized {
            callback(status: Access.Granted)
        } else {
            callback(status: Access.Denied)
        }
    }
    
// TODO: Uncomment After New Beta Release. takeRetainedValue() crashes now
//    func getContactNames(callback: (names: [String]!) -> Void) {
//        self.authorizeUser { (status) -> Void in
//            if status == Access.Granted {
//                var contacts: [String] = []
//                var errorRef: Unmanaged<CFError>?
//                self.addressBook = self.extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
//                var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue()
//                
//                for record:ABRecordRef in contactList {
//                    var contactName = ABRecordCopyCompositeName(record)
//                    
//                    if contactName != nil {
//                        contacts.append(contactName.takeRetainedValue() as NSString)
//                    }
//                }
//                
//                callback(names: contacts)
//            } else {
//                println("no access")
//            }
//        }
//    }
    
    
    // MARK: Fake Methods Until iOS Fixes Bug
    func getContacts(callback: (contacts: Array<Contact>) -> Void) {
        let phone: Phone = Phone(name: "mobile", phone: "3108492533")
        
        callback(contacts: [
            Contact(name: "Brian", email: nil, phones: [phone]),
            Contact(name: "Brian Vallelunga", email: nil, phones: [phone]),
            Contact(name: "Bob", email: nil, phones: [phone]),
            Contact(name: "Mark Adams", email: nil, phones: [phone]),
            Contact(name: "Gorge", email: nil, phones: [phone])
        ])
    }
}