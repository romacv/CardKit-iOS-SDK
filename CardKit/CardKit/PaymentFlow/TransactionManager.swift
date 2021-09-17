//
//  CardKPaymentFlowController.swift
//  CardKit
//
//  Created by Alex Korotkov on 4/7/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//


import UIKit
import ThreeDSSDK

@objc public protocol TransactionManagerDelegate {
  func errorEventReceived(message: NSString)
  func didCancel()
  func didComplete(transactionStatus: NSString)
}

@objc public class TransactionManager: NSObject, ChallengeStatusReceiver {
  @objc public weak var delegate: TransactionManagerDelegate?
  static var sdkProgressDialog: ProgressDialog? = nil

  @objc public var pubKey: String = ""
  @objc public var headerLabel: String = ""
  @objc public var rootCertificate: String = ""
  
  var _service: ThreeDS2Service? = nil
  var _sdkTransaction: Transaction?
  var _isSdkInitialized: Bool = false
  var _isChallengeTransaction : Bool? = false
  
  let _notificationCenter = NotificationCenter.default
  let _logo:String = ""
  let _uiConfig = UiCustomization()
  
  
  @objc public func initializeSdk() {
    do {
      _initSdkOnce()
      self._sdkTransaction = try self._service?.createTransaction(directoryServerID: "directoryServerId", messageVersion: nil, publicKeyBase64: pubKey, rootCertificateBase64: rootCertificate, logoBase64: _logo)

      TransactionManager.sdkProgressDialog = try self._sdkTransaction!.getProgressView()
    } catch _ {
      
    }
  }
  
  @objc public func setUpUICustomization(primaryColor: UIColor, textDoneButtonColor: UIColor) throws {
    let toolbarCustomization = ToolbarCustomization()
    try toolbarCustomization.setHeaderText(headerLabel)
    
    let buttonDoneCustomization = ButtonCustomization()
    buttonDoneCustomization.setBackgroundColor(primaryColor)
    buttonDoneCustomization.setTextColor(textDoneButtonColor)
    
    let buttonCancelCustomization = ButtonCustomization()
    buttonCancelCustomization.setBackgroundColor(.clear)
    buttonCancelCustomization.setTextColor(primaryColor)

    _uiConfig.setToolbarCustomization(toolbarCustomization)
    try _uiConfig.setButtonCustomization(buttonDoneCustomization, .submit)
    try _uiConfig.setButtonCustomization(buttonCancelCustomization, .cancel)
    try _uiConfig.setButtonCustomization(buttonDoneCustomization, .next)
  }

  private func _initSdkOnce() {
    do {
        let p = ConfigParameters()
        try p.addParam(nil, ConfigParameters.Key.integrityReferenceValue.rawValue, "abc")
        let config = p
        
        self._service = Ecom3DS2Service()
        
        let locale = "en"
      
        try self._service!.initialize(configParameters: config, locale: locale, uiCustomization: _uiConfig)
        self._isSdkInitialized = true
    } catch _ {
      
    }
  }
    
  @objc public func getAuthRequestParameters() -> [NSString: Any]? {
    do {
      let authRequestParams = try self._sdkTransaction?.getAuthenticationRequestParameters()
    
      return [
        "threeDSSDKEncData": authRequestParams?.getDeviceData() ?? "",
        "threeDSSDKEphemPubKey": authRequestParams?.getSDKEphemeralPublicKey() ?? "",
        "threeDSSDKAppId": authRequestParams?.getSDKAppID() ?? "",
        "threeDSSDKTransId": authRequestParams?.getSDKTransactionID() ?? ""
      ];
    } catch  {
      return nil;
    }
  }

  @objc public func handleResponse (aRes: ARes) {
    let challengeParameters = ChallengeParameters()
    challengeParameters.setAcsSignedContent(aRes.acsSignedContent)
    challengeParameters.setAcsRefNumber(aRes.acsReferenceNumber)
    challengeParameters.setAcsTransactionID(aRes.acsTransID)
    challengeParameters.set3DSServerTransactionID(aRes.threeDSServerTransID)
  
    _executeChallenge(delegate: self, challengeParameters: challengeParameters , timeout: 5)
  }

  private func _executeChallenge(delegate: ChallengeStatusReceiver ,challengeParameters: ChallengeParameters, timeout : Int32) {
    DispatchQueue.main.async(){
      do {
        try self._sdkTransaction?.doChallenge(challengeParameters: challengeParameters, challengeStatusReceiver: delegate, timeOut: Int(timeout))
      } catch {
        self.delegate?.errorEventReceived(message: error.localizedDescription as NSString)
      }
    }
  }

  @objc public func showProgressDialog() {
    TransactionManager.sdkProgressDialog?.show();
  }
  
  @objc public func closeProgressDialog() {
    TransactionManager.sdkProgressDialog?.close();
  }
}

extension TransactionManager {
  public func completed(completionEvent e: CompletionEvent) {
    let transactionStatus: NSString = e.getTransactionStatus() as NSString
    
    delegate?.didComplete(transactionStatus: transactionStatus)
  }
  
  public func cancelled() {
    delegate?.didCancel()
  }

  public func timedout() {
    delegate?.errorEventReceived(message: "Timedout error")
  }

  public func protocolError(protocolErrorEvent e: ProtocolErrorEvent) {
    delegate?.errorEventReceived(message: e.getErrorMessage().getErrorDescription() as NSString)
  }
  
  public func runtimeError(runtimeErrorEvent: RuntimeErrorEvent) {
    delegate?.errorEventReceived(message: runtimeErrorEvent.errorMessage as NSString)
  }
}
