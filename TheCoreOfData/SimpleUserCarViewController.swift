//
//  ViewController.swift
//  TheCoreOfData
//
//  Created by Jasmee Sengupta on 01/03/18.
//  Copyright © 2018 Jasmee Sengupta. All rights reserved.
//  Getting started with Core Data - User with 2 cars

import UIKit
import CoreData

class ViewController: UIViewController {

    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRecords()
        saveManagedObjectContext()
        fetchUser(name: "Jas", sortby: "email")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpRecords() {
        guard let user = getUserObject(name: "Jas", email: "jas@a.com", dob: "01/01/1971", children: 0) else { return }
        guard let car1 = getCarObject(model: "Lamborghini", year: 2019) else { return }
        guard let car2 = getCarObject(model: "Audi", year: 2018) else { return }
        car1.setValue(user, forKey: "user_id")
        car2.setValue(user, forKey: "user_id")
    }
    
    // MARK: Create records
    
    func getUserObject(name: String, email: String, dob: String, children: Int) -> NSManagedObject? {
        guard let user = getEntityObject(name: "User") else { return nil}
        user.setValuesForKeys(["name": name, "email": email, "number_of_children": children])
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/mm/yyyy"
        if let dob = formatter.date(from: dob) {
            user.setValue(dob, forKey: "date_of_birth")
        } else {
            print("Could not convert date of birth")
            user.setNilValueForKey("date_of_birth")
        }
        return user
    }
    
    func getCarObject(model: String, year: Int) -> NSManagedObject? {
        guard let car = getEntityObject(name: "Car") else { return nil }
        car.setValuesForKeys(["model": model, "year": year])
        return car
    }
    
    func getManagedObjectContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        managedObjectContext = appDelegate.persistentContainer.viewContext
        return managedObjectContext
    }
    
    func getEntityObject(name: String) -> NSManagedObject? {
        guard let managedObjectContext = getManagedObjectContext() else {
            return nil
        }
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: managedObjectContext) else { return nil }
        let object = NSManagedObject(entity: entity, insertInto: managedObjectContext)
        return object
    }
    
    // MARK: Save records
    
    func saveManagedObjectContext() {
        do {
            try managedObjectContext?.save()
            print("Saved successfully")
        } catch let error as NSError {
            print("Could not save context \(error), \(error.userInfo)")
        }
    }
    
    // MARK: Fetch records

    func fetchUser(name: String, sortby: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: sortby, ascending: true)]
        let users = try! managedObjectContext?.fetch(fetchRequest)
        guard let user = users?.first as? User else { return }
        let cars = user.cars?.allObjects as! [Car]
        print("\(user.name!) has \(cars.count) cars, dob: \(user.date_of_birth!)")
    }

}

