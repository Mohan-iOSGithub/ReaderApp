//
//  CoreDataStack.swift
//  ReaderApp
//
//  Created by Mohanaprabhu on 12/09/25.
//

import Foundation
import CoreData
import CommonCrypto

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ReaderApp")
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Error details: \(error.userInfo)")
                fatalError("Unresolved Core Data error")
            } else {
                // Debug entities immediately after loading
                let entities = container.managedObjectModel.entities
                if entities.count > 0 {
                    print("Found entities count in model: \(entities.count)")
                    
                    for entity in entities {
                        print("- \(entity.name ?? "Unknown")")
                    }
                } else {
                    print("<<<<<<<<<< Not Found entities in model >>>>>>>>>>")
                }
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "ReaderApp")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("❌ Failed to load Core Data stack: \(error)")
            }
        }
        
        // 🔑 Prevent duplicate crashes / conflicts
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("❌ Core Data save error: \(error)")
            }
        }
    }
}

extension Data {
    var sha256: String {
        return withUnsafeBytes { bytes in
            var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256(bytes.bindMemory(to: UInt8.self).baseAddress, CC_LONG(count), &hash)
            return hash.map { String(format: "%02x", $0) }.joined()
        }
    }
}
