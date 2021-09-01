//
//  PaymentFlowController.swift
//  SampleApp
//
//  Created by Alex Korotkov on 3/30/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//

import Foundation
import CardKit

class PaymentFlowController: UIViewController {
  var sampleAppCardIO: SampleAppCardIO? = nil
  var navController: UINavigationController!
  static var requestParams: RequestParams = RequestParams();
  var _paymentFlowController: CardKPaymentFlowController!;
  var amount: String {
      get {
        return PaymentFlowController.requestParams.amount ?? ""
      }
      set(newAmount) {
        PaymentFlowController.requestParams.amount = newAmount
      }
  } 
  
  var _button: UIButton = UIButton();

  init() {
    super.init(nibName: nil, bundle: nil)

    _paymentFlowController = CardKPaymentFlowController();
    _paymentFlowController.cardKPaymentFlowDelegate = self;

    navController = UINavigationController(rootViewController: _paymentFlowController)
    self.view.addSubview(_button)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    ThreeDS2ViewController.logs.removeAllObjects()
    if #available(iOS 13.0, *) {
      self.view.backgroundColor = .systemGray6
      CardKConfig.shared.theme = CardKTheme.system()
    } else {
      self.view.backgroundColor = .white
      CardKConfig.shared.theme = CardKTheme.light()
    };

    _button.setTitleColor(.systemBlue, for: .normal)
    
    CardKConfig.shared.language = "en";
    CardKConfig.shared.bindingCVCRequired = true;
    CardKConfig.shared.isTestMod = true;
    CardKConfig.shared.mrBinApiURL = "https://mrbin.io/bins/display";
    CardKConfig.shared.mrBinURL = "https://mrbin.io/bins/";
    CardKConfig.shared.pubKey = """
        -----BEGIN PUBLIC KEY-----
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAws0r6I8emCsURXfuQcU2c9mwUlOiDjuCZ/f+EdadA4vq/kYt3w6kC5TUW97Fm/HTikkHd0bt8wJvOzz3T0O4so+vBaC0xjE8JuU1eCd+zUX/plw1REVVii1RNh9gMWW1fRNu6KDNSZyfftY2BTcP1dbE1itpXMGUPW+TOk3U9WP4vf7pL/xIHxCsHzb0zgmwShm3D46w7dPW+HO3PEHakSWV9bInkchOvh/vJBiRw6iadAjtNJ4+EkgNjHwZJDuo/0bQV+r9jeOe+O1aXLYK/s1UjRs5T4uGeIzmdLUKnu4eTOQ16P6BHWAjyqPnXliYIKfi+FjZxyWEAlYUq+CRqQIDAQAB-----END PUBLIC KEY-----
  """
    CardKConfig.shared.isEditBindingListMode = true
    CardKConfig.shared.rootCertificate = """
      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
  """

    PaymentFlowController.requestParams.userName = "3ds2-api"
    PaymentFlowController.requestParams.password = "testPwd"
    PaymentFlowController.requestParams.returnUrl = "returnUrl"
    PaymentFlowController.requestParams.failUrl = "errors_ru.html"
    PaymentFlowController.requestParams.email = "test@test.ru"
    PaymentFlowController.requestParams.text = "DE DE"
    PaymentFlowController.requestParams.threeDSSDK = "true"
    PaymentFlowController.requestParams.clientId = "clientId"
    
    _button.setTitle("Начать Payement flow", for: .normal);
    _button.frame = CGRect(x: 0, y: 0, width: 200, height: 100);
    _button.center = CGPoint(x: self.view.bounds.size.width / 2, y: self.view.bounds.size.height / 2);
    _button.addTarget(self, action: #selector(_pressedButton), for: .touchDown);
  }
  
  @objc func _pressedButton() {
    _registerOrder()
  }

  func _registerOrder() {
    _paymentFlowController = CardKPaymentFlowController();
    _paymentFlowController.cardKPaymentFlowDelegate = self;
    
    API.registerNewOrder(params: PaymentFlowController.requestParams) {(data, response) in
      PaymentFlowController.requestParams.orderId = data.orderId
      CardKConfig.shared.mdOrder = data.orderId ?? ""
      
      let amountDecimal = NSDecimalNumber (string: PaymentFlowController.requestParams.amount)
      
      DispatchQueue.main.async {
        let paymentRequest = PKPaymentRequest();
        paymentRequest.currencyCode = "RUB";
        paymentRequest.countryCode = "RU";
        paymentRequest.merchantCapabilities = PKMerchantCapability.capability3DS
        paymentRequest.supportedNetworks = [.visa, .amex, .masterCard];
        paymentRequest.paymentSummaryItems = [
          PKPaymentSummaryItem(label: "Коробка", amount: amountDecimal)
        ];
        
        let cardPayButton = UIButton();
        cardPayButton.backgroundColor = .systemBlue;
        cardPayButton.setTitleColor(.white, for: .normal)
        cardPayButton.setTitle("New card", for: .normal)
        
        let cardKPaymentView = CardKPaymentView();
        cardKPaymentView.merchantId = "merchant.cardkit";
        cardKPaymentView.paymentRequest = paymentRequest;
        cardKPaymentView.paymentButtonStyle = .black;
        cardKPaymentView.paymentButtonType = .buy;
        cardKPaymentView.cardPaybutton = cardPayButton;
        cardKPaymentView.paymentRequest.merchantIdentifier = "merchant.cardkit";
        
        self._paymentFlowController.url = "https://web.rbsdev.com/soyuzpayment";
        self._paymentFlowController.cardKPaymentView = cardKPaymentView;
        self._paymentFlowController.allowedCardScaner = CardIOUtilities.canReadCardWithCamera();
        self._paymentFlowController.headerLabel = "Custom header label";
      
        self._paymentFlowController.textDoneButtonColor = .white
        self._paymentFlowController.primaryColor = .systemBlue
        if #available(iOS 13.0, *) {
          self._paymentFlowController.textDoneButtonColor = .white
        }
        
        self.navController = UINavigationController(rootViewController: self._paymentFlowController)
        
        
        self.present(self.navController, animated: true, completion: nil)
      }
    }
  }
}

extension PaymentFlowController: CardKPaymentFlowDelegate {
  func didFinishPaymentFlow(_ paymentInfo: [AnyHashable : Any]!) {
    print("didFinishPaymentFlow")
    var message = ""
    for key in paymentInfo.keys {
      message = "\(message) \n \(key) = \(paymentInfo[key] ?? "")"
    }

    let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
      self.dismiss(animated: true, completion: nil)
    }))
    
    self.navController.present(alert, animated: true, completion: nil)
  }
  
  func didErrorPaymentFlow(_ paymentError: CardKPaymentError!) {
    let alert = UIAlertController(title: "Error", message: paymentError.message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    self.navController.present(alert, animated: true, completion: nil)
  }
  
  func didCancelPaymentFlow() {
    let alert = UIAlertController(title: "Cancel", message: "Action was canceled", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
      self.dismiss(animated: true, completion: nil)
    }))
    
    self.navController.present(alert, animated: true, completion: nil)
  }
  
  func scanCardRequest(_ controller: CardKViewController) {
    let cardIO = CardIOView(frame: controller.view.bounds)
    cardIO.hideCardIOLogo = true
    cardIO.scanExpiry = false
    cardIO.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    sampleAppCardIO = SampleAppCardIO()
    sampleAppCardIO?.cardKController = controller
    cardIO.delegate = sampleAppCardIO
    
    controller.showScanCardView(cardIO, animated: true)
  }
}
