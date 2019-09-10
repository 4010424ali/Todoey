import UIKit
import CoreData

class TodoListViewController: UITableViewController {
 
    var itemArrsy = [Item]()
    
    // create the link app delegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
   
    
//    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("item.plist") ?? "")
        loadItem()
        
    }

    //Mark - Tableview Datasource Method
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArrsy.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        let item = itemArrsy[indexPath.row]
        
        cell.textLabel?.text = item.titile
        
        cell.accessoryType =   item.done ? .checkmark : .none
        
        return cell
    }
    
    //Mark - TableView Delegate method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArrsy[indexPath.row].done = !itemArrsy[indexPath.row].done
        
        // order is very important delete the Item
        //context.delete(itemArrsy[indexPath.row])

        //itemArrsy.remove(at: indexPath.row)
        
        saveItem()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //Mark - Add New Item
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What happen once the user clcik the Add Item button
            
            print("Success")
            
            
            let newItem = Item(context: self.context)
            
            newItem.titile = textField.text!
            newItem.done = false
            
            self.itemArrsy.append(newItem)
            
            self.saveItem()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Craete New Item"
            
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveItem(){
        do {
            
           try context.save()
            
        } catch {
            
            print("Error saving context \(error)")
            
        }
        
        tableView.reloadData()
    }
    
    func loadItem(){
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do {
          itemArrsy =  try context.fetch(request)
        } catch {
            print("Error fetching data from content \(error)")
        }
    }
}
