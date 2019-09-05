//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 02/09/2019.
//  Copyright © 2019 Alexey Efimov. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    private let cellID = "cell"
    private var tasks: [Task] = []
    private let managedContext = (
        UIApplication.shared.delegate as! AppDelegate
        )
        .persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        // Table view cell register
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }

    /// Setup view
    private func setupView() {
        view.backgroundColor = .white
        setupNavigationBar()
    }
    
    /// Setup navigation bar
    private func setupNavigationBar() {
        
        // Set title for navigation bar
        title = "Tasks list"
        
        // Title color
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        // Navigation bar color
        navigationController?.navigationBar.barTintColor = UIColor(
            displayP3Red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        // Set large title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(title: "New Task", message: "What do you want to do?")
    }

}

// MARK: - UITableViewDataSource
extension ViewController {
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
        ) -> Int {
        
        return tasks.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID,
                                                 for: indexPath)
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController {
    
    // Edit task
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID,
                                                 for: indexPath)
        let task = tasks[indexPath.row]
        showAlert(title: "Edit task",
                  message: "Enter new value",
                  currentTask: task) { (newValue) in
                    
            cell.textLabel?.text = newValue
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // Delete task
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        let task = tasks[indexPath.row]
        
        if editingStyle == .delete {
            deleteTask(task, indexPath: indexPath)
        }
    }
}

// MARK: - Work with Data Base
extension ViewController {
    
    // Fetch data
    private func fetchData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest() // Запрос выборки по ключу Task
        
        do {
            tasks = try managedContext.fetch(fetchRequest) // Заполнение массива данными из базы
        } catch let error {
            print("Failed to fetch data", error)
        }
    }
    
    // Save data
    private func saveTask(_ taskName: String) {
        
        guard let entity = NSEntityDescription.entity(
            forEntityName: "Task",
            in: managedContext
            ) else { return } // Create entity
        
        let task = NSManagedObject(entity: entity,
                                   insertInto: managedContext) as! Task // Task instace
        task.name = taskName // New value for task name
        
        do {
            try managedContext.save()
            tasks.append(task)
            tableView.insertRows(
                at: [IndexPath(row: tasks.count - 1, section: 0)],
                with: .automatic
            )
        } catch let error {
            print("Failed to save task", error.localizedDescription)
        }
    }
    
    // Edit data
    private func editTask(_ task: Task, newName: String) {
        do {
            task.name = newName
            try managedContext.save()
        } catch let error {
            print("Failed to save task", error)
        }
    }
    
    // Delete data
    private func deleteTask(_ task: Task, indexPath: IndexPath) {
        
        managedContext.delete(task)
        
        do {
            try managedContext.save()
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error {
            print("Error: \(error)")
        }
    }

}

// MARK: - Setup Alert Controller
extension ViewController {
    
    private func showAlert(title: String,
                           message: String,
                           currentTask: Task? = nil,
                           completion: ((String) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        // Save action
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            
            guard let newValue = alert.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            
            // Edit current task or add new task
            currentTask != nil ? self.editTask(currentTask!, newName: newValue) : self.saveTask(newValue)
            if completion != nil { completion!(newValue) }
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        // Подставляем текущую задачу в текстовое поле при редактировании задачи
        if currentTask != nil {
            alert.textFields?.first?.text = currentTask?.name
        }
        
        present(alert, animated: true)
    }
}
