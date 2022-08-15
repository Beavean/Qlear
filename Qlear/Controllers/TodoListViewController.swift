//
//  TodoListViewController.swift
//  Qlear
//
//  Created by Beavean on 11.08.2022.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    //MARK: - TableView datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        if let item = todoItems?[indexPath.row] {
            content.text = item.title
            cell.contentConfiguration = content
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            content.text = "No items added"
            cell.contentConfiguration = content
        }
        return cell
    }
    
    //MARK: - TableView delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write({
                    item.done = !item.done
                })
            }catch {
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func addItemButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { action in
            guard let item = textField.text, let currentCategory = self.selectedCategory else { return }
            do {
                try self.realm.write({
                    let newItem = Item()
                    newItem.title = item
                    currentCategory.items.append(newItem)
                })
            } catch {
                print("Error saving new items, \(error)")
            }
            self.tableView.reloadData()
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        self.tableView.reloadData()
    }
}



