//
//  LocalService.swift
//  spinningWheel
//
//  Created by Nickolay Truhin on 12.12.2021.
//

import Foundation
import UIKit
import CoreData

protocol LocalServicing: AnyObject {
    var rows: Property<[RowModel]> { get }
}

class LocalService: LocalServicing {
    lazy var rows: Property<[RowModel]> = {
        let property = Property<[RowModel]>(fetchRows())
        property.listeners.append { [weak self] rows in
            self?.saveRows(rows)
        }
        return property
    }()
    
    private func fetchEntities() -> [RowEntity] {
        let request = RowEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let rows = (try? context.fetch(request)) ?? []
        return rows
    }
    
    private func fetchRows() -> [RowModel] {
        fetchEntities().compactMap { row in
            guard let colorStr = row.color,
                  let color = UIColor(hex: colorStr),
                  let date = row.date,
                  let text = row.text else { return nil }
            return .init(color: color, date: date, text: text)
        }
    }
    
    private func saveRows(_ rows: [RowModel]) {
        for entity in fetchEntities() {
            context.delete(entity)
        }
        
        for row in rows {
            let entity = RowEntity(context: context)
            entity.color = row.color.toHex
            entity.date = row.date
            entity.text = row.text
        }
        try! context.save()
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "spinningWheel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private lazy var context: NSManagedObjectContext = {
        persistentContainer.viewContext
    }()
    
    private func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
