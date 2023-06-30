    
import UIKit

class TodoListTableViewController: UITableViewController {
    
    var cellID = "todoItemCell"
    var filename = "jsonitems"
    let fileCache = FileCache()
    
    var filteredItems: [TodoItem] {
        return showDone ? fileCache.items : fileCache.items.filter { !$0.isDone }
    }
    
    var showDone = true {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Мои дела"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.sizeToFit()
        self.tableView.contentInsetAdjustmentBehavior = .never
        tableView = UITableView(frame: tableView.frame, style: .insetGrouped)
        
        tableView.register(TodoItemTableViewCell.self, forCellReuseIdentifier: cellID)
        
        let addNewItemCircleButton = UIButton()
        addNewItemCircleButton.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal), for: .normal)
        self.view.addSubview(addNewItemCircleButton)
        addNewItemCircleButton.translatesAutoresizingMaskIntoConstraints = false
        addNewItemCircleButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        addNewItemCircleButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor).isActive = true
        
        addNewItemCircleButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        addNewItemCircleButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        addNewItemCircleButton.layer.shadowOpacity = 1.0
        addNewItemCircleButton.layer.shadowRadius = 5.0
        addNewItemCircleButton.addTarget(self, action: #selector(addNewItem), for: .touchUpInside)
        
        fileCache.loadFromJSONFile(fileName: self.filename)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == filteredItems.count {
            let cell = UITableViewCell()
            var content = cell.defaultContentConfiguration()
            content.attributedText = NSAttributedString(string: "Новое", attributes: [.font:UIFont.systemFont(ofSize: 17), .foregroundColor:UIColor.lightGray])
            cell.contentConfiguration = content
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TodoItemTableViewCell
            
            var item = filteredItems[indexPath.row]
            cell.item = item
            
            cell.action = {
                item.isDone.toggle()
                self.fileCache.add(newItem: item)
                tableView.reloadData()
                self.fileCache.saveToJSONFile(fileName: self.filename)
            }
            cell.configure()
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == filteredItems.count || filteredItems[indexPath.row].isDone {
            return 56
        } else if filteredItems[indexPath.row].deadlineString != nil {
            return 66
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let done = fileCache.items.filter({ $0.isDone })
        label.text = "Выполнено - \(done.count)"
        label.textColor = .lightGray
        stackView.addArrangedSubview(label)
        
        let button = UIButton()
        let showHideString = showDone ? "Скрыть" : "Показать"
        
        button.setAttributedTitle(NSAttributedString(string: showHideString, attributes: [.font:UIFont.systemFont(ofSize: 15, weight: .bold), .foregroundColor:UIColor.systemBlue]), for: .normal)
        stackView.addArrangedSubview(button)
        
        button.addTarget(self, action: #selector(showHideButtonTapped), for: .touchUpInside)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == filteredItems.count {
            self.addNewItem()
        } else {
            self.showTodoListDetailsTableView(indexPath: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let markAsDoneAction = UIContextualAction(style: .normal, title: "") { _, _, completion in
            var item = self.filteredItems[indexPath.row]
            item.isDone.toggle()
            self.fileCache.add(newItem: item)
            tableView.reloadData()
            self.fileCache.saveToJSONFile(fileName: self.filename)
            completion(true)
        }
        markAsDoneAction.backgroundColor = .systemGreen
        markAsDoneAction.image = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        return UISwipeActionsConfiguration(actions: [markAsDoneAction])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let infoAction = UIContextualAction(style: .normal, title: "") { _, _, completion in
            self.showTodoListDetailsTableView(indexPath: indexPath)
            completion(true)
        }
        infoAction.backgroundColor = .lightGray
        infoAction.image = UIImage(systemName: "info.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        let deleteItemAction = UIContextualAction(style: .normal, title: "") { _, _, completion in
            self.fileCache.delete(byID: self.filteredItems[indexPath.row].id)
            tableView.reloadData()
            self.fileCache.saveToJSONFile(fileName: self.filename)
            completion(true)
        }
        deleteItemAction.backgroundColor = .systemRed
        deleteItemAction.image = UIImage(systemName: "trash.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        return UISwipeActionsConfiguration(actions: [deleteItemAction, infoAction])
    }
    
    @objc func addNewItem() {
        let todoDetailsViewController = TodoDetailsTableViewController()
        let navigation = UINavigationController(rootViewController: todoDetailsViewController)
        let newItemIndexPath = IndexPath(row: filteredItems.count, section: 0)
        todoDetailsViewController.saveItemAction = { item in
            self.fileCache.add(newItem: item)
            self.tableView.insertRows(at: [newItemIndexPath], with: .automatic)
            self.fileCache.saveToJSONFile(fileName: self.filename)
        }
        
        present(navigation, animated: true)
    }
    
    @objc func showTodoListDetailsTableView(indexPath: IndexPath) {
        let todoDetailsViewController = TodoDetailsTableViewController()
        todoDetailsViewController.editedItem = self.filteredItems[indexPath.row]
        let navigation = UINavigationController(rootViewController: todoDetailsViewController)
        todoDetailsViewController.saveItemAction = { item in
            self.fileCache.add(newItem: item)
            self.tableView.reloadData()
            self.fileCache.saveToJSONFile(fileName: self.filename)
        }
        
        todoDetailsViewController.deleteItemAction = { item in
            self.fileCache.delete(byID: item.id)
            self.tableView.reloadData()
            self.fileCache.saveToJSONFile(fileName: self.filename)
        }
        present(navigation, animated: true)
    }
    
    @objc func showHideButtonTapped() {
        showDone.toggle()
        tableView.reloadData()
    }
}

