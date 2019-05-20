//
//  ProductTableViewCell.swift
//  IAPDemo
//
//  Created by Can Khac Nguyen on 5/19/19.
//  Copyright © 2019 Can Khac Nguyen. All rights reserved.
//

import UIKit
import StoreKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    var product: SKProduct?
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    func configCell(product: SKProduct) {
        self.product = product
        productTitleLabel?.text = product.localizedTitle
        
        if IAPHelper.shared.isProductPurchased(product.productIdentifier) {
            accessoryType = .checkmark
            accessoryView = nil
            detailTextLabel?.text = ""
        } else if IAPHelper.canMakePayments() {
            ProductTableViewCell.priceFormatter.locale = product.priceLocale
            productPriceLabel?.text = ProductTableViewCell.priceFormatter.string(from: product.price)
            
            accessoryType = .none
            accessoryView = nil
        } else {
            productPriceLabel?.text = "Not available"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        productTitleLabel.text = nil
        productPriceLabel.text = nil
        accessoryView = nil
    }

    @IBAction func onBuyButtonClicked(_ sender: Any) {
        guard let product = product else { return }
        IAPHelper.shared.buyProduct(product)
    }
}
