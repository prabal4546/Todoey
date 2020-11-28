//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems: Results<Item>?
    var selectedCategory: Category?{
    didSet{
        loadItems()
        }
    }
    
   // let defaults = UserDefaults.standard
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        tableView.separatorStyle = .none
        
        tableView.rowHeight = 80.0
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        if let colourHex = selectedCategory?.colour{
            guard let navBar = navigationController?.navigationBar else {fatalError("navigation controller does not exist")}
            
            if let navBarColor = UIColor(hexString:colourHex ){
                
                navBar.backgroundColor = navBarColor
                searchBar.barTintColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                
            }
            
            
        }
    }
            
        //}
//        let newItem1 = Item()
//        newItem1.title = "find mike"
//        itemArray.append(newItem1)
//
//        let newItem2 = Item()
//        newItem2.title = "buy eggos"
//        itemArray.append(newItem2)
//
//        let newItem3 = Item()
//        newItem3.title = "destroy demogorgon"
//        itemArray.append(newItem3)
//    }
    
    //-Mark
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView,cellForRowAt: indexPath)
        
        if let item  = todoItems?[indexPath.row]{
            
            cell.textLabel?.text = item.title
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(CGFloat(indexPath.row)/CGFloat(todoItems!.count))){
                cell.backgroundColor = colour
                cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn:colour, isFlat:true)
            }
                  //Ternary operator
                  //value = condition ? valueIfTrue:valueIfFalse
                  
            cell.accessoryType = item.done ? .checkmark : .none
            
        }else{
            cell.textLabel?.text = "no items added"
        }
        
      
        
//        if item.done == true{
//            cell.accessoryType = .checkmark
//        }else{
//            cell.accessoryType = .none
//        }
        return cell
        
    }
    //-Mark TableViewDelegate method
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write(){
                    //realm.delete(item)
                    item.done = !item.done
                }
            }catch{
                print("error saving done status,\(error)")
            }
        }
        tableView.reloadData()
        //tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        // print(itemArray[indexPath.row])
        
 //-Mark Delete in CRUD
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
       
        
//        if itemArray[indexPath.row].done == false{
//            itemArray[indexPath.row].done = true
//        }
//        else{
//            itemArray[indexPath.row].done = false
//        }
        
        
//        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark
//        {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        }else{
//                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//            }
//
        
//        todoItems[indexPath.row].done = !itemArray[indexPath.row].done
//        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
    }
    //-MARK ADD NEW ITEMS
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        
       
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Ad  new Todoey item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            //what will happen when the user clicks add item
            
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write(){
                let newItem = Item()
                newItem.title = textField.text!
                newItem.dateCreated = Date()
                currentCategory.items.append(newItem)
                    }
                    
                }catch{
                    print("error saving new items,\(error)")
                }
            }
            
              
              
//            newItem.parentCategory = self.selectedCategory
//            
//            self.itemArray.append(newItem)
            self.tableView.reloadData()
            
          
            //self.defaults.set(self.itemArray, forKey: "TodoListArray")
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
    }
//    func saveItems(){
//        //let encoder = PropertyListEncoder()
//                  do{
//                    try context.save()
//                  }
//                  catch{
//                    print("error saving context,\(error)")
//                  }
//                  self.tableView.reloadData()
//
//    }
    func loadItems(){
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//
//        do{
//              itemArray = try context.fetch(request)
//        }catch{
//            print("error fetching data from context,\(error) ")
//        }
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row]{
            do{
            try realm.write{
                realm.delete(item)
                }
                
            }catch{
                print("error deleting list items,\(error)")
            }
        }
    }
}
//-MARK SEARCH BAR METHODS
extension TodoListViewController:UISearchBarDelegate{

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
        
        
        
    }
//        let request  = NSfetch
//
//        request.predicate  = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

//        do{
//              itemArray = try context.fetch(request)
//        }catch{
//            print("error fetching data from context,\(error) ")
//        }
//        loadItems(with: request)

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()


            DispatchQueue.main.async{
                searchBar.resignFirstResponder()
            }
        }
    }

}

