//
//  Api.swift
//  CertificatePinSwift
//  Created by Anish Kumar on 11/14/18.
//  Copyright © 2018 Akamai. All rights reserved.
//
import Foundation

class Api: NSObject, URLSessionDelegate {
    
    static var isSSLPinningEnabled = false
    
    func authenticate(userId: String, password: String, callback: @escaping (_ output: String, _ hasError: Bool) -> Void) {
        
        let configuration = URLSessionConfiguration.default
        VocServiceFactory.setupSessionConfiguration(configuration)
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue:OperationQueue.main)
        
        
        var request = URLRequest(url: URL(string: "https://floating-stream-25740.herokuapp.com/authentication/login")!)
        request.httpMethod = "POST"
        let postString = "id=\(userId)&password=\(password)"
        request.httpBody = postString.data(using: .utf8)
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                
                callback(error?.localizedDescription ?? "", true)
                print(error?.localizedDescription ?? "")
                
                return
            }
            
            let responseString = String(data: data, encoding: .utf8) ?? ""
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                callback(responseString, true)
                print(responseString)
            } else {
                callback(responseString, false)
            }
        }
        task.resume()
    }
    
//    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//
//        let serverTrust = challenge.protectionSpace.serverTrust
//        let certificate = SecTrustGetCertificateAtIndex(serverTrust!, 0)
//
//        if !Api.isSSLPinningEnabled {
//            let credential:URLCredential = URLCredential(trust: serverTrust!)
//            completionHandler(.useCredential, credential)
//        } else {
//            // Set SSL policies for domain name check
//            let policies = NSMutableArray();
//            policies.add(SecPolicyCreateSSL(true, (challenge.protectionSpace.host as CFString)))
//            SecTrustSetPolicies(serverTrust!, policies);
//
//            // Evaluate server certificate
//            var result: SecTrustResultType = SecTrustResultType(rawValue: 0)!
//            SecTrustEvaluate(serverTrust!, &result)
//            let isServerTrusted:Bool = result == SecTrustResultType.unspecified || result ==  SecTrustResultType.proceed
//
//            // Get local and remote cert data
//            let remoteCertificateData:NSData = SecCertificateCopyData(certificate!)
//            let pathToCert = Bundle.main.path(forResource: "herokuapp.com", ofType: "cer")
//            let localCertificate:NSData = NSData(contentsOfFile: pathToCert!)!
//
//            if (isServerTrusted && remoteCertificateData.isEqual(to: localCertificate as Data)) {
//                let credential:URLCredential = URLCredential(trust: serverTrust!)
//                completionHandler(.useCredential, credential)
//            } else {
//                completionHandler(.cancelAuthenticationChallenge, nil)
//            }
//        }
//    }
//
//    
//    @objc(vocService:didReceiveChallengeForRequest:currentRequest:challenge:modifiedTrust:completion:) func vocService(_ vocService: VocService, didReceiveChallengeFor originalRequest: URLRequest, currentRequest: URLRequest, challenge: URLAuthenticationChallenge, modifiedTrust: SecTrust?, completion: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        print("didReceive challenge in MAP!!")
//        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
//            if let serverTrust = challenge.protectionSpace.serverTrust {
//                var secresult = SecTrustResultType.invalid
//                let status = SecTrustEvaluate(serverTrust, &secresult)
//                if (errSecSuccess == status) {
//                    if let serverLeafCert = SecTrustGetCertificateAtIndex(serverTrust, 0) {
//                        let serverLeafCertData = SecCertificateCopyData(serverLeafCert)
//                        let data = CFDataGetBytePtr(serverLeafCertData);
//                        let size = CFDataGetLength(serverLeafCertData);
//                        let presentedCert = NSData(bytes: data, length: size)
//                        let localCertPath = Bundle.main.path(forResource: "herokuapp.com", ofType: "cer")//define cert here!
//                        if let localCertFile = localCertPath {
//                            if let localCert = NSData(contentsOfFile: localCertFile) {
//                                if presentedCert.isEqual(to: localCert as Data) {
//                                    completion(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
//                                    print("Pinned cert OK!")
//                                    return
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        print("Pinned cert check failed")
//        // Pinning failed
//        completion(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
//    }
}
