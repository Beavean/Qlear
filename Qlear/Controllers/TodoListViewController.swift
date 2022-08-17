//
//  TodoListViewController.swift
//  Qlear
//
//  Created by Beavean on 11.08.2022.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework


class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedCategory = selectedCategory {
            title = selectedCategory.name
        }
    }
    //MARK: - TableView datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        var content = cell.defaultContentConfiguration()
        if let item = todoItems?[indexPath.row], let colour = FlatRed().darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
            content.text = item.title
            content.textProperties.color = ContrastColorOf(backgroundColor: colour, returnFlat: true)
            cell.contentConfiguration = content
            cell.accessoryType = item.done ? .checkmark : .none
            cell.backgroundColor = colour
            
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
                    newItem.dateCreated = Date()
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
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
}

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        self.tableView.reloadData()
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




