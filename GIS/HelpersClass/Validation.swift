

import UIKit

class Validation: NSObject
{
    class func isEnterCharacter(testString:String) -> Bool
    {
        let emailRegEx = "^[a-zA-Z ]*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testString)
    }
    
   class func isValidEmail(emailString:String) -> Bool
   {
        let emailRegEx = "^[a-zA-Z0-9..!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailString)
    }
    
   class func isPasswordValid(_ password : String) -> Bool{
    let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$")//(?=.*?[#?!@$%^&*-])")
        return passwordTest.evaluate(with: password)
    }
 
    class func isValidMobileNumber(testString:String) -> Bool
    {
        let teststring=testString.trimmingCharacters(in: NSCharacterSet.whitespaces)
        var newString = teststring
        newString = (newString.replacingOccurrences(of: "(", with: "") as NSString) as String
        newString = (newString.replacingOccurrences(of: ")", with: "") as NSString) as String
        newString = (newString.replacingOccurrences(of: "-", with: "") as NSString) as String
        newString = (newString.replacingOccurrences(of: " ", with: "") as NSString) as String

        if newString.count != 10
        {
            return false
        }
        
        let mobileRegex = "^([0-9]*)$"
        let mobileTemp = NSPredicate(format:"SELF MATCHES %@", mobileRegex)
        return mobileTemp.evaluate(with: newString)
    }
    
    class func isblank(testString : String) -> Bool
    {
        let trimstring = testString.trimmingCharacters(in: NSCharacterSet.whitespaces)
        return !trimstring.isEmpty
    }
}
