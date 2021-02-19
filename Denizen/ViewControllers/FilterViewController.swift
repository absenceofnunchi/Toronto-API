//
//  FilterViewController.swift
//  Denizen
//
//  Created by J C on 2021-02-02.
//

import UIKit

class FilterViewController: UIViewController {
    // MARK: - Properties
    // topics, civic_issues, owner_division (Publisher), refresh_rate, formats (Format), dataset_category (Type), last_refreshed (order)

    weak var delegate: LeftViewDelegate?
    let defaults = UserDefaults.standard
    lazy var filters: [Filter] = {
        var data = [Filter]()
        
        for filter in FilterType.allCases {
            if let savedFilter = defaults.string(forKey: filter.rawValue) {
                data.append(Filter(title: filter, setting: NSLocalizedString(savedFilter, comment: "")))
            } else {
                data.append(Filter(title: filter, setting: NSLocalizedString("All", comment: "")))
            }
        }
        return data
    }()
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func loadView() {
        let v = UIView()
        v.backgroundColor = UIColor.secondarySystemGroupedBackground
        v.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view = v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Filters"
        self.navigationController?.presentationController?.delegate = self
        
        configureTableView()
        configureRightBarItems()
        configureLeftBarItem()
        setConstraints()
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
}

// MARK: - Configure table view

extension FilterViewController {
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.filterCell)
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - configureNavigationItem

extension FilterViewController {
    func configureLeftBarItem() {
        let applyButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 40)))
        applyButton.setTitle("Apply", for: .normal)
        applyButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        applyButton.backgroundColor = .black
        applyButton.clipsToBounds = true
        applyButton.layer.cornerRadius = 10
        applyButton.tag = 1
        
        let leftBarButton = UIBarButtonItem(customView: applyButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func configureRightBarItems() {
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector((buttonPressed)))
        rightBarButton.tag = 2
        
        let warningButton = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(buttonPressed(_:)))
        warningButton.tag = 3
        
        self.navigationItem.rightBarButtonItems = [rightBarButton, warningButton]
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        switch sender.tag {
            case 1:
                delegate?.didApplyFilter()
                dismiss(animated: true, completion: nil)
            case 2:
                for filter in FilterType.allCases {
                    defaults.removeObject(forKey: filter.rawValue)
                }
                
                filters.removeAll()
                for filter in FilterType.allCases {
                    filters.append(Filter(title: filter, setting: NSLocalizedString("All", comment: "")))
                }
                tableView.reloadData()
            case 3:
                let alertController = UIAlertController(title: "", message: "Filters are only applicable to Tags, Topics, and Civic Issues. Reset your filter settings to see the full result.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                
                self.present(alertController, animated: true, completion: nil)
            default:
                break
        }
    }
}

// MARK:- Table view datasource

extension FilterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.filterCell, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = filters[indexPath.section].setting
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filters[section].title.rawValue
    }
}

// MARK: - Table view delegate

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = filters[indexPath.section]
        let filterSettingsVC = FilterSettingsTableViewController()
        filterSettingsVC.data = selectedFilter
        filterSettingsVC.delegate = self
        self.navigationController?.pushViewController(filterSettingsVC, animated: true)
    }
}

// MARK: - Filter delgate

extension FilterViewController: FilterDelegate {
    func didSelectFilter(selectedFilter: Filter, setting: String) {
        for case let filter in filters where filter.title == selectedFilter.title {
            filter.setting = setting
            defaults.set(filter.setting, forKey: filter.title.rawValue)
            tableView.reloadData()
        }
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension FilterViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        delegate?.didApplyFilter()
    }
}
