//
//  AppDelegate.swift
//  CertificatePinSwift
//
//  Created by Anish Kumar on 11/14/18.
//  Copyright © 2018 Akamai. All rights reserved.
//

import UIKit

//Identifier for registartion update notification
let registrationUpdate = "registrationUpdate"

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate , VocServiceDelegate {
    
    var window: UIWindow?
    var akaService: AkaWebAccelerator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        do {
            try self.akaService =   VocServiceFactory.createAkaWebAccelerator(with: self, delegateQueue: OperationQueue.main, options: nil)
            
            if (self.akaService?.state == VOCServiceState.notRegistered) {
                // service needs registering
                print("SDK user not registered, starting registration flow")
                return true
            }
            
            // service already registered
            print("SDK user registered, starting normal flow")
            
            // example one-time event log
            self.akaService?.logEvent("APP_LAUNCHED")
            
            // example timed event log
            let eventName: String = "Sample Event"
            self.akaService?.startEvent(eventName)
            
            // perform actions to time between startEvent and stopEvent
            self.akaService?.stopEvent(eventName)
        } catch {
            print("Could not create service")
            return false
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func vocService(_ vocService: VocService, didBecomeNotRegistered info: [AnyHashable : Any]) {
        print("didBecomeNotRegistered \(vocService), \(info)")
        NotificationCenter.default.post(name: Notification.Name(registrationUpdate), object: nil)
    }
    
    func vocService(_ vocService: VocService, didFailToRegister error: Error) {
        print("didFailToRegister \(vocService), \(error)")
    }
    
    func vocService(_ vocService: VocService, didRegister info: [AnyHashable : Any]) {
        print("didRegister \(vocService), \(info)")
        NotificationCenter.default.post(name: Notification.Name(registrationUpdate), object: nil)
    }
    
    func vocService(_ vocService: VocService, didInitialize info: [AnyHashable : Any]) {
        print("didInitialize \(vocService), \(info)")
    }
    
    
    func vocService(_ vocService: VocService, didReceiveChallengeFor originalRequest: URLRequest, currentRequest: URLRequest, challenge: URLAuthenticationChallenge, modifiedTrust: SecTrust?, completion: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("didReceive challenge in MAP!!")
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                var secresult = SecTrustResultType.invalid
                let status = SecTrustEvaluate(serverTrust, &secresult)
                if (errSecSuccess == status) {
                    if let serverLeafCert = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        let serverLeafCertData = SecCertificateCopyData(serverLeafCert)
                        let data = CFDataGetBytePtr(serverLeafCertData);
                        let size = CFDataGetLength(serverLeafCertData);
                        let presentedCert = NSData(bytes: data, length: size)
                        let localCertPath = Bundle.main.path(forResource: "herokuapp.com", ofType: "cer")//define cert here!
                        if let localCertFile = localCertPath {
                            if let localCert = NSData(contentsOfFile: localCertFile) {
                                if presentedCert.isEqual(to: localCert as Data) {
                                    completion(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                                    print("Pinned cert OK!")
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
        print("Pinned cert check failed")
        // Pinning failed
        completion(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }
}
