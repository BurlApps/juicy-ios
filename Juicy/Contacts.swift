//
//  Contacts.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/18/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import AddressBook
import Foundation

class Contacts {
    
    // MARK: Class Structs
    struct Phone {
        var name: String!
        var phone: String!
    }
    
    struct Contact {
        var name: String!
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
    func getContacts(callback: (contacts: Array<Contact>) -> Void) {
        self.authorizeUser { (status) -> Void in
            if status == Access.Granted {
                var contacts: [Contact] = []
                var tempContacts: Dictionary<String, Int> = [:]
                var errorRef: Unmanaged<CFError>?
                self.addressBook = self.extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
                var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue()
                
                for record:ABRecordRef in contactList {
                    let contactName = ABRecordCopyCompositeName(record)
                    let phones: ABMultiValueRef = ABRecordCopyValue(record, kABPersonPhoneProperty).takeRetainedValue()
                    var phoneList: [Phone] = []
                    
                    if contactName != nil {
                        var name: NSString = contactName.takeRetainedValue() as NSString
                        
                        if name.length != 0 {
                            for index: CFIndex in 0...ABMultiValueGetCount(phones) {
                                let phoneNumber = ABMultiValueCopyValueAtIndex(phones, index).takeRetainedValue() as NSString
                                let locLabel = ABMultiValueCopyLabelAtIndex(phones, index).takeRetainedValue() as NSString
                                let phoneLabel = ABAddressBookCopyLocalizedLabel(locLabel).takeRetainedValue() as NSString
                                
                                if phoneNumber.length != 0 && phoneLabel.length != 0 {
                                    phoneList.append(Phone(name: phoneLabel, phone: phoneNumber))
                                }
                            }
                            
                            if !phoneList.isEmpty {
                                let contact = Contact(name: name, phones: phoneList)
                                
                                if tempContacts[name as String] != phoneList.count {
                                    contacts.append(Contact(name: name, phones: phoneList))
                                    tempContacts[name] = phoneList.count
                                }
                            }
                        }
                    }
                }
                
                contacts.sort({ $0.name < $1.name })
                callback(contacts: contacts)
            } else {
                println("no access")
            }
        }
    }
}