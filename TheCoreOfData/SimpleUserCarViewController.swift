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
        managedObjectContext = getManagedObjectContext()
        //setUpRecords()
        delete(entity: "User")
        delete(entity: "Car")
        createDB()
        //getUser()
        //fetchUser(name: "Jas", sortby: "email")
        fetchCars(predicate: "model = %@", searchString: "Lamborghini")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Create User and car
    
    func getUser(name: String, email: String, dob: String, children: Int) -> NSManagedObject? {
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
    
    func getCar(model: String, year: Int) -> NSManagedObject? {
        guard let car = getEntityObject(name: "Car") else { return nil }
        car.setValuesForKeys(["model": model, "year": year])
        return car
    }
    
    func getEntityObject(name: String) -> NSManagedObject? {
        if let moc = managedObjectContext {
            guard let entity = NSEntityDescription.entity(forEntityName: name, in: moc) else { return nil }
            let object = NSManagedObject(entity: entity, insertInto: managedObjectContext)
            return object
        }
        return nil
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
    
    // MARK: Managed Object Context Methods
    
    func getManagedObjectContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        managedObjectContext = appDelegate.persistentContainer.viewContext
        return managedObjectContext
    }
    
    func saveManagedObjectContext() {
        do {
            try managedObjectContext?.save()
            print("Saved successfully")
        } catch let error as NSError {
            print("Could not save context \(error), \(error.userInfo)")
        }
    }

}

extension ViewController {// Fetch records
    func getUser() {
        fetchUser(key: "name", value: "Jasmee")
        fetchUser(key: "name", value: "Harry")
        fetchUser(key: "name", value: "Dim")
        
        //fetchUser(key: "date_of_birth", value: "01/01/1970")
    }
    
    func fetchCars(predicate: String, searchString: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Car")
        //fetchRequest.fetchLimit = 10
        fetchRequest.predicate = NSPredicate(format: predicate, searchString)
        let carArray = try! managedObjectContext?.fetch(fetchRequest)
        for eachCar in carArray! {
            guard let car = eachCar as? Car else { return }
            print("car \(car.model) is from \(car.year) owned by \(car.user_id?.name)")
        }
    }
    
    func fetchUser(key: String, value: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "\(key) = %@", value)
        let userArray = try! managedObjectContext?.fetch(fetchRequest)
        guard let user = userArray?.first as? User else { return }// gen
        let cars = user.cars?.allObjects as! [Car]
        print("\(user.name!) has \(cars.count) cars, email: \(user.email), dob: \(user.date_of_birth!)")
    }
    
    func fetchUser2() {
        do {
            let fetchRequest : NSFetchRequest<User> = User.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", "Jasmee")
            let fetchedResults = try managedObjectContext?.fetch(fetchRequest) as! [User]
            if let aContact = fetchedResults.first {
                //providerName.text = aContact.providerName
            }
        }
        catch {
            print ("fetch task failed", error)
        }
    }
    func fetchEntity(name: String, key: String, value: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "\(key) = %@", value)
        let entityArray = try! managedObjectContext?.fetch(fetchRequest)
        let entityType = NSEntityDescription.entity(forEntityName: name, in: managedObjectContext!)
        //guard let entity = entityArray?.first as? entity else { return }// gen
        //let cars = user.cars?.allObjects as! [Car]
        //print("\(user.name!) has \(cars.count) cars, dob: \(user.date_of_birth!)")
    }
    
    func fetchEntities(name: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRequest.fetchLimit = 10 // check by 3
        
    }
}

extension ViewController {// create records
    
    func createDB() {
        setUpUsers(name: "Jasmee", email: "j@a.com", dob: "01/01/1970", children: 0, carModels: [("Lamborghini", 1970), ("Mercedes", 1971)])
        setUpUsers(name: "Dimpu", email: "d@a.com", dob: "01/01/1976", children: 0, carModels: [("Jaguar", 1970), ("Ferrari", 1971)])
        setUpUsers(name: "Harry", email: "h@a.com", dob: "01/01/1978", children: 3, carModels: [("Lamborghini", 1970), ("Ferrari", 1976)])
        setUpUsers(name: "Ron", email: "r@a.com", dob: "01/01/1989", children: 1, carModels: [("Jaguar", 1970), ("Lamborghini", 1971)])
        setUpUsers(name: "Lakshmibai", email: "l@a.com", dob: "01/01/1901", children: 1, carModels: [("Horse", 1970), ("Elephant", 1971)])
        saveManagedObjectContext()
    }
    
    func setUpUsers(name: String, email: String, dob: String, children: Int, carModels: [(String, Int)]) {
        guard let user = getUser(name: name, email: email, dob: dob, children: children) else { return }
        for carModel in carModels {
            guard let car = getCar(model: carModel.0 , year: carModel.1) else { return }
            car.setValue(user, forKey: "user_id")
        }
    }
    
    func setUpRecords() {
        guard let user = getUser(name: "Jas", email: "jas@a.com", dob: "01/01/1971", children: 0) else { return }
        guard let car1 = getCar(model: "Lamborghini", year: 2019) else { return }
        guard let car2 = getCar(model: "Audi", year: 2018) else { return }
        car1.setValue(user, forKey: "user_id")
        car2.setValue(user, forKey: "user_id")
    }
}

extension ViewController {// Delete records
    func delete(entity: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        if let result = try? managedObjectContext?.fetch(fetchRequest) {
            for object in result! {
                if let nsmo = object as? NSManagedObject {
                    managedObjectContext?.delete(nsmo)
                }
            }
            saveManagedObjectContext()
        }
    }
    
    func batchDelete() {
        /* not working
         let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
         do {
         try managedObjectContext?.persistentStoreCoordinator?.execute(deleteRequest, with: managedObjectContext!)
         saveManagedObjectContext()
         } catch let error as NSError {
         print("Could not delete all \(entity) entities")
         }*/
    }
}
/* swift 2.1?
 // Initialize Fetch Request
 let fetchRequest = NSFetchRequest()
 
 // Create Entity Description
 let entityDescription = NSEntityDescription.entityForName("Person", inManagedObjectContext: self.managedObjectContext)
 
 // Configure Fetch Request
 fetchRequest.entity = entityDescription
 
 do {
 let result = try self.managedObjectContext.executeFetchRequest(fetchRequest)
 print(result)
 
 } catch {
 let fetchError = error as NSError
 print(fetchError)
 }
 */
