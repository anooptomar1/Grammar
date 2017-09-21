//
//  AdMob.swift
//  TextScanner
//
//  Created by Jennifer Vilanda Hasler on 9/21/2560 BE.
//  Copyright © 2560 Jennifer Vilanda Hasler. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

var admobDelegate = AdMobDelegate()
var currentVc: UIViewController!

class AdMobDelegate: NSObject, GADInterstitialDelegate {
    
    var interstitialView: GADInterstitial!
    
    func createAd() -> GADInterstitial {
        interstitialView = GADInterstitial(adUnitID: "ca-app-pub-1323381872235473/3274141350")
        interstitialView.delegate = self
        let request = GADRequest()
        interstitialView.load(request)
        return interstitialView
    }
    
    func showAd() {
        if interstitialView != nil {
            if (interstitialView.isReady == true){
                interstitialView.present(fromRootViewController:currentVc)
            } else {
                print("ad wasn't ready")
                interstitialView = createAd()
            }
        } else {
            print("ad wasn't ready")
            interstitialView = createAd()
        }
    }
    
    func interstitialDidReceiveAd(ad: GADInterstitial!) {
        print("Ad Received")
        if ad.isReady {
            interstitialView.present(fromRootViewController: currentVc)
        }
    }
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        print("Did Dismiss Screen")
    }
    
    func interstitialWillDismissScreen(ad: GADInterstitial!) {
        print("Will Dismiss Screen")
    }
    
    func interstitialWillPresentScreen(ad: GADInterstitial!) {
        print("Will present screen")
    }
    
    func interstitialWillLeaveApplication(ad: GADInterstitial!) {
        print("Will leave application")
    }
    
    func interstitialDidFailToPresentScreen(ad: GADInterstitial!) {
        print("Failed to present screen")
    }
    
    func interstitial(ad: GADInterstitial!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("\(ad) did fail to receive ad with error \(error)")
    }
}
