//
//  NoOfInstallments.swift
//  GIS
//
//  Created by Macbook Pro on 12/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit

class NoOfInstallments: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mTableView: UITableView!
    
    
    @IBOutlet weak var mHeadingLABEL: UILabel!
    var delegate:TotalInstallmentsDelegate? = nil
    var mMaxAmount = 30000.00
    var mNoOfInstallmentsArray = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mHeadingLABEL.text = "Installment".localizedString
        mView.layer.cornerRadius = 24
        mView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        for i in 2...30 {
            mNoOfInstallmentsArray.append(i)
        }
        self.view.backgroundColor = .clear

        mTableView.showsVerticalScrollIndicator = false
        mTableView.delegate = self
        mTableView.dataSource = self
        mTableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mNoOfInstallmentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InstallmentItems") as? InstallmentItems else {
            return UITableViewCell()
        }
        let mEquatedAmount = String(format:"%.02f",locale:Locale.current,(mMaxAmount/Double(mNoOfInstallmentsArray[indexPath.row])))
        cell.mInstallment.text = "x\(mNoOfInstallmentsArray[indexPath.row] )"
        cell.mAmount.text = (UserDefaults.standard.string(forKey: "currencySymbol") ?? "$") + " \(mEquatedAmount)"
        
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor(named: "themeBackground")
        }else{
            cell.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true)
        delegate?.mGetInstallment(installments: mNoOfInstallmentsArray[indexPath.row])
    }
}
