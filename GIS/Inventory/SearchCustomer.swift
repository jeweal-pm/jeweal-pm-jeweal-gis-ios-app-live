//
//  SearchCustomer.swift
//  GIS
//
//  Created by Apple Hawkscode on 11/12/20.
//

import UIKit

class CustomerSearchItemCell: UITableViewCell {
    
    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class SearchCustomer: UIViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var mCustomerTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
               
        
        mCustomerTable.delegate = self
        mCustomerTable.dataSource = self
        mCustomerTable.reloadData()
       
    }
    

    @IBAction func mBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated:true)
    }
    // MARK: - Navigation

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerSearchItemCell") as? CustomerSearchItemCell {
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
        
    }

}
