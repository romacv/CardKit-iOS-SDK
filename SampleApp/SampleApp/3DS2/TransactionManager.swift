//
//  TransactionMeneger.swift
//  SampleApp3DS2
//
//  Created by Alex Korotkov on 12/14/20.
//

import UIKit
import ThreeDSSDK


public protocol TransactionManagerDelegate: AnyObject {
    func errorEventReceived()
}

protocol AddLogDelegate: AnyObject {
  func addLog(title: String, request: String, response: String, isReload: Bool) -> Void
}

public class TransactionManager: NSObject, ChallengeStatusReceiver {
  weak var delegateAddLog: AddLogDelegate?
  weak var delegate: TransactionManagerDelegate?

  static var sdkProgressDialog: ProgressDialog? = nil

  var pubKey: String = ""
  var directoryServerId: String = ""
  var rootCI: String = ""
  
  var _service: ThreeDS2Service? = nil
  var _sdkTransaction: Transaction?
  var _isSdkInitialized: Bool = false
  var _isChallengeTransaction : Bool? = false
  
  let _notificationCenter = NotificationCenter.default
  let HEADER_LABEL = "SECURE CHECKOUT"
  let _logo:String = ""
  let _uiConfig = UiCustomization()

  public func initializeSdk() {
    do {
      _initSdkOnce()
      self._sdkTransaction = try self._service?.createTransaction(directoryServerID: self.directoryServerId, messageVersion: nil, publicKeyBase64: pubKey, rootCertificateBase64: self.rootCI, logoBase64: _logo)

      TransactionManager.sdkProgressDialog = try self._sdkTransaction!.getProgressView()
    } catch _ {
      print("Error initializing SDK")
    }
  }

  func setUpUICustomization(isDarkMode: Bool) throws {
    let indigoColor = UIColor(red: 0.25, green: 0.32, blue: 0.71, alpha: 1.00)
    
    var toolbarColor: UIColor = indigoColor
    var textColor: UIColor = .white
    var buttonDone: UIColor = indigoColor
    var buttonResend: UIColor = indigoColor
    
    if #available(iOS 11.0, *) {
      toolbarColor = UIColor(named: "toolbarColor") ?? toolbarColor
      textColor = UIColor(named: "textColor") ?? textColor
      buttonDone = UIColor(named: "buttonDone") ?? buttonDone
      buttonResend = UIColor(named: "buttonResend") ?? buttonResend
    }
    
    let toolbarCustomization = ToolbarCustomization()
    try toolbarCustomization.setHeaderText(HEADER_LABEL)
    toolbarCustomization.setBackgroundColor(toolbarColor)
    toolbarCustomization.setTextColor(.white)
    
    let textBoxCustomization = TextBoxCustomization()
    try textBoxCustomization.setBorderWidth(1)
    textBoxCustomization.setBorderColor(.gray)
    textBoxCustomization.setTextColor(textColor)
    
    let buttonDoneCustomization = ButtonCustomization()
    buttonDoneCustomization.setBackgroundColor(buttonDone)
    buttonDoneCustomization.setTextColor(.white)
    
    let buttonCancelCustomization = ButtonCustomization()
    buttonCancelCustomization.setBackgroundColor(.clear)
    buttonCancelCustomization.setTextColor(.white)
    
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
      self._service = Ecom3DS2Service()

      try self._service!.initialize(configParameters: ConfigParameters(), locale: Locale.current.languageCode, uiCustomization: _uiConfig)

      self._isSdkInitialized = true
    } catch _ {
      print("Error initializing SDK")
    }
  }
  
  func getAuthRequestParameters() throws -> ThreeDSSDK.AuthenticationRequestParameters {
    let authRequestParams = try self._sdkTransaction!.getAuthenticationRequestParameters()
    
    return authRequestParams;
  }

  func handleResponse (responseObject: [String : String]){
    self._isChallengeTransaction = false

    let challengeParameters = ChallengeParameters()
    challengeParameters.setAcsSignedContent(responseObject["acsSignedContent"]!)
    challengeParameters.setAcsRefNumber(responseObject["acsReferenceNumber"]!)
    challengeParameters.setAcsTransactionID(responseObject["acsTransID"]!)
    challengeParameters.set3DSServerTransactionID(responseObject["threeDSServerTransID"]!)
    
    self._isChallengeTransaction = true

    _executeChallenge(delegate: self, challengeParameters: challengeParameters , timeout: 5)
  }

  private func _executeChallenge(delegate: ChallengeStatusReceiver ,challengeParameters: ChallengeParameters, timeout : Int32) {
    DispatchQueue.main.async(){
      do {
        try self._sdkTransaction?.doChallenge(challengeParameters: challengeParameters, challengeStatusReceiver: delegate, timeOut: Int(timeout))
      } catch {
        self.close()
        dump(error)
      }
    }
  }

  public func completed(completionEvent e: CompletionEvent) {
    API.finishOrder(params: ThreeDS2ViewController.requestParams) { (data, response) in
      let params = ThreeDS2ViewController.requestParams
      let body = [
        "threeDSServerTransId": params.threeDSServerTransId ?? "",
        "userName": params.userName ?? "",
        "password": params.password ?? "",
      ];
      
      self.delegateAddLog?.addLog(title: "Finish order", request: String(describing: Utils.jsonSerialization(data: body)), response: String(describing: Utils.jsonSerialization(data: response)), isReload: false)

      API.fetchOrderStatus(params: ThreeDS2ViewController.requestParams) {(data, response) in
        let params = ThreeDS2ViewController.requestParams
        let body = [
          "orderId": params.orderId ?? "",
          "userName": params.userName ?? "",
          "password": params.password ?? ""
        ];

        DispatchQueue.main.async {
          self.delegateAddLog?.addLog(title: "Fetch order status",
                                 request: String(describing: Utils.jsonSerialization(data: body)),
                                 response: String(describing: Utils.jsonSerialization(data: response)),
                                 isReload: true)
        }
      }
    }
  }

  public func close() {
    do {
      try _sdkTransaction?.close()
    } catch {
      
    }
  }
  
  private func _reloadTable() {
    self._notificationCenter.post(name: Notification.Name("_reloadTable"), object: nil)
  }
}

extension TransactionManager {
  public func cancelled() {
    self._reloadTable()
  }

  public func timedout() {
    delegate?.errorEventReceived()
    self._reloadTable()
  }

  public func protocolError(protocolErrorEvent e: ProtocolErrorEvent) {
    delegate?.errorEventReceived()
    self._reloadTable()
  }
  
  public func runtimeError(runtimeErrorEvent: RuntimeErrorEvent) {
    delegate?.errorEventReceived()
    self._reloadTable()
  }
}
