//
//  CategoryTableViewController.swift
//  ToDoList
//
//  Created by Victor Lee on 12/27/20.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories: Results<Category>?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let navBar = navigationController?.navigationBar else { fatalError("nav controller doesnt exist")}
        
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textFiled = UITextField()
        
        let alertVc = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { [self] (action) in
            
            let newCategory = Category()
            
            newCategory.name = textFiled.text!
            newCategory.colour = UIColor.randomFlat().hexValue()
            /// Mark: - We dont need to append objects because Results is an auto-updating container type in Realm returned from object queries.
            //            categories.append(newCategory)
            saveItems(category: newCategory)
        }
        
        alertVc.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "Create new Item"
            textFiled = alertTextfield
        }
        alertVc.addAction(action)
        present(alertVc, animated: true, completion: nil)
    }
    
    func saveItems(category: Category) {
        
        do {
            try realm.write{
                realm.add(category)
            }
        }catch {
            print(error.localizedDescription)
        }
        
        tableView.reloadData()
    }
    
    func loadItems() {
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    //Delete data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let categoryForDeletion = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(categoryForDeletion)
                }
            } catch {
                print("error")
            }
        }
    }
    
}


extension CategoryTableViewController {
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name 
            guard let categoryColour = UIColor(hexString: category.colour) else { fatalError("COLOR DOESNT EXIST")}
            cell.backgroundColor = categoryColour
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }


        return cell
    }
    // MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
}
