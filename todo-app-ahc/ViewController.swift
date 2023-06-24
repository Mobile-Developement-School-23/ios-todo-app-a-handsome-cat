
import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FileCache.shared.loadFromJSONFile(fileName: "jsonitems")
        
        view.backgroundColor = .yellow

        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tap me!", for: .normal)
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(showTodoListDetailsTableView), for: .touchUpInside)
        view.addSubview(button)
        button.backgroundColor = .red
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func showTodoListDetailsTableView() {
        let todoDetailsViewController = TodoDetailsTableViewController()
        todoDetailsViewController.editedItem = FileCache.shared.items.first
        let navigation = UINavigationController(rootViewController: todoDetailsViewController)
        present(navigation, animated: true)
    }
    
}

