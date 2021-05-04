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
  func errorEventReceived()
  func didCancel()
  func didComplete(transactionStatus: NSString)
}

@objc public class TransactionManager: NSObject, ChallengeStatusReceiver {
    @objc public weak var delegate: TransactionManagerDelegate?
    static var sdkProgressDialog: ProgressDialog? = nil

    @objc public var pubKey: String = ""
    var _service: ThreeDS2Service? = nil
    var _sdkTransaction: Transaction?
    var _isSdkInitialized: Bool = false
    var _isChallengeTransaction : Bool? = false
    
    let _notificationCenter = NotificationCenter.default
    let HEADER_LABEL = "SECURE CHECKOUT"
    let _logo:String = ""
    let _uiConfig = UiCustomization()
    let _rootKey: String = """
        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
    """
  
    @objc public func initializeSdk() {
      do {
        _initSdkOnce()
        self._sdkTransaction = try self._service?.createTransaction(directoryServerID: "directoryServerId", messageVersion: nil, publicKeyBase64: pubKey, rootCertificateBase64: _rootKey, logoBase64: _logo)

        TransactionManager.sdkProgressDialog = try self._sdkTransaction!.getProgressView()
      } catch _ {
        
      }
    }
  
  @objc public func setUpUICustomization(isDarkMode: Bool, primaryColor: UIColor, secondaryColor: UIColor, buttonTextColor: UIColor, textColor: UIColor) throws {
      let indigoColor = UIColor(red: 0.25, green: 0.32, blue: 0.71, alpha: 1.00)
      
      var toolbarColor: UIColor = primaryColor
      var textColor: UIColor = textColor
      var buttonDone: UIColor = secondaryColor
      var buttonResend: UIColor = toolbarColor
      
      if #available(iOS 11.0, *) {
        toolbarColor = UIColor(named: "toolbarColor") ?? toolbarColor
        textColor = UIColor(named: "textColor") ?? textColor
        buttonDone = UIColor(named: "buttonDone") ?? buttonDone
        buttonResend = UIColor(named: "buttonResend") ?? buttonResend
      }
      
      let toolbarCustomization = ToolbarCustomization()
      try toolbarCustomization.setHeaderText(HEADER_LABEL)
      toolbarCustomization.setBackgroundColor(toolbarColor)
      toolbarCustomization.setTextColor(buttonTextColor)
      
      let textBoxCustomization = TextBoxCustomization()
      try textBoxCustomization.setBorderWidth(1)
      textBoxCustomization.setBorderColor(.gray)
      textBoxCustomization.setTextColor(textColor)
      
      let buttonDoneCustomization = ButtonCustomization()
      buttonDoneCustomization.setBackgroundColor(buttonDone)
      buttonDoneCustomization.setTextColor(buttonTextColor)
      
      let buttonCancelCustomization = ButtonCustomization()
      buttonCancelCustomization.setBackgroundColor(.clear)
      buttonCancelCustomization.setTextColor(buttonTextColor)
      
      let buttonResendCustomization = ButtonCustomization()
      buttonResendCustomization.setBackgroundColor(.clear)
      buttonResendCustomization.setTextColor(buttonResend)
      
      let titleCustomization = LabelCustomization()
      titleCustomization.setTextColor(textColor)
      titleCustomization.setHeadingTextColor(textColor)

      _uiConfig.setToolbarCustomization(toolbarCustomization)
      _uiConfig.setTextBoxCustomization(textBoxCustomization)
      _uiConfig.setLabelCustomization(titleCustomization)
      try _uiConfig.setButtonCustomization(buttonDoneCustomization, .submit)
      try _uiConfig.setButtonCustomization(buttonCancelCustomization, .cancel)
      try _uiConfig.setButtonCustomization(buttonResendCustomization, .resend)
    }

    private func _initSdkOnce(){
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

    @objc public func handleResponse (responseObject: NSObject){
      self._isChallengeTransaction = false
      let aRes = responseObject as! ARes
      
      let challengeParameters = _createChallengeParameters(aRes: aRes)
      self._isChallengeTransaction = true
      let timeout : Int32 =  5
      _executeChallenge(delegate: self, challengeParameters: challengeParameters , timeout: timeout)
    }

    private func _createChallengeParameters(aRes: ARes) -> ChallengeParameters{
      let challengeParameters = ChallengeParameters()
      challengeParameters.setAcsSignedContent(aRes.acsSignedContent)
      challengeParameters.setAcsRefNumber(aRes.acsReferenceNumber)
      challengeParameters.setAcsTransactionID(aRes.acsTransID)
      challengeParameters.set3DSServerTransactionID(aRes.threeDSServerTransID)

      return challengeParameters
    }

    private func _executeChallenge(delegate: ChallengeStatusReceiver ,challengeParameters: ChallengeParameters, timeout : Int32) {
      DispatchQueue.main.async(){
        do {
            
            try self._sdkTransaction?.doChallenge(challengeParameters: challengeParameters, challengeStatusReceiver: delegate, timeOut: Int(timeout))
        } catch {
            dump(error)
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
    delegate?.errorEventReceived()
  }

  public func protocolError(protocolErrorEvent e: ProtocolErrorEvent) {
    delegate?.errorEventReceived()
  }
  
  public func runtimeError(runtimeErrorEvent: RuntimeErrorEvent) {
    delegate?.errorEventReceived()
  }
}
