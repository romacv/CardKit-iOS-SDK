//
//  NSObject+CardKPaymentFlow.m
//  CardKit
//
//  Created by Alex Korotkov on 3/26/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//
#import <PassKit/PassKit.h>
#import "CardKPaymentFlowController.h"
#import "CardKKindPaymentViewController.h"
#import "CardKConfig.h"
#import "RSA.h"
#import "ConfirmChoosedCard.h"
#import "CardKPaymentSessionStatus.h"

@implementation CardKPaymentFlowController {
  CardKKindPaymentViewController *_controller;
  NSString *_url;
  UIActivityIndicatorView *_spinner;
  CardKTheme *_theme;
  CardKBinding *_cardKBinding;
  CardKPaymentSessionStatus *_sessionStatus;
  CardKPaymentError *_cardKPaymentError;
  NSString *_seToken;
}
- (instancetype)init
  {
    self = [super init];
    if (self) {
      _theme = CardKConfig.shared.theme;
      self.view.backgroundColor = CardKConfig.shared.theme.colorTableBackground;
      
      _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
      [self.view addSubview:_spinner];
      _spinner.color = _theme.colorPlaceholder;
      
      _controller = [[CardKKindPaymentViewController alloc] init];
      _controller.cKitDelegate = self;

      [_spinner startAnimating];
      
      _cardKPaymentError = [[CardKPaymentError alloc] init];
    }
    return self;
  }

  - (void)viewDidLayoutSubviews {
    _spinner.frame = CGRectMake(0, 0, 100, 100);
    _spinner.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
  }

  - (void)viewDidAppear:(BOOL)animated {
    _url = @"https://web.rbsdev.com/soyuzpayment";
    [self _getSessionStatusRequest:^(CardKPaymentSessionStatus * sessionStatus) {
      
    }];
  }
  - (void)viewDidLoad {
    [super viewDidLoad];
  }

  - (NSString *) _urlParameters:(NSArray<NSString *> *) parameters {
    NSString *url = @"";

    for(NSString *parameter in parameters) {
      if ([parameters.lastObject isEqual:parameter]) {
        url = [NSString stringWithFormat:@"%@%@", url, parameter];
      } else {
        url = [NSString stringWithFormat:@"%@%@&", url, parameter];
      }
    }
    
    return url;
  }

  - (void)callPaymentErrorDelegate {

  }

  - (void) _getSessionStatusRequest:(void (^)(CardKPaymentSessionStatus *)) handler {
    NSString *mdOrder = [NSString stringWithFormat:@"%@%@", @"MDORDER=", CardKConfig.shared.mdOrder];
    NSString *URL = [NSString stringWithFormat:@"%@%@?%@", _url, @"/rest/getSessionStatus.do", mdOrder];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];

    request.HTTPMethod = @"GET";

    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
  
      if(httpResponse.statusCode != 200) {
        self->_cardKPaymentError.massage = @"Ошибка запроса статуса";
        [self->_cardKPaymentFlowDelegate didErrorPaymentFlow:self->_cardKPaymentError];

        dispatch_async(dispatch_get_main_queue(), ^{
          
          [self.navigationController popViewControllerAnimated:YES];
        });
        
        return;
      }
      
      NSError *parseError = nil;
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
      
      self->_sessionStatus = [[CardKPaymentSessionStatus alloc] init];
      self->_sessionStatus.bindingItems = [responseDictionary objectForKey:@"bindingItems"];
      self->_sessionStatus.bindingEnabled = (BOOL)[responseDictionary[@"bindingEnabled"] boolValue];
      self->_sessionStatus.cvcNotRequired = (BOOL)[responseDictionary[@"cvcNotRequired"] boolValue];
      self-> _sessionStatus.redirect = [responseDictionary objectForKey:@"redirect"];
      
      CardKConfig.shared.bindings = self->_sessionStatus.bindingItems;
      CardKConfig.shared.bindingCVCRequired = !self->_sessionStatus.cvcNotRequired;
      
      
      if (self->_sessionStatus.redirect != nil) {
        self->_cardKPaymentError.massage = self->_sessionStatus.redirect;
        [self->_cardKPaymentFlowDelegate didErrorPaymentFlow: self->_cardKPaymentError];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          [self.navigationController popViewControllerAnimated:YES];
        });
      } else {
        dispatch_async(dispatch_get_main_queue(), ^{
          UIViewController *sourceViewController = self;
          UIViewController *destinationController = self->_controller;
          UINavigationController *navigationController = sourceViewController.navigationController;
          
          [navigationController popToRootViewControllerAnimated:NO];
          [navigationController pushViewController:destinationController animated:NO];
          
          [self->_spinner stopAnimating];
        });
      }
    }];
    [dataTask resume];
  }

  - (void) _getProcessBindingFormRequest:(ConfirmChoosedCard *) choosedCard callback: (void (^)(NSDictionary *)) handler {
    NSString *mdOrder = [NSString stringWithFormat:@"%@%@", @"orderId=", CardKConfig.shared.mdOrder];
    NSString *bindingId = [NSString stringWithFormat:@"%@%@", @"bindingId=", choosedCard.cardKBinding.bindingId];
    NSString *cvc = [NSString stringWithFormat:@"%@%@", @"cvc=", choosedCard.cardKBinding.secureCode];
    NSString *language = [NSString stringWithFormat:@"%@%@", @"language=", CardKConfig.shared.language];
    NSString *parameters = [self _urlParameters:@[mdOrder, bindingId, cvc, language]];
    
    NSString *URL = [NSString stringWithFormat:@"%@%@?%@", _url, @"/rest/processBindingForm.do", parameters];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];

    request.HTTPMethod = @"POST";

    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        if(httpResponse.statusCode == 200) {
          
//          NSError *parseError = nil;
//          NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
//          handler(responseDictionary);
        }
    }];
    [dataTask resume];
  }

- (void) _getProcessFormRequest:(CardKCardView *) cardView cardOwner:(NSString *) cardOwner seToken:(NSString *) seToken callback: (void (^)(NSDictionary *)) handler {
    NSString *mdOrder = [NSString stringWithFormat:@"%@%@", @"MDORDER=", CardKConfig.shared.mdOrder];
    NSString *pan = [NSString stringWithFormat:@"%@%@", @"$PAN=", cardView.number];
    NSString *cvc = [NSString stringWithFormat:@"%@%@", @"$CVC=", cardView.secureCode];
    NSString *month = [NSString stringWithFormat:@"%@%@", @"MM=", cardView.getMonthFromExpirationDate];
    NSString *year = [NSString stringWithFormat:@"%@%@", @"YYYY=", cardView.getFullYearFromExpirationDate];
    NSString *seTokenParam = [NSString stringWithFormat:@"%@%@", @"seToken=", seToken];
    NSString *language = [NSString stringWithFormat:@"%@%@", @"language=", CardKConfig.shared.language];
    NSString *owner = [NSString stringWithFormat:@"%@%@", @"TEXT=", cardOwner];
  
    NSString *parameters = [self _urlParameters:@[mdOrder, pan, cvc, month, year, language, owner]];

    NSString *URL = [NSString stringWithFormat:@"%@%@?%@&bindingNotNeeded=false", _url, @"/rest/processform.do", parameters];
  
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];

    request.HTTPMethod = @"POST";

    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

      if(httpResponse.statusCode != 200) {
        self->_cardKPaymentError.massage = @"Ошибка запроса данных формы";
        [self->_cardKPaymentFlowDelegate didErrorPaymentFlow:self->_cardKPaymentError];

        return;
      }
      
      NSError *parseError = nil;
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

      
      NSString *redirect = [responseDictionary objectForKey:@"redirect"];
      BOOL is3DSVer2 = (BOOL)[responseDictionary[@"is3DSVer2"] boolValue];
      NSString *errorMessage = [responseDictionary objectForKey:@"error"];
      NSInteger errorCode = [responseDictionary[@"errorCode"] integerValue];
      
      if (errorCode != 0) {
        self->_cardKPaymentError.massage = errorMessage;
        [self->_cardKPaymentFlowDelegate didErrorPaymentFlow: self->_cardKPaymentError];
      } else if (redirect != nil) {
        self->_cardKPaymentError.massage = redirect;
        [self->_cardKPaymentFlowDelegate didErrorPaymentFlow: self->_cardKPaymentError];
      } else if (is3DSVer2){
        // Run 3dsVer2
        [self _sePayment];
//        [responseDictionary objectForKey:@"errorCode"];
//        [responseDictionary objectForKey:@"error"];
//        [responseDictionary objectForKey:@"redirect"];
//        [responseDictionary objectForKey:@"acsUrl"];
      }
    }];
    [dataTask resume];
  }

- (void)_getFinishedPaymentInfo {
  NSString *mdOrder = [NSString stringWithFormat:@"%@%@", @"orderId=", CardKConfig.shared.mdOrder];
  NSString *withCart = [NSString stringWithFormat:@"%@%@", @"withCart=", @"NO"];
  NSString *language = [NSString stringWithFormat:@"%@%@", @"language=", CardKConfig.shared.language];

  NSString *parameters = [self _urlParameters:@[mdOrder, withCart, language]];

  NSString *URL = [NSString stringWithFormat:@"%@%@?%@", _url, @"/rest/getFinishedPaymentInfo.do", parameters];

  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];

  request.HTTPMethod = @"GET";

  NSURLSession *session = [NSURLSession sharedSession];

  NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

      if(httpResponse.statusCode == 200) {
  //          NSError *parseError = nil;
  //          NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
  //          handler(responseDictionary);
      }
  }];
  [dataTask resume];
}

- (void)_unbindСardAnon {
  NSString *mdOrder = [NSString stringWithFormat:@"%@%@", @"orderId=", CardKConfig.shared.mdOrder];
  NSString *bindingId = [NSString stringWithFormat:@"%@%@", @"bindingId=", _cardKBinding.bindingId];
  
  NSString *parameters = [self _urlParameters:@[mdOrder, bindingId]];
  NSString *URL = [NSString stringWithFormat:@"%@%@?%@", _url, @"/binding/unbindcardanon.do", parameters];

  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];

  request.HTTPMethod = @"GET";

  NSURLSession *session = [NSURLSession sharedSession];

  NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

      if(httpResponse.statusCode == 200) {
  //          NSError *parseError = nil;
  //          NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
  //          handler(responseDictionary);
      }
  }];
  [dataTask resume];
}

- (void)sePayment {
  
}

- (void)_sePayment {
  NSString *seToken = [NSString stringWithFormat:@"%@%@", @"seToken=", _seToken];
  NSString *mdOrder = [NSString stringWithFormat:@"%@%@", @"MDORDER=", CardKConfig.shared.mdOrder];
  NSString *userName = [NSString stringWithFormat:@"%@%@", @"userName=", _userName];
  NSString *password = [NSString stringWithFormat:@"%@%@", @"password=", _password];
  NSString *threeDSSDK = [NSString stringWithFormat:@"%@%@", @"threeDSSDK=", @"YES"];
  
  NSString *parameters = [self _urlParameters:@[seToken, mdOrder, userName, password, threeDSSDK]];
  NSData *postData = [parameters dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
  

  NSString *URL = [NSString stringWithFormat:@"%@%@", _url, @"/rest/paymentorder.do"];

  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];

  request.HTTPMethod = @"POST";
  [request setHTTPBody:postData];

  NSURLSession *session = [NSURLSession sharedSession];

  NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

      if(httpResponse.statusCode == 200) {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        
        
//        CardKConfig.shared.mdOrder = data.orderId ?? ""

      }
  }];
  [dataTask resume];
  
//  API.sePayment(params: ThreeDS2ViewController.requestParams) {(data, response) in
//    DispatchQueue.main.async {
//      let params = ThreeDS2ViewController.requestParams
//      let body = [
//        "seToken": params.seToken ?? "",
//        "MDORDER": params.orderId ?? "",
//        "userName": params.userName ?? "",
//        "password": params.password ?? "",
//        "TEXT": params.text ?? "",
//        "threeDSSDK": params.threeDSSDK ?? "",
//      ];
//
//      self.addLog(title: "Payment", request: String(describing: Utils.jsonSerialization(data: body)), response: Utils.jsonSerialization(data: response))
//
//      guard let data = data else {
//        self._transactionManager.close()
//        self._notificationCenter.post(name: Notification.Name("ReloadTable"), object: nil)
//        return
//      }
//
//      ThreeDS2ViewController.requestParams.threeDSSDKKey = data.threeDSSDKKey
//      ThreeDS2ViewController.requestParams.threeDSServerTransId = data.threeDSServerTransId
//
//      self._transactionManager.pubKey = data.threeDSSDKKey ?? ""
//
//      var isDarkMode = false
//
//      if #available(iOS 12.0, *) {
//        if self.traitCollection.userInterfaceStyle == .dark {
//          isDarkMode = true
//        }
//      }
//
//      if self.isUseCustomTheme {
//        do {
//          try self._transactionManager.setUpUICustomization(isDarkMode: isDarkMode)
//        } catch {}
//      }
//
//      self._transactionManager.initializeSdk()
//      TransactionManager.sdkProgressDialog?.show()
//
//      do {
//        ThreeDS2ViewController.requestParams.authParams = try self._transactionManager.getAuthRequestParameters()
//        self._sePaymentStep2()
//      } catch {
//        TransactionManager.sdkProgressDialog?.close()
//        self._notificationCenter.post(name: Notification.Name("ReloadTable"), object: nil)
//      }
//    }
//  }
}

- (void)_sePaymentStep2 {
//  API.sePaymentStep2(params: ThreeDS2ViewController.requestParams) {(data, response) in
//    let params = ThreeDS2ViewController.requestParams
//    let body = [
//      "seToken": params.seToken ?? "",
//      "MDORDER": params.orderId ?? "",
//      "threeDSServerTransId": params.threeDSServerTransId ?? "",
//      "userName": params.userName ?? "",
//      "password": params.password ?? "",
//      "TEXT": params.text ?? "",
//      "threeDSSDK": params.threeDSSDK ?? "",
//      "threeDSSDKEncData": params.authParams!.getDeviceData(),
//      "threeDSSDKEphemPubKey":params.authParams!.getSDKEphemeralPublicKey(),
//      "threeDSSDKAppId": params.authParams!.getSDKAppID(),
//      "threeDSSDKTransId": params.authParams!.getSDKTransactionID()
//    ];
//
//    self.addLog(title: "Payment step 2", request: String(describing: Utils.jsonSerialization(data: body)), response: String(describing: Utils.jsonSerialization(data: response)))
//
//    guard let data = data else {
//      self._transactionManager.close()
//      return
//    }
//
//    self._aRes["threeDSServerTransID"] = ThreeDS2ViewController.requestParams.threeDSServerTransId ?? ""
//    self._aRes["acsTransID"] = data.acsTransID
//    self._aRes["acsReferenceNumber"] = data.acsReferenceNumber
//    self._aRes["acsSignedContent"] = data.acsSignedContent
//
//    let _aRes: ARes = ARes(JSON: self._aRes)!;
//
//    self._transactionManager.handleResponse(responseObject: _aRes)
//  }
}


// CardKDelegate
- (void)cardKPaymentView:(nonnull CardKPaymentView *)paymentView didAuthorizePayment:(nonnull PKPayment *)pKPayment {
  
}

- (void)cardKitViewController:(nonnull UIViewController *)controller didCreateSeToken:(nonnull NSString *)seToken allowSaveBinding:(BOOL)allowSaveBinding isNewCard:(BOOL)isNewCard {
  
  _seToken = seToken;
  if (isNewCard) {
    CardKViewController *cardKViewController = (CardKViewController *) controller;
    [self _getProcessFormRequest: [cardKViewController getCardKView]
                       cardOwner:[cardKViewController getCardOwner]
                        seToken:seToken
                        callback:^(NSDictionary * sessionStatus) {}];
    
  } else {
    ConfirmChoosedCard *confirmChoosedCardController = (ConfirmChoosedCard *) controller;
    _cardKBinding = confirmChoosedCardController.cardKBinding;
    [self _getProcessBindingFormRequest:confirmChoosedCardController
                        callback:^(NSDictionary * sessionStatus) {}];
  }
}

- (void)didLoadController:(nonnull CardKViewController *)controller {
  controller.purchaseButtonTitle = @"Custom purchase button";
  controller.allowSaveBinding = self->_sessionStatus.bindingEnabled;
  controller.isSaveBinding = false;
  controller.displayCardHolderField = true;
}

- (void)didRemoveBindings:(nonnull NSArray<CardKBinding *> *)removedBindings {
  
}

- (void)willShowPaymentView:(nonnull CardKPaymentView *)paymentView {
  NSArray *paymentNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkDiscover, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];
 
  PKPaymentSummaryItem *paymentItem = [PKPaymentSummaryItem summaryItemWithLabel:@"Коробка" amount:[[NSDecimalNumber alloc] initWithString:@"0.1"]];
  
  NSString *merchandId = @"merchant.cardkit";
  paymentView.merchantId = merchandId;
  paymentView.paymentRequest.currencyCode = @"RUB";
  paymentView.paymentRequest.countryCode = @"RU";
  paymentView.paymentRequest.merchantIdentifier = merchandId;
  paymentView.paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
  paymentView.paymentRequest.supportedNetworks = paymentNetworks;
  paymentView.paymentRequest.paymentSummaryItems = @[paymentItem];
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
  
}
@end
