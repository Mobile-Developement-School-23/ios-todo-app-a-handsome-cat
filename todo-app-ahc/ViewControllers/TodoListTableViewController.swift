import UIKit

class TodoListTableViewController: UITableViewController {

    var cellID = "todoItemCell"

    let itemsManager = TodoItemsManager()

    let activityIndicator = UIActivityIndicatorView(style: .medium)

    var filteredItems: [TodoItem] {
        return showDone ? itemsManager.items : itemsManager.items.filter { !$0.isDone }
    }

    var showDone: Bool {
        get {
            UserDefaults.standard.value(forKey: "showDone") as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "showDone")
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        itemsManager.updateTableView = { self.tableView.reloadData() }

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateActivityIndicator),
                                               name: Notification.Name("activeCountChanged"),
                                               object: nil)

        Task {
            itemsManager.getList()
            tableView.reloadData()
        }

        navigationItem.title = "Мои дела"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.sizeToFit()
        self.tableView.contentInsetAdjustmentBehavior = .never
        tableView = UITableView(frame: tableView.frame, style: .insetGrouped)

        tableView.register(TodoItemTableViewCell.self, forCellReuseIdentifier: cellID)

        let addNewItemCircleButton = AddNewItemCircleButton()
        self.view.addSubview(addNewItemCircleButton)
        addNewItemCircleButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            addNewItemCircleButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            addNewItemCircleButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor)
        ])

        addNewItemCircleButton.addTarget(self, action: #selector(addNewItem), for: .touchUpInside)
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
            content.attributedText = NSAttributedString(string: "Новое",
                                                        attributes: [.font: UIFont.systemFont(ofSize: 17),
                                                                     .foregroundColor: UIColor.lightGray])
            cell.contentConfiguration = content
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
                    as? TodoItemTableViewCell
            else { return UITableViewCell() }

            var item = filteredItems[indexPath.row]
            cell.item = item

            cell.action = {
                item.isDone.toggle()
                self.itemsManager.editItem(item)
                tableView.reloadData()
            }
            cell.configure()
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == filteredItems.count || filteredItems[indexPath.row].deadlineString == nil {
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

        let done = itemsManager.fileCache.items.filter({ $0.isDone })
        label.text = "Выполнено - \(done.count)"
        label.textColor = .lightGray
        stackView.addArrangedSubview(label)

        let button = UIButton()
        let showHideString = showDone ? "Скрыть" : "Показать"

        button.setAttributedTitle(NSAttributedString(string: showHideString,
                                                     attributes: [
                                                        .font: UIFont.systemFont(ofSize: 15, weight: .bold),
                                                        .foregroundColor: UIColor.systemBlue
                                                     ]), for: .normal)
        stackView.addArrangedSubview(button)

        button.addTarget(self, action: #selector(showHideButtonTapped), for: .touchUpInside)

        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == filteredItems.count {
            self.addNewItem()
        } else {
            self.showTodoListDetailsTableView(indexPath: indexPath)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func tableView(_ tableView: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let markAsDoneAction = UIContextualAction(style: .normal, title: "") { _, _, completion in
            var item = self.filteredItems[indexPath.row]
            item.isDone.toggle()
            self.itemsManager.editItem(item)
            tableView.reloadData()
            completion(true)
        }
        markAsDoneAction.backgroundColor = .systemGreen
        markAsDoneAction.image = UIImage(systemName: "checkmark.circle.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        return UISwipeActionsConfiguration(actions: [markAsDoneAction])
    }

    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let infoAction = UIContextualAction(style: .normal, title: "") { _, _, completion in
            self.showTodoListDetailsTableView(indexPath: indexPath)
            completion(true)
        }
        infoAction.backgroundColor = .lightGray
        infoAction.image = UIImage(systemName: "info.circle.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)

        let deleteItemAction = UIContextualAction(style: .normal, title: "") { _, _, completion in
            let item = self.filteredItems[indexPath.row]
            self.itemsManager.deleteItem(item)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        deleteItemAction.backgroundColor = .systemRed
        deleteItemAction.image = UIImage(systemName: "trash.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        return UISwipeActionsConfiguration(actions: [deleteItemAction, infoAction])
    }

    @objc func addNewItem() {
        let todoDetailsViewController = TodoDetailsTableViewController()
        let navigation = UINavigationController(rootViewController: todoDetailsViewController)
        let newItemIndexPath = IndexPath(row: filteredItems.count, section: 0)
        todoDetailsViewController.saveItemAction = { item in
            self.itemsManager.addItem(item)
            self.tableView.insertRows(at: [newItemIndexPath], with: .automatic)
        }
        present(navigation, animated: true)
    }

    @objc func showTodoListDetailsTableView(indexPath: IndexPath) {
        let todoDetailsViewController = TodoDetailsTableViewController()
        todoDetailsViewController.editedItem = self.filteredItems[indexPath.row]
        let navigation = UINavigationController(rootViewController: todoDetailsViewController)

        navigation.modalPresentationStyle = .custom
        navigation.transitioningDelegate = self

        todoDetailsViewController.saveItemAction = { item in
            self.itemsManager.editItem(item)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        todoDetailsViewController.deleteItemAction = { item in
            Task {
                self.itemsManager.deleteItem(item)
                self.tableView.reloadData()
            }
        }
        present(navigation, animated: true)
    }

    @objc func showHideButtonTapped() {
        showDone.toggle()
        tableView.reloadData()
    }

    @objc func updateActivityIndicator() {
        DispatchQueue.main.async {
            if self.itemsManager.networkService.active == 0 {
                self.activityIndicator.stopAnimating()
            } else {
                self.activityIndicator.startAnimating()
            }
        }
    }

    var cardView: UIViewController?

    func createCard(indexPath: IndexPath) -> UIViewController {
        let view = UIViewController()
        view.view.backgroundColor = .darkGray
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Пожалуйста, не трогайте меня!\nМне еще нужно успеть\n\(self.filteredItems[indexPath.row].text)"
        if let deadline = self.filteredItems[indexPath.row].deadlineString {
            label.text?.append("\nдо \(deadline)")
        }
        label.textColor = .systemRed
        view.view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.view.centerYAnchor).isActive = true
        return view
    }

    override func tableView(_ tableView: UITableView,
                            contextMenuConfigurationForRowAt indexPath: IndexPath,
                            point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            if indexPath.row == self.filteredItems.count {
                return TodoDetailsTableViewController()
            } else {
                self.cardView = self.createCard(indexPath: indexPath)
                return self.cardView
            }
        })
    }

    override func tableView(_ tableView: UITableView,
                            willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                            animator: UIContextMenuInteractionCommitAnimating) {
        guard let indexPath = configuration.identifier as? IndexPath else { return }
        let view = createCard(indexPath: indexPath)
        let renderer = UIGraphicsImageRenderer(size: view.view.bounds.size)
        let image = renderer.image { _ in
            view.view.drawHierarchy(in: view.view.bounds, afterScreenUpdates: true)
        }

        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = self.view
        self.cardView?.dismiss(animated: true)
        self.present(activityController, animated: true)
    }
}

extension TodoListTableViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return TransitioningAnimationController(frame: tableView.rectForRow(at: IndexPath(row: 0, section: 0)))
        }

        let controller = TransitioningAnimationController(frame: tableView.rectForRow(at: indexPath ))
        return controller
    }

}
