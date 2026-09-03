//
//  BiometricIDAuth.swift
//  GIS
//
//  Created by Macbook Pro on 04/11/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import LocalAuthentication

enum BiometricType{
    case none
    case faceID
    case touchID
    case unknown
}

enum BiometricError: LocalizedError {
    case authenticationFailed
    case userCancel
    case userFallback
    case biometryNotAvailable
    case biometryNotEnrolled
    case biometryLockout
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "There was a problem verifying your identity."
        case .userCancel:
            return "You pressed cancel."
        case .userFallback:
            return "You pressed password."
        case .biometryNotAvailable:
            return "Face ID is not available."
        case .biometryNotEnrolled:
            return "Face ID is not set up."
        case .biometryLockout:
            return "Face ID is locked."
        case .unknown:
            return "Face ID may not be configured."
        }
    }
    
}

class BiometricIdAuth{
    private let context = LAContext()
    private let policy: LAPolicy
    private let localizedReason: String
    
    private var error: NSError?
    
    init(policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics,
         localizedReason: String = "Verify your Identity",
         localizedFallbackTitle: String = "Enter App Password",
         localizedCancelTitle: String = "Cancel") {
        self.policy = policy
        self.localizedReason = localizedReason
        context.localizedFallbackTitle = localizedFallbackTitle
        context.localizedCancelTitle = localizedCancelTitle
    }
 
    private func biometricType(for type: LABiometryType) -> BiometricType {
        switch type {
        case .none:
            return .none
        case .faceID:
            return .faceID
        case .touchID:
            return .none
        case .opticID:
            return .none
        @unknown default:
            return .unknown
        }
    }
    
    private func biometricError(from nsError: NSError) -> BiometricError {
        let error: BiometricError
        
        switch nsError {
            case LAError.authenticationFailed:
                error = .authenticationFailed
            case LAError.userCancel:
                error = .userCancel
            case LAError.userFallback:
                error = .userFallback
            case LAError.biometryNotAvailable:
                error = .biometryNotAvailable
            case LAError.biometryNotEnrolled:
                error = .biometryNotEnrolled
            case LAError.biometryLockout:
                error = .biometryLockout
            default:
                error = .unknown
        }
        
        return error
    }
    
    func canEvaluate(completion: (Bool, BiometricType, BiometricError?) -> Void){
        
        guard context.canEvaluatePolicy(policy , error: &error) else {
            let type = biometricType(for: context.biometryType)
            
            guard let error = error else {
                return completion(false, type, nil)
            }
            
            return completion(false, type, biometricError(from: error))
        }
        
        if context.biometryType == .faceID {
            completion(true, .faceID, nil)
        } else {
            // Face ID is not available, so return an error.
            completion(false, .unknown, .biometryNotAvailable)
        }
    }
    
    func evaluate(completion: @escaping (Bool, BiometricError?) -> Void) {
        if context.biometryType == .faceID {
            context.evaluatePolicy(policy, localizedReason: localizedReason) { [weak self] success, error in
                
                DispatchQueue.main.async {
                    if success {
                        completion(true, nil)
                    } else {
                        guard let error = error else { return completion(false, nil) }
                        
                        completion(false, self?.biometricError(from: error as NSError))
                    }
                }
            }
        }else {
            // Face ID is not available, so return an error.
            completion(false, .biometryNotAvailable)
        }
    }
    
}
