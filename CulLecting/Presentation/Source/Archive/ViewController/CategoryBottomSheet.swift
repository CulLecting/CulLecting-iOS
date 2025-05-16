//
//  CategoryBottomSheet.swift
//  CulLecting
//
//  Created by 김승희 on 5/7/25.
//


import UIKit


final class CategoryBottomSheet: UITableViewController {
    
    var onCategorySelected: ((String) -> Void)?
    
    private let categories = Category.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "카테고리 선택"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryBottomSheetCell")
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryBottomSheetCell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.rawValue
        cell.textLabel?.font = .systemFont(ofSize: 16)
        return cell
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        onCategorySelected?(category.rawValue)
        dismiss(animated: true)
    }
}
