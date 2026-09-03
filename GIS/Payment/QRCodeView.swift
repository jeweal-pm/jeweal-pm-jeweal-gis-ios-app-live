//
//  QRCodeView.swift
//  GIS
//
//  Created by Mayank Sharma on 23/12/24.
//  Copyright © 2024 Hawkscode. All rights reserved.
//

import Foundation
import UIKit

protocol QRCodeViewDelegate: AnyObject {
    func didTapCancelQRCode()
}

class QRCodeView: UIView {
    
    
    var countdownTimer: Timer?
    var totalTime: Int = 120
    
    weak var delegate: QRCodeViewDelegate?
    
    override func awakeFromNib() {
         super.awakeFromNib()
         startTimer()
     }

     deinit {
         invalidateTimer()
     }

    
    
    @IBOutlet weak var mQRTime: UILabel!
    
    @IBOutlet weak var mQRImage: UIImageView!
    @IBOutlet weak var mCancelQRCode: UIButton!
    @IBAction func mCancelQRCodeButton(_ sender: Any) {
        
        // Notify the delegate when the cancel button is clicked
        delegate?.didTapCancelQRCode()
        invalidateTimer()
        self.removeFromSuperview()
    }
    
    func startTimer() {
          // Reset totalTime to the full 120 seconds when the timer starts
          totalTime = 120
          invalidateTimer() // Stop any existing timer before starting a new one
          updateTimerLabel() // Update the label initially
          countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
              self?.updateCountdown()
          }
      }

      private func invalidateTimer() {
          countdownTimer?.invalidate() // Invalidate the existing timer
          countdownTimer = nil
      }

      private func updateCountdown() {
          if totalTime > 0 {
              totalTime -= 1
              updateTimerLabel() // Update the label with the remaining time
          } else {
              timerExpired() // When the time runs out
          }
      }

      private func updateTimerLabel() {
          let minutes = totalTime / 60
          let seconds = totalTime % 60
          mQRTime.text = "Remaining Time: \(String(format: "%02d:%02d", minutes, seconds))"
      }

      private func timerExpired() {
          // Notify delegate when the timer expires
          delegate?.didTapCancelQRCode()
          invalidateTimer() // Invalidate the timer
          self.removeFromSuperview() // Remove the view when time expires
      }
    
 

   }

extension QRCodeView {
    static func loadFromNib() -> QRCodeView {
        let nib = UINib(nibName: "QRCodeView", bundle: nil)
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? QRCodeView else {
            fatalError("Could not load QRCodeView from nib")
        }
        return view
    }
}
