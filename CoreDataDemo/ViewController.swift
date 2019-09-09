//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 02/09/2019.
//  Copyright © 2019 Alexey Efimov. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UITableViewController {
    
    var tasks: [Task] = []

    private let cellID = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //filling DB
//        let firstTask = Task()
//        firstTask.name = "Купить пива"
//
//        let secondTask = Task()
//        secondTask.name = "Купить водки"
//
//        let thirdTask = Task()
//        thirdTask.name = "Купить селедки"
//
//        tasks.append(firstTask)
//        tasks.append(secondTask)
//        tasks.append(thirdTask)
//
//        DispatchQueue.main.async {
//            StorageManager.saveTask(task: firstTask)
//            StorageManager.saveTask(task: secondTask)
//            StorageManager.saveTask(task: thirdTask)
//        }
        
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
        
        let realm = try! Realm()
        let dataFromDB = realm.objects(Task.self)
        
        tasks = Array(dataFromDB)
        
    }
    
    // Save data
    private func saveTask(_ taskName: String) {
        
//
    }
    
    // Edit data
    private func editTask(_ task: Task, newName: String) {
//
    }
    
    // Delete data
    private func deleteTask(_ task: Task, indexPath: IndexPath) {

}

// MARK: - Setup Alert Controller
    
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
