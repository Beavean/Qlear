//
//  QlearViewController.swift
//  Qlear
//
//  Created by Beavean on 11.08.2022.
//

import UIKit

class QlearViewController: UITableViewController {
    
    var itemsArray = [ItemModel]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
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
            let newItem = ItemModel()
            newItem.title = item
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
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.itemsArray)
            guard let path = self.dataFilePath else { return }
            try data.write(to: path)
        } catch {
            print("Error encoding items: \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems() {
        guard let path = self.dataFilePath else { return }
       if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do {
            itemsArray = try decoder.decode([ItemModel].self, from: data)
            } catch {
                print("Error decoding items: \(error)")
            }
        }
    }
}

