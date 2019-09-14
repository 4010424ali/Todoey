import UIKit
import CoreData

class TodoListViewController: UITableViewController {
 
    var itemArrsy = [Item]()
    
    var selectCategory: Category? {
        didSet {
            loadItem()
        }
    }
    
    // create the link app delegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
   
    
    //  let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("item.plist") ?? "")
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
    
    //MARK: - TableView Delegate method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArrsy[indexPath.row].done = !itemArrsy[indexPath.row].done
        
        // order is very important delete the Item
        //context.delete(itemArrsy[indexPath.row])

        //itemArrsy.remove(at: indexPath.row)
        
        saveItem()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What happen once the user clcik the Add Item button
 
            let newItem = Item(context: self.context)
            
            newItem.titile = textField.text!
            
            newItem.done = false
            
            newItem.parentCategory = self.selectCategory
            
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
    
    func loadItem(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
     
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectCategory!.name!)
        
        if let additionalPredicate = predicate {
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            
        } else {
            
            request.predicate = categoryPredicate
            
        }
        
        do {
            
          itemArrsy =  try context.fetch(request)
            
        } catch {
            
            print("Error fetching data from content \(error)")
            
        }
        
        tableView.reloadData()
    }
}


//MARK: - SearchBar functionality
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request :NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "titile CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors  = [NSSortDescriptor(key: "titile", ascending: true)]
        
        loadItem(with : request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItem()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
