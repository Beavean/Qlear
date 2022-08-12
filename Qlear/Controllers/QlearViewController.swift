//
//  QlearViewController.swift
//  Qlear
//
//  Created by Beavean on 11.08.2022.
//

import UIKit
import CoreData

class QlearViewController: UITableViewController {
    
    var itemsArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - TableView datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QlearItemCell", for: indexPath)
        let item = itemsArray[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        cell.contentConfiguration = content
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    //MARK: - TableView delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemsArray[indexPath.row].done = !itemsArray[indexPath.row].done
        self.saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addItemButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { action in
            guard let item = textField.text else { return }
            let newItem = Item(context: self.context)
            newItem.title = item
            newItem.done = false
            self.itemsArray.append(newItem)
            self.saveItems()
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        self.tableView.reloadData()
    }
    
//    func loadItems() {
//        guard let path = self.dataFilePath else { return }
//       if let data = try? Data(contentsOf: path) {
//            let decoder = PropertyListDecoder()
//            do {
//            itemsArray = try decoder.decode([Item].self, from: data)
//            } catch {
//                print("Error decoding items: \(error)")
//            }
//        }
//    }
}

