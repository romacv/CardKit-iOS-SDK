//
//  SampleCardKPaymentView.swift
//  SampleApp
//
//  Created by Alex Korotkov on 5/28/20.
//  Copyright © 2020 AnjLab. All rights reserved.
//

import UIKit
import CardKit

class ThreeDS2ViewController: UITableViewController, AddLogDelegate, UITextFieldDelegate {
  static var logs: NSMutableArray = NSMutableArray()
  static var requestParams: RequestParams = RequestParams();
  
  var isUseCustomTheme: Bool = false
  var _aRes = ["threeDSServerTransID": "", "acsTransID": "", "acsReferenceNumber": "", "acsSignedContent": ""]
  
  let _notificationCenter = NotificationCenter.default
  let _headerView = UIView()
  let _textFieldBaseUrl = TextField3DS2Example()
  let _textFieldCost = TextField3DS2Example()
  let _textFieldUserName = TextField3DS2Example()
  let _textFieldPassword = TextField3DS2Example()
  let _textFieldRootCI = TextField3DS2Example()
  let _textFieldDirectoryServerId = TextField3DS2Example()

  let _transactionManager: TransactionManager = TransactionManager()
  let _reqResController = ReqResDetailsController()
  
  func initialize(isUseCustomTheme: Bool) {
    self.isUseCustomTheme = isUseCustomTheme
  }

  func addLog(title: String, request: String, response: String, isReload: Bool = false) {
    ThreeDS2ViewController.logs.add(["title": title, "response": response, "request": request])
    
    if isReload {
      self.tableView.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let request: URLRequest = URLRequest(url: URL(string: "https://dummy3dsdev.intabia.ru/acs2/secret/cert")!)
    
    URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
      guard let data = data else { return }

      DispatchQueue.main.async {
        self._textFieldRootCI.text = String(data: data, encoding: .utf8) ?? ""
      }
    }).resume()
    
    ThreeDS2ViewController.logs.removeAllObjects()
    if #available(iOS 13.0, *) {
      CardKConfig.shared.theme = CardKTheme.system()
    } else {
      CardKConfig.shared.theme = CardKTheme.light()
    };
    CardKConfig.shared.language = "";
    CardKConfig.shared.bindingCVCRequired = true;
    CardKConfig.shared.bindings = [];
    CardKConfig.shared.isTestMod = true;
    CardKConfig.shared.mdOrder = "mdOrder";
    CardKConfig.shared.mrBinApiURL = "https://mrbin.io/bins/display";
    CardKConfig.shared.mrBinURL = "https://mrbin.io/bins/";
    CardKConfig.shared.pubKey = """
        -----BEGIN PUBLIC KEY-----
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAws0r6I8emCsURXfuQcU2c9mwUlOiDjuCZ/f+EdadA4vq/kYt3w6kC5TUW97Fm/HTikkHd0bt8wJvOzz3T0O4so+vBaC0xjE8JuU1eCd+zUX/plw1REVVii1RNh9gMWW1fRNu6KDNSZyfftY2BTcP1dbE1itpXMGUPW+TOk3U9WP4vf7pL/xIHxCsHzb0zgmwShm3D46w7dPW+HO3PEHakSWV9bInkchOvh/vJBiRw6iadAjtNJ4+EkgNjHwZJDuo/0bQV+r9jeOe+O1aXLYK/s1UjRs5T4uGeIzmdLUKnu4eTOQ16P6BHWAjyqPnXliYIKfi+FjZxyWEAlYUq+CRqQIDAQAB-----END PUBLIC KEY-----
    """

    _transactionManager.delegateAddLog = self
    _textFieldBaseUrl.text = url
    _textFieldBaseUrl.placeholder = "url"
    _textFieldBaseUrl.delegate = self
    
    _textFieldCost.text = "2000"
    _textFieldCost.keyboardType = .numberPad
    _textFieldCost.placeholder = "Стоимость"
    
    _textFieldPassword.text = "testPwd"
    _textFieldPassword.isSecureTextEntry = true
    _textFieldPassword.placeholder = "Пароль"
    
    _textFieldUserName.text = "3ds2-api"
    _textFieldUserName.placeholder = "Имя пользователя"
    
    _textFieldRootCI.placeholder = "Root CI"

    _textFieldDirectoryServerId.text = "directoryServerId"
    _textFieldDirectoryServerId.placeholder = "Directory server id"
    
    let textFields = [_textFieldBaseUrl, _textFieldCost, _textFieldPassword, _textFieldUserName, _textFieldDirectoryServerId, _textFieldRootCI]
    
    textFields.forEach({textField in
      _headerView.addSubview(textField)
    })

    self.tableView.tableHeaderView = _headerView
  
    self.tableView.rowHeight = UITableView.automaticDimension
    self.tableView.estimatedRowHeight = 44
    self.tableView.separatorStyle = .none
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tableView.setNeedsLayout()
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
    self.tableView.autoresizingMask = .flexibleWidth
    
    _notificationCenter.addObserver(self, selector: #selector(_reloadTableView), name: Notification.Name("ReloadTable"), object: nil)
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    let urlString = String("\(textField.text ?? url)/se/keys.do")
    CardKConfig.fetchKeys(urlString)
  }

  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
  
  @objc func _reloadTableView() {
    self.tableView.reloadData()
  }
  
  @objc func _pressedCleanButton() {
    ThreeDS2ViewController.logs.removeAllObjects()
    self.tableView.reloadData()
  }
  
  @objc func _pressedButton() {
    self._runSDK()
    self._registerOrder()
    
    _transactionManager.rootCI = _textFieldRootCI.text ?? "";
    _transactionManager.directoryServerId = _textFieldDirectoryServerId.text ?? "";

    let controller = CardKViewController();
    controller.cKitDelegate = self;
    
    let createdUiController = CardKViewController.create(self, controller: controller);
    
    let navController = UINavigationController(rootViewController: createdUiController)
    
    if #available(iOS 13.0, *) {
      self.present(navController, animated: true)
      return;
    }
    
    navController.modalPresentationStyle = .formSheet

    let closeBarButtonItem = UIBarButtonItem(
     title: "Close",
     style: .done,
     target: self,
     action: #selector(_close(sender:))
    )
    createdUiController.navigationItem.leftBarButtonItem = closeBarButtonItem
    self.present(navController, animated: true)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    _textFieldBaseUrl.frame = CGRect(x: 20, y: 10, width: self.view.bounds.width - 40, height: 50)
    _textFieldCost.frame = CGRect(x: 20, y: _textFieldBaseUrl.frame.maxY + 10, width: self.view.bounds.width - 40, height: 50)
    
    _textFieldUserName.frame = CGRect(x: 20, y: _textFieldCost.frame.maxY + 10, width: self.view.bounds.width / 2 - 30, height: 50)
    _textFieldPassword.frame = CGRect(x: _textFieldUserName.frame.maxX + 30, y: _textFieldCost.frame.maxY + 10, width: self.view.bounds.width / 2 - 40, height: 50)
    
    _textFieldDirectoryServerId.frame = CGRect(x: 20, y: _textFieldPassword.frame.maxY + 10, width: self.view.bounds.width - 40, height: 50)

    _textFieldRootCI.frame = CGRect(x: 20, y: _textFieldDirectoryServerId.frame.maxY + 10, width: self.view.bounds.width - 40, height: 50)

    _headerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: _textFieldRootCI.frame.maxY + 20)
    
    self.tableView.tableHeaderView?.frame = _headerView.frame
    self.navigationController?.isNavigationBarHidden = false
    
    let doneButton = UIBarButtonItem(title: "Старт", style: .plain, target: self, action: #selector(_pressedButton))
    let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let cancelButton = UIBarButtonItem(title: "Очистить", style: .plain, target: self, action: #selector(_pressedCleanButton))
    
    self.setToolbarItems([cancelButton,spaceButton, doneButton], animated: false)
    self.navigationController?.isToolbarHidden = false
  }
  
  func _runSDK() {
    url = _textFieldBaseUrl.text ?? url
    
    ThreeDS2ViewController.requestParams.amount = _textFieldCost.text
    ThreeDS2ViewController.requestParams.userName = _textFieldUserName.text
    ThreeDS2ViewController.requestParams.password = _textFieldPassword.text
    ThreeDS2ViewController.requestParams.returnUrl = "finish.html"
    ThreeDS2ViewController.requestParams.failUrl = "errors_ru.html"
    ThreeDS2ViewController.requestParams.email = "test@test.ru"
    ThreeDS2ViewController.requestParams.text = "DE DE"
    ThreeDS2ViewController.requestParams.threeDSSDK = "true"
  }
  
  func _registerOrder() {
    API.registerNewOrder(params: ThreeDS2ViewController.requestParams) {(data, response) in
      let params = ThreeDS2ViewController.requestParams
      let body = [
        "amount": params.amount ?? "",
        "userName": params.userName ?? "",
        "password": params.password ?? "",
        "returnUrl": params.returnUrl ?? "",
        "failUrl": params.failUrl ?? "",
        "email": params.email ?? "",
      ];
      
      self.addLog(title: "Register New Order",
                  request: String(describing: Utils.jsonSerialization(data: body)), response:String(describing: Utils.jsonSerialization(data: response)))
   
      DispatchQueue.main.async {
        self._notificationCenter.post(name: Notification.Name("ReloadTable"), object: nil)
      }
      ThreeDS2ViewController.requestParams.orderId = data.orderId
      
      CardKConfig.shared.mdOrder = data.orderId ?? ""
    }
  }
  
  func _sePayment() {
    API.sePayment(params: ThreeDS2ViewController.requestParams) {(data, response) in
      DispatchQueue.main.async {
        let params = ThreeDS2ViewController.requestParams
        let body = [
          "seToken": params.seToken ?? "",
          "MDORDER": params.orderId ?? "",
          "userName": params.userName ?? "",
          "password": params.password ?? "",
          "TEXT": params.text ?? "",
          "threeDSSDK": params.threeDSSDK ?? "",
        ];
        
        if let response = response {
          self.addLog(title: "Payment", request: String(describing: Utils.jsonSerialization(data: body)), response: Utils.jsonSerialization(data: response))
        } else {
          self.addLog(title: "Payment", request: String(describing: Utils.jsonSerialization(data: body)), response: Utils.jsonSerialization(data: ["error": "пустой объект"]))
        }
  
         
        self._notificationCenter.post(name: Notification.Name("ReloadTable"), object: nil)

        guard let data = data else {
          self._transactionManager.close()
          return
        }
        
        ThreeDS2ViewController.requestParams.threeDSSDKKey = data.threeDSSDKKey
        ThreeDS2ViewController.requestParams.threeDSServerTransId = data.threeDSServerTransId
        
        self._transactionManager.pubKey = data.threeDSSDKKey ?? ""
        
        var isDarkMode = false
        
        if #available(iOS 12.0, *) {
          if self.traitCollection.userInterfaceStyle == .dark {
            isDarkMode = true
          }
        }
             
        if self.isUseCustomTheme {
          do {
            try self._transactionManager.setUpUICustomization(isDarkMode: isDarkMode)
          } catch {}
        }
        
        self._transactionManager.initializeSdk()
        TransactionManager.sdkProgressDialog?.show()
        
        do {
          ThreeDS2ViewController.requestParams.authParams = try self._transactionManager.getAuthRequestParameters()
          self._sePaymentStep2()
        } catch {
          TransactionManager.sdkProgressDialog?.close()
        }
      }
    }
  }

  func _sePaymentStep2() {
    API.sePaymentStep2(params: ThreeDS2ViewController.requestParams) {(data, response) in
      let params = ThreeDS2ViewController.requestParams
      let body = [
        "seToken": params.seToken ?? "",
        "MDORDER": params.orderId ?? "",
        "threeDSServerTransId": params.threeDSServerTransId ?? "",
        "userName": params.userName ?? "",
        "password": params.password ?? "",
        "TEXT": params.text ?? "",
        "threeDSSDK": params.threeDSSDK ?? "",
        "threeDSSDKEncData": params.authParams!.getDeviceData(),
        "threeDSSDKEphemPubKey":params.authParams!.getSDKEphemeralPublicKey(),
        "threeDSSDKAppId": params.authParams!.getSDKAppID(),
        "threeDSSDKTransId": params.authParams!.getSDKTransactionID()
      ];
      
      self.addLog(title: "Payment step 2", request: String(describing: Utils.jsonSerialization(data: body)), response: String(describing: Utils.jsonSerialization(data: response)))

      DispatchQueue.main.async {
        self._notificationCenter.post(name: Notification.Name("ReloadTable"), object: nil)
      }

      guard let data = data else {
        self._transactionManager.close()
        return
      }
            
      self._aRes["threeDSServerTransID"] = ThreeDS2ViewController.requestParams.threeDSServerTransId ?? ""
      self._aRes["acsTransID"] = data.acsTransID
      self._aRes["acsReferenceNumber"] = data.acsReferenceNumber
      self._aRes["acsSignedContent"] = data.acsSignedContent
      
      self._transactionManager.handleResponse(responseObject: self._aRes)
    }
  }
  
  @objc func _close(sender:UIButton){
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
    
    let log = ThreeDS2ViewController.logs[indexPath.item] as! [String: String]
    
    cell.textLabel?.text = "\(log["title"] ?? "")"
    cell.accessoryType = .disclosureIndicator

    return cell
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return ThreeDS2ViewController.logs.count
  }

  override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let log = ThreeDS2ViewController.logs[indexPath.item] as! [String: String]
    
    _reqResController.requestInfo = log["request"] ?? ""
    _reqResController.responseInfo = log["response"] ?? ""
  
    self.navigationController?.pushViewController(_reqResController, animated: true)
    
    self.tableView.deselectRow(at: indexPath, animated: true)
  }
  
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}

extension ThreeDS2ViewController: CardKDelegate {
  func didRemove(_ removedBindings: [CardKBinding]) {
    
  }
  
  func cardKPaymentView(_ paymentView: CardKPaymentView, didAuthorizePayment pKPayment: PKPayment) {
  
  }
  
  func cardKitViewController(_ controller: UIViewController, didCreateSeToken seToken: String, allowSaveBinding: Bool, isNewCard: Bool) {
    debugPrint(seToken)

    let alert = UIAlertController(title: "SeToken", message: "allowSaveCard = \(allowSaveBinding) \n isNewCard = \(isNewCard) \n seToken = \(seToken)", preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

    ThreeDS2ViewController.requestParams.seToken = seToken
    
    self.dismiss(animated: true, completion: nil)
    _sePayment()
  }
  
  func willShow(_ paymentView: CardKPaymentView) {
    let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa]
    let paymentItem = PKPaymentSummaryItem.init(label: "Коробка", amount: NSDecimalNumber(value: 0.1))
    let merchandId = "merchant.cardkit";
    paymentView.merchantId = merchandId
    paymentView.paymentRequest.currencyCode = "RUB"
    paymentView.paymentRequest.countryCode = "RU"
    paymentView.paymentRequest.merchantIdentifier = merchandId
    paymentView.paymentRequest.merchantCapabilities = PKMerchantCapability.capability3DS
    paymentView.paymentRequest.supportedNetworks = paymentNetworks
    paymentView.paymentRequest.paymentSummaryItems = [paymentItem]
    paymentView.paymentButtonStyle = .black;
    paymentView.paymentButtonType = .buy;
  }
  
  func didLoad(_ controller: CardKViewController) {
    controller.allowedCardScaner = CardIOUtilities.canReadCardWithCamera();
    controller.purchaseButtonTitle = "Custom purchase button";

    controller.displayCardHolderField = true;
    controller.allowSaveBinding = true;
    controller.isSaveBinding = false;
  }
  
  func cardKitViewControllerScanCardRequest(_ controller: CardKViewController) {

  }
}
