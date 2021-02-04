//
//  ViewController.swift
//  ToDoList
//
//  Created by Victor Lee on 12/22/20.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
        
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colourHex = selectedCategory?.colour {
            title = selectedCategory?.name
            guard let navBar = navigationController?.navigationBar else { fatalError("nav controller doesnt exist")}

            if let navBarColour = UIColor(hexString: colourHex) {
                navBar.backgroundColor = navBarColour
                navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColour, returnFlat: true)]
                searchBar.backgroundColor = navBarColour
                
            }
      
    
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
    
            
        } else {
            cell.textLabel?.text = "No items added"
        }
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            }catch {
                print("error in saving done status \(error)")
            }
        }
            
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var texField = UITextField()
        
        let alert = UIAlertController(title: "Add new to do Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { [self] (action) in
            // happen whne user clicks
            if let currentCategory = selectedCategory {
                do {
                    try realm.write {
                        let newItem = Item()
                        newItem.title = texField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }catch {
                    print("Error in saving new itmes, \(error)")
                }
                
            }
            tableView.reloadData()
        }  
        
        alert.addTextField { (alertTextfield) in
            
            alertTextfield.placeholder = "Create New Item"
            texField = alertTextfield
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil  )
        
    }
    
//    func saveItems() {
//
//        //        do {
//        //            try context.save()
//        //        } catch {
//        //            print("Error saving context")
//        //        }
//        //        tableView.reloadData()
//    }
    
    func loadItems()  {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
        
        
        //            let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        //
        //            if let additionalPredicate = predicate {
        //                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        //            } else {
        //                request.predicate = categoryPredicate
        //            }
        //
        //            do {
        //                itemArray = try context.fetch(request)
        //            } catch {
        //                print("Error in fetching")
        //            }
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let itemsForDeletion = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemsForDeletion)
                }
            } catch {
                print("error")
            }
        }
    }
    
}

//MARK: Search bar methods
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
/// Realm
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()

        
        
        ///Core Data
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        //cd stands to not be sensative to upper or lower cases
//        let predicate  = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request, predicate: predicate)
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}



