//
//  FilterViewController.swift
//  Denizen
//
//  Created by J C on 2021-02-02.
//

import UIKit

class FilterViewController: UITableViewController {
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
    
    override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Filters"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.filterCell)
        self.navigationController?.presentationController?.delegate = self
        
        configureRightBarItem()
        configureLeftBarItem()
    }
}

// MARK: - configureNavigationItem

extension FilterViewController {
    func configureRightBarItem() {
        let applyButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 40)))
        applyButton.setTitle("Apply", for: .normal)
        applyButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        applyButton.backgroundColor = .black
        applyButton.clipsToBounds = true
        applyButton.layer.cornerRadius = 10
        applyButton.tag = 1
        
        let rightBarButton = UIBarButtonItem(customView: applyButton)
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func configureLeftBarItem() {
        let leftBarButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector((buttonPressed)))
        leftBarButton.tintColor = .black
        leftBarButton.tag = 2
        self.navigationItem.leftBarButtonItem = leftBarButton
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
            default:
                break
        }
    }
}

// MARK:- Table view datasource

extension FilterViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return filters.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.filterCell, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = filters[indexPath.section].setting
                
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filters[section].title.rawValue
    }
}

// MARK: - Table view delegate

extension FilterViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
