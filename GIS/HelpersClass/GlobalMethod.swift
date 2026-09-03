//
//  GlobalMethod.swift
//  NavhooDriver
//
//  Created by apple on 3/3/20.
//  Copyright © 2020 Hawkscode. All rights reserved.
//

import Alamofire
import UIKit
 
class GlobalMethod: NSObject {

    static let objGlobalMethod = GlobalMethod()

    func ServiceMethod(url:String, method:String, controller:UIViewController, parameters:Parameters, completion: @escaping (_ result: AFDataResponse<Any>) -> Void) {

           
          
           
        }
    
    
    
}



class LeftSide: UIView {
    
    override func draw(_ rect: CGRect) {
        
        guard  let context =  UIGraphicsGetCurrentContext() else {
            return
        }
        context.setStrokeColor(UIColor.yellow.cgColor)
        context.setLineWidth(2)
        context.stroke(rect.insetBy(dx: 10, dy: 10))
        
        
    }
    
    
    
}
