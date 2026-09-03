//
//  SplashController.swift
//  GIS
//
//  Created by Apple Hawkscode on 16/10/20.
//

import UIKit

class SplashController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(mainController), userInfo: nil, repeats: false)
        
    }
    
    override func viewDidLayoutSubviews() {

        self.view.applyGradient(withColours: [#colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1), #colorLiteral(red: 0.9019607843, green: 0.937254902, blue: 0.9725490196, alpha: 1)], gradientOrientation: .vertical)

    }

    
    
    @objc
    func mainController(){
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "LoginController") as? LoginController {
            self.navigationController?.pushViewController(home, animated:false)
        }
    }
    
    


}

