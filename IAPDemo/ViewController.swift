//
//  ViewController.swift
//  IAPDemo
//
//  Created by Can Khac Nguyen on 5/19/19.
//  Copyright © 2019 Can Khac Nguyen. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let cellIdentifier = "ProductCell"
    private var refreshControl: UIRefreshControl?
    var products: [SKProduct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigationBar()
        addRefreshControl()
        reload()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseNotification(_:)),
                                               name: .IAPHelperPurchaseNotification,
                                               object: nil)
    }
    
    func addRefreshControl() {
        refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        refreshControl?.tintColor = UIColor.blue
        refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)
        tableView.addSubview(refreshControl ?? UIRefreshControl())
    }

    func configNavigationBar() {
        let restoreButton = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(onRestoreButtonClicked))
        navigationItem.rightBarButtonItem = restoreButton;
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard
            let productID = notification.object as? String,
            let index = products.index(where: { product -> Bool in
                product.productIdentifier == productID
            })
            else { return }
        
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    
    // MARK: Action
    @objc func onRestoreButtonClicked() {
        IAPHelper.shared.restorePurchases()
    }
    
    @objc func reload() {
        products = []
        
        tableView.reloadData()
        
        IAPHelper.shared.requestProducts { [weak self] (success, products) in
            guard let self = self else { return }
            if success {
                self.products = products!
                
                self.tableView.reloadData()
            }
            
            self.refreshControl?.endRefreshing()
        }
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ProductTableViewCell else {
            return UITableViewCell()
        }
        cell.configCell(product: products[indexPath.row])
        return cell
    }
}
