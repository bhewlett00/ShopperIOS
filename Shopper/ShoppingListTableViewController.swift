//
//  ShoppingListTableViewController.swift
//  Shopper
//
//  Created by Hewlett, Brianna Anne on 11/12/19.
//  Copyright © 2019 Hewlett, Brianna Anne. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListTableViewController: UITableViewController {
    //create a reference to a context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //create a variable that will contain the row of selected Shopping List
    var selectedShoppingList: ShoppingList?
    
    //create an array to store Shopping List Items
    var shoppingListItems = [ShoppingListItem] ()

    override func viewDidLoad() {
        super.viewDidLoad()

        //call load shopping list items method
        loadShoppingListItems()
        
        //make row height larger
        self.tableView.rowHeight = 84.0
        
        setTitle()
    }
    
    func setTitle(){
        //declare local varianle to store total cost of shopping list and initialize it to 0
        var totalCost = 0.0
        
        //loop through the shopping list items and compute total cost
        for (list) in shoppingListItems {
            totalCost += Double(list.price * Double(list.quantity))
        }
        
        //if we have a valid Shopping List
        if let selectedShoppingList = selectedShoppingList{
            //get the ShoppingList name and set the title
            title = selectedShoppingList.name! + String(format: " $%.2f", totalCost)
        }else{
            //set the title to Shopping List Items
            title = "Shopping List Items"
        }
    }

    //fetch ShoppingListItems from Core Data
    func loadShoppingListItems(){
        //check is Shopper Table View Controller has passed a valid Shopping List
        if let list = selectedShoppingList{
            //if the Shopping List has items cast to an array of ShoppingListItems
            if let listItems = list.items?.allObjects as? [ShoppingListItem]{
                //store constant in Shopping List Items array
                shoppingListItems = listItems
            }
        }
        
        //reload fetched data in Table View Controller
        tableView.reloadData()
    }
    
    //save ShoppingListItems entities into Core Data
    func saveShoppingListItems(){
        //use context to save ShoppingLists into Core Data
        do{
            try context.save()
        }catch{
            print("Error saving ShoppingListItems to Core Data")
        }
        
        //reload the data in the Table View Controller
        tableView.reloadData()
    }
    
    //delete shopping list item entities from core data
    func deleteShoppingListItem(item: ShoppingListItem){
        context.delete(item)
        
        //use context to delete ShoppingList Item from Core Data
        do{
            try context.save()
        }catch{
            print("Error deleting ShoppingListItem from Core Data")
        }
        
        loadShoppingListItems()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //declare Text Fields variables for input of name, price, and quantity
        var nametextField = UITextField()
        var pricetextField = UITextField()
        var quantitytextField = UITextField()
        
        //create an Alert Controller
        let alert = UIAlertController(title: "Add Shopping List Item", message: "", preferredStyle: .alert)
        
        //definen an action that will occur when the Add Item button is pushed
        let action = UIAlertAction(title: "Add Item", style: .default, handler: { (action) in
            //create an instance of a ShoppingList entity
            let newShoppingListItem = ShoppingListItem(context: self.context)
            
            //get name, price, quantity, purchased, and relationship input by user and store them in ShoppingList entity
            newShoppingListItem.name = nametextField.text!
            newShoppingListItem.price = Double(pricetextField.text!)!
            newShoppingListItem.quantity = Int64(quantitytextField.text!)!
            newShoppingListItem.purchased = false
            newShoppingListItem.shoppingList = self.selectedShoppingList
            
            //add ShoppingListItem entity into array
            self.shoppingListItems.append(newShoppingListItem)
            
            //save ShoppingListItem into Core Data
            self.saveShoppingListItems()
            
            //update the title to incorporate the cost of the added shopping list item
            self.setTitle()
        })
        
        //disable the action that will occur when the Add List button is pushed
        action.isEnabled = false
        
        //decline an action that will occur when the cancel button is pushed
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (cancelAction) in
            
        })
        
        //add actions into Alert Controller
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        //add the Text Fields into the Alert Controller
        alert.addTextField(configurationHandler: { (field) in
            nametextField = field
            nametextField.placeholder = "Enter Name"
            nametextField.addTarget(self, action: #selector((self.alertTextFieldDidChange)), for: .editingChanged)
        })
        alert.addTextField(configurationHandler: { (field) in
            pricetextField = field
            pricetextField.placeholder = "Enter Price"
            pricetextField.addTarget(self, action: #selector((self.alertTextFieldDidChange)), for: .editingChanged)
        })
        alert.addTextField(configurationHandler: { (field) in
            quantitytextField = field
            quantitytextField.placeholder = "Enter Quantity"
            quantitytextField.addTarget(self, action: #selector((self.alertTextFieldDidChange)), for: .editingChanged)
        })

        //display the Alert Controller
        present(alert, animated: true, completion: nil)
    }
    
    @objc func alertTextFieldDidChange(){
        //get reference to the Alert Controller
        let alertController = self.presentedViewController as! UIAlertController
        
        //get a reference to the Ction that allows the user to add a ShoppingList
        let action = alertController.actions[0]
        
        //get references to teh text in the Text Fields
        if let name = alertController.textFields![0].text, let price = alertController.textFields![1].text, let quantity = alertController.textFields![2].text {
            
            //trim whitespace from the text
            let trimmedName = name.trimmingCharacters(in: .whitespaces)
            let trimmedPrice = price.trimmingCharacters(in: .whitespaces)
            let trimmedQuantity = quantity.trimmingCharacters(in: .whitespaces)
            
            //check if teh trimmed text isn't empty and if it isn't enable the acion that allows the user to add a ShoppingList
            if(!trimmedName.isEmpty && !trimmedPrice.isEmpty && !trimmedQuantity.isEmpty){
                action.isEnabled = true
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // return number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        //we will hav eas amny rows as there are shopping list items
        return shoppingListItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingListItemCell", for: indexPath)

        // Configure the cell...
        let shoppingListItem = shoppingListItems[indexPath.row]
        
        //set the cell title equal to the shopping list item name
        cell.textLabel?.text = shoppingListItem.name!
        
        //set detailTextLabel numberOfLines to 0
        cell.detailTextLabel!.numberOfLines = 0
        
        //set the cell subtitle equal to the shopping list item price and quantity
        cell.detailTextLabel?.text = String(shoppingListItem.quantity) + "\n" + String(shoppingListItem.price)
        
        //set the cell accessory type to checkmark if the purchased is eqaul to true, else set it to none
        if(shoppingListItem.purchased == false){
            cell.accessoryType = .none
        }else{
            cell.accessoryType = .checkmark
        }

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingListItemCell", for: indexPath)

        // getting the selected shopping list item
        let shoppingListItem = shoppingListItems[indexPath.row]
        
        //get quantity, price, and purchased indicator for selected shopping list item
        let sQuantity = String(shoppingListItem.quantity)
        let sPrice = String(shoppingListItem.price)
        let purchased = shoppingListItem.purchased
        
        if(purchased == true){
            //if purchased indicator is true, set it to false and remove checkmark
            cell.accessoryType = .none
            shoppingListItem.purchased = false
        }else{
            //if purchased indicator is false, set it to true and add checkmark
            cell.accessoryType = .checkmark
            shoppingListItem.purchased = true
        }
        
        //configure the table view cell
        cell.textLabel?.text = shoppingListItem.name
        cell.detailTextLabel!.numberOfLines = 0
        cell.detailTextLabel?.text = sQuantity + "\n" + sPrice
        
        //save update to purchased indicator
        self.saveShoppingListItems()
        
        //call deselectRow method to allow update to be visible in tbale view controller
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let item = shoppingListItems[indexPath.row]
            deleteShoppingListItem(item: item)
            setTitle()
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
