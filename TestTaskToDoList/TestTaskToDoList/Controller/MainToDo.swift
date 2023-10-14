//
//  MainToDo.swift
//  TestTaskToDoList
//
//  Created by Владимир Данилович on 14.10.23.
//

import UIKit
import CoreData

class MainToDo: UITableViewController {

  var tasks = [Tasks]()
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

  override func viewDidLoad() {
    super.viewDidLoad()
    loadTasks()
    print(tasks)
  }


  @IBAction func addTask(_ sender: UIBarButtonItem) {

    let alertC = UIAlertController(title: "AddTask", message: nil, preferredStyle: .alert)
    let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] textField in
      if let textField = alertC.textFields?.first,
        let text = textField.text, text != "",
        let self = self {
        let tasks = Tasks(context: self.context)
        tasks.name = text
        self.tasks.append(tasks)
        self.saveTasks()
        self.tableView.insertRows(at: [IndexPath(row: self.tasks.count - 1, section: 0)], with: .fade)
      }
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

    alertC.addTextField { textFieald in
      textFieald.placeholder = "AddTask"
    }
    alertC.addAction(addAction)
    alertC.addAction(cancelAction)
    present(alertC, animated: true)
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return tasks.count
  }


  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

    cell.textLabel?.text = tasks[indexPath.row].name
    cell.accessoryType = tasks[indexPath.row].done ? .checkmark : .none

    return cell
  }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }


  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Tasks")

        if let tasks = try? context.fetch(fetchRequest) {
          for task in tasks {
            context.delete(task as! NSManagedObject)
          }
          self.tasks.remove(at: indexPath.row)
          saveTasks()
          tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
  }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
      let elementToMove = tasks[fromIndexPath.row]
      tasks.remove(at: fromIndexPath.row)
      tasks.insert(elementToMove, at: to.row)
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

      let done = tasks[indexPath.row]
      done.done.toggle()
    saveTasks()
      tableView.reloadData()
  }
}

extension MainToDo {
  private func saveTasks() {
    do {
      try context.save()
    } catch {
      print("Error Save")
    }
  }

  private func loadTasks(with request: NSFetchRequest<Tasks> = Tasks.fetchRequest()) {
      do {
          tasks = try context.fetch(request)
      } catch {
          print("Error Load")
      }
      tableView.reloadData()
  }
}
