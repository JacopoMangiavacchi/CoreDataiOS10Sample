//
//  TableViewController.swift
//  CoreDataiOS10Sample
//
//  Created by Jacopo Mangiavacchi on 10/31/16.
//  Copyright © 2016 Jacopo. All rights reserved.
//

import UIKit
import CoreData


class TableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    lazy var fetchedResultsController:NSFetchedResultsController<Entity> = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedContext = appDelegate?.persistentContainer.viewContext
        managedContext?.automaticallyMergesChangesFromParent = true
        
        let fetchRequest =  NSFetchRequest<Entity>(entityName: "Entity")
        
        let primarySortDescriptor = NSSortDescriptor(key: "attribute", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let resultsController = NSFetchedResultsController<Entity>(fetchRequest: fetchRequest, managedObjectContext: managedContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        resultsController.delegate = self
        
        return resultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CoreData iOS10"
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "Cell")
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func addRecord(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "New Entity",
                                      message: "Add a new Entity",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
            
            self.save(name: nameToSave)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        appDelegate.persistentContainer.performBackgroundTask { (managedContext) in
            let entity = NSEntityDescription.entity(forEntityName: "Entity",
                                                    in: managedContext)!
            
            let entityObject = Entity(entity: entity, insertInto: managedContext)

            entityObject.attribute = name
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath)
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        let entityObject = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.text = entityObject.attribute
    }
    
    //MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    @objc(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:) func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath {
                if let cell = tableView.cellForRow(at: indexPath) {
                    configureCell(cell, indexPath: indexPath)
                }
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
}
