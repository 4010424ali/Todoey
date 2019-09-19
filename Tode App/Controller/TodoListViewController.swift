import UIKit
import RealmSwift
class TodoListViewController: SwipeTableViewController {
 
    var todoItems: Results<Item>?
    
    let realm = try! Realm()
    
    var selectCategory: Category? {
        didSet {
           loadItem()
        }
    }
    
    
    //  let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("item.plist") ?? "")
        
    }

    //Mark - Tableview Datasource Method
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if  let item = todoItems?[indexPath.row]{
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType =   item.done ? .checkmark : .none
        
        } else {
           cell.textLabel?.text = "No Item Added"
        }
        
          return cell
    }
    
    //MARK: - TableView Delegate method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row]{
          
            do {
                
                try realm.write {
                    item.done = !item.done
                    
                    //realm.delete(item)
                }
                
            } catch {
                
                print("error saving don status, \(error)")
                
            }
        }
        
        tableView.reloadData()
//        todoItems?[indexPath.row].done = todoItems?[indexPath.row].done
        
        // order is very important elete the Item
        //context.delete(itemArrsy[indexPath.row])

        //itemArrsy.remove(at: indexPath.row)
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What happen once the user clcik the Add Item button
 
            if let currentCategory = self.selectCategory {
                
                do {
                    try self.realm.write {
                        let newItem = Item()
                        
                        newItem.title = textField.text!
                        
                        newItem.dateCreated = Date()
                        
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error Saving the new Iten, \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Craete New Item"
            
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadItem(){

        todoItems = selectCategory?.items.sorted(byKeyPath: "title", ascending: true)
       
        tableView.reloadData()
    }
    
    //MARK - DeleteData from Swip
    override func updateModal(at indexPath: IndexPath){
        if let categoryForDelete = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDelete)
                }
            } catch {
                print("Error deleting category, \(error) ")
            }
        }
    }
}


//MARK: - SearchBar functionality
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text ?? "").sorted(byKeyPath: "dateCreated", ascending: true)
      
        tableView.reloadData()
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
