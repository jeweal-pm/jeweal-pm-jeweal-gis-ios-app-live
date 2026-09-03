

import Foundation
import Alamofire




func HitServerUsingAlamofire(url:String, parameters:NSMutableDictionary, imageData:Data?=nil, imageDataArray:NSArray?=nil, completion:@escaping (_ isSuccess: Bool, _ response: NSDictionary) -> Void)
{

}

func HitServerUsingDefault(url:String, parameters:NSMutableDictionary, completion:@escaping (_ isSuccess: Bool, _ response: NSDictionary) -> Void)
{
 
    let fullURL = String(format: url)
    guard let serviceUrl = URL(string: fullURL) else { return }
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = "POST"
    request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
    guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {return}
    request.httpBody = httpBody
    request.timeoutInterval = 20
    let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
        
        DispatchQueue.main.async
        {
            CommonClass.stopLoader()
            if error != nil
            {
                completion(false,[:])
            }
            
            do {
                if let mData = data {
                    if let json = try JSONSerialization.jsonObject(with: mData, options: .mutableContainers) as? NSDictionary {
                        completion(true,json)
                    } else {
                        completion(false,[:])
                    }
                } else {
                    completion(false,[:])
                }
            } catch {
                completion(false,[:])
            }
        }
    }
    task.resume()
}


func mGetDeviceInfo() -> String {
    switch UIDevice.current.userInterfaceIdiom {
    case .pad:
        return "iPad"
    case .phone:
        return "iPhone"
    case .mac:
        return "mac"
    default:
        return ""
    }
}



func mGetData(url: String,headers: HTTPHeaders, params : [String:Any], completion: @escaping (_ response : NSDictionary , _ status:Bool) -> Void) {
    if Reachability.isConnectedToNetwork() == true {
        AF.request(url, method:.post, parameters: params ,encoding: JSONEncoding.default,headers: headers).responseJSON
        { response in
            
            print("========== DIRECT JSON TEST ==========")
                print("🔥 REQUEST =", response.request)
                print("🔥 HEADERS =", response.request?.allHTTPHeaderFields ?? [:])
            
            if let body = response.request?.httpBody,
                   let bodyString = String(data: body, encoding: .utf8) {
                    print("🔥 RAW HTTP BODY =", bodyString)
                }

                print("🔥 RESPONSE =", response.value ?? "")
                print("======================================")
            
            if(response.error != nil){
                
                completion(NSDictionary(),false)
            }else{
                guard let jsonData = response.data else{
                    completion(NSDictionary(),false)
                    CommonClass.showSnackBar(message: "OOPS, Something went wrong.")
                    return
                }
                let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                guard let jsonResult = json as? NSDictionary else{
                    completion(NSDictionary(),false)
                    CommonClass.showSnackBar(message: "OOPS, Something went wrong.")
                    return
                }
                completion(jsonResult, true)
            }
        }
    }else{
        completion(NSDictionary(),false)
        CommonClass.showSnackBar(message: "No Internet Connection!")
    }
}
func mGetDataGET(url: String, completion: @escaping (_ response : NSDictionary) -> Void) {
    mUserLoginToken = UserDefaults.standard.string(forKey: "token")
    mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
    
    AF.request(url, method:.get,headers: headers).responseJSON
    { response in
        
        if(response.error != nil){
            
        }else{
            guard let jsonData = response.data else{
                completion(NSDictionary())
                CommonClass.showSnackBar(message: "OOPS, Something went wrong.")
                return
            }
            let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
            guard let jsonResult = json as? NSDictionary else{
                completion(NSDictionary())
                CommonClass.showSnackBar(message: "OOPS, Something went wrong.")
                return
            }
            completion(jsonResult)
        }
    }
    
}

func mMultipartUpload(url: String, params : [String:Any], image: UIImage , completion: @escaping (_ response : NSDictionary) -> Void) {
    
    mUserLoginToken = UserDefaults.standard.string(forKey: "token")
    mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
    
    AF.upload (
        multipartFormData: { multipartFormData in
            
            
            
            
            for (key, value) in params {
                if let temp = value as? String, let mdata = temp.data(using: .utf8) {
                    multipartFormData.append(mdata, withName: key)
                }
                if let temp = value as? Int, let mdata = "(temp)".data(using: .utf8) {
                    multipartFormData.append(mdata, withName: key)
                }
                if let temp = value as? NSArray {
                    temp.forEach({ element in
                        let keyObj = key + "[]"
                        if let string = element as? String, let mdata = string.data(using: .utf8) {
                            multipartFormData.append(mdata, withName: keyObj)
                        } else
                        if let num = element as? Int, let mdata = "\(num)".data(using: .utf8) {
                            multipartFormData.append(mdata, withName: keyObj)
                        }
                    })
                }
            }
            
            if let imageV = image.jpegData(compressionQuality: 1) {
                multipartFormData.append(imageV, withName: "userimage" , fileName: "file.jpeg", mimeType: "image/jpeg/jpg/png")
            }
        },
        to: url, method: .post, headers: nil ).responseJSON{
            response in
            
            if(response.error != nil){
                
            }else{
                guard let jsonData = response.data else{
                    completion(NSDictionary())
                    CommonClass.showSnackBar(message: "OOPS, Something went wrong.")
                    return
                }
                let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                guard let jsonResult = json as? NSDictionary else{
                    completion(NSDictionary())
                    CommonClass.showSnackBar(message: "OOPS, Something went wrong.")
                    return
                }
                completion(jsonResult)
            }
            
            
            
        }
}
