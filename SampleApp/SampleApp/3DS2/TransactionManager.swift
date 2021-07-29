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
  
    public func initializeSdk() {
      do {
        _initSdkOnce()
        self._sdkTransaction = try self._service?.createTransaction(directoryServerID: "directoryServerId", messageVersion: nil, publicKeyBase64: pubKey, rootCertificateBase64: _rootKey, logoBase64: _logo)

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
