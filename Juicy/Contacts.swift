//
//  Contacts.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/18/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import AddressBook

class Contacts {
    
    // MARK: Instance Variables
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
        if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.NotDetermined) {
            var errorRef: Unmanaged<CFError>? = nil
            addressBook = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
            ABAddressBookRequestAccessWithCompletion(addressBook, { success, error in
                if success {
                    callback(status: Access.Granted)
                } else {
                    callback(status: Access.Denied)
                    println(error)
                }
            })
        } else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Denied || ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Restricted) {
            callback(status: Access.Denied)
        } else if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Authorized) {
            callback(status: Access.Granted)
        }
    }

    func getContactNames(callback: (names: [String]!) -> Void) {
        self.authorizeUser { (status) -> Void in
            var contacts: [String] = []
            var errorRef: Unmanaged<CFError>?
            self.addressBook = self.extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
            var contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue()
            
            for record:ABRecordRef in contactList {
                var contactPerson: ABRecordRef = record
                var contactName: String = ABRecordCopyCompositeName(contactPerson).takeRetainedValue() as NSString
                contacts.append(contactName)
            }
            
            callback(names: contacts)
        }
    }
}