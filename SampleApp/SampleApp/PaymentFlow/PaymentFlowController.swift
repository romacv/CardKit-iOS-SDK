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
  static var requestParams: RequestParams = RequestParams();
  let _paymentFlowController: CardKPaymentFlowController = CardKPaymentFlowController();
  var _button: UIButton = UIButton();

  init() {
    super.init(nibName: nil, bundle: nil)

    _paymentFlowController.cardKPaymentFlowDelegate = self;
    self.view.addSubview(_button)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    ThreeDS2ViewController.logs.removeAllObjects()
    if #available(iOS 13.0, *) {
      CardKConfig.shared.theme = CardKTheme.system()
    } else {
      CardKConfig.shared.theme = CardKTheme.light()
    };
    CardKConfig.shared.language = "ru";
    CardKConfig.shared.bindingCVCRequired = true;
    CardKConfig.shared.isTestMod = true;
    CardKConfig.shared.mrBinApiURL = "https://mrbin.io/bins/display";
    CardKConfig.shared.mrBinURL = "https://mrbin.io/bins/";
    CardKConfig.shared.pubKey = """
        -----BEGIN PUBLIC KEY-----
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAws0r6I8emCsURXfuQcU2c9mwUlOiDjuCZ/f+EdadA4vq/kYt3w6kC5TUW97Fm/HTikkHd0bt8wJvOzz3T0O4so+vBaC0xjE8JuU1eCd+zUX/plw1REVVii1RNh9gMWW1fRNu6KDNSZyfftY2BTcP1dbE1itpXMGUPW+TOk3U9WP4vf7pL/xIHxCsHzb0zgmwShm3D46w7dPW+HO3PEHakSWV9bInkchOvh/vJBiRw6iadAjtNJ4+EkgNjHwZJDuo/0bQV+r9jeOe+O1aXLYK/s1UjRs5T4uGeIzmdLUKnu4eTOQ16P6BHWAjyqPnXliYIKfi+FjZxyWEAlYUq+CRqQIDAQAB-----END PUBLIC KEY-----
  """
    CardKConfig.shared.isEditBindingListMode = true
    
    PaymentFlowController.requestParams.amount = "2000"
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
    API.registerNewOrder(params: PaymentFlowController.requestParams) {(data, response) in
      PaymentFlowController.requestParams.orderId = data.orderId
      CardKConfig.shared.mdOrder = data.orderId ?? ""
      
      DispatchQueue.main.async {
        self._paymentFlowController.userName = "3ds2-api";
        self._paymentFlowController.password = "testPwd";
        self._paymentFlowController.url = "https://web.rbsdev.com/soyuzpayment";

        let navController = UINavigationController(rootViewController: self._paymentFlowController)
        
        self.present(navController, animated: true, completion: nil)
      }
    }
  }
}

extension PaymentFlowController: CardKPaymentFlowDelegate {
  func didFinishPaymentFlow(_ paymentInfo: [AnyHashable : Any]!) {
    Log.i(object: self, message: "didFinishPaymentFlow")
  }
  
  func didErrorPaymentFlow(_ paymentError: CardKPaymentError!) {
    Log.i(object: self, message: "didErrorPaymentFlow")
  }
  
  func didCancelPaymentFlow() {
    Log.i(object: self, message: "didCancel")
  }
}
