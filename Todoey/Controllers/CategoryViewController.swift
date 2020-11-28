//
//  CategoryViewController.swift
//  Todoey
//
//  Created by PRABALJIT WALIA     on 20/05/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
   
    
    
    var categories: Results<Category>?
  //  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("navigation controller does not exist")}
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")
    }
    //-MARK TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        
        if let category = categories?[indexPath.row]{
        cell.textLabel?.text = categories?[indexPath.row].name ?? "no category added yet"
          
            
            
        cell.backgroundColor = UIColor(hexString: category.colour ?? "1D9BF6")
            cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: category.colour)!, returnFlat: true)
        }
        
       
        return cell
    }
    //-Mark TableView Delegate Mehtods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //-Mark Data Manipulation Methods
    func save(category: Category){
        do{
            try realm.write{
                realm.add(category)
                
                
            }
        }catch{
            print("error saving category,\(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(){
        categories = realm.objects(Category.self)
//        let request: NSFetchRequest<Category> = Category.fetchRequest()
//        do{
//            category = try context.fetch(request)
//        }catch{
//            print("error reading/loading category,\(error)")
//        }
//        tableView.reloadData()
    }
    //-Mark:Delete form Swipe
    override func updateModel(at indexPath: IndexPath) {
        
                       if let categoryForDeletion = self.categories?[indexPath.row]{
                           do{
                               try self.realm.write{
                                   self.realm.delete(categoryForDeletion)
                               }
        
                           }catch{
                                   print("error deleting category,\(error)")
                               }
        
        
                       }
    }
    //MARK Add new category

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat().hexValue()
            
            self.save(category: newCategory)
        }
        alert.addAction(action)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }
        present(alert,animated: true,completion: nil)
    }
    
}
//MARK-SWIPE CELL DLEEGATE METHOD
