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
#import <ThreeDSSDK/ThreeDSSDK.h>

#import <CardKit/CardKit-Swift.h>
#import "ARes.h"

@protocol TransactionManagerDelegate;

@interface CardKPaymentFlowController () <TransactionManagerDelegate>
@end

@implementation CardKPaymentFlowController {
  CardKKindPaymentViewController *_controller;
  NSString *_url;
  UIActivityIndicatorView *_spinner;
  CardKTheme *_theme;
  CardKBinding *_cardKBinding;
  CardKPaymentSessionStatus *_sessionStatus;
  CardKPaymentError *_cardKPaymentError;
  NSString *_seToken;
  TransactionManager *_transactionManager;
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
      
      [_spinner startAnimating];
      
      _cardKPaymentError = [[CardKPaymentError alloc] init];

      _url = @"https://web.rbsdev.com/soyuzpayment";
      
      _transactionManager = [[TransactionManager alloc] init];
      _transactionManager.delegate = self;
    }
    return self;
  }

  - (void)viewDidLayoutSubviews {
    _spinner.frame = CGRectMake(0, 0, 100, 100);
    _spinner.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
  }

  - (void)viewDidAppear:(BOOL)animated {
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

  - (void)_sendError {
    self->_cardKPaymentError.massage = @"Ошибка запроса статуса";
    [self->_cardKPaymentFlowDelegate didErrorPaymentFlow:self->_cardKPaymentError];

    [self.navigationController popViewControllerAnimated:YES];
  }

  - (void)_sendRedirectError {
    self->_cardKPaymentError.massage = self->_sessionStatus.redirect;
    [self->_cardKPaymentFlowDelegate didErrorPaymentFlow: self->_cardKPaymentError];
  
    [self.navigationController popViewControllerAnimated:YES];
  }
  
  - (void)_moveChoosePaymentMethodController {
    _controller = [[CardKKindPaymentViewController alloc] init];
    _controller.cKitDelegate = self;
    
    UIViewController *sourceViewController = self;
    UIViewController *destinationController = self->_controller;
    UINavigationController *navigationController = sourceViewController.navigationController;
    
    [navigationController popToRootViewControllerAnimated:NO];
    [navigationController pushViewController:destinationController animated:NO];
    
    [self->_spinner stopAnimating];
  }

  - (void) _getFinishSessionStatusRequest {
    NSString *mdOrder = [NSString stringWithFormat:@"%@%@", @"MDORDER=", CardKConfig.shared.mdOrder];
    NSString *URL = [NSString stringWithFormat:@"%@%@?%@", _url, @"/rest/getSessionStatus.do", mdOrder];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];

    request.HTTPMethod = @"GET";

    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      
      dispatch_async(dispatch_get_main_queue(), ^{
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

      if(httpResponse.statusCode != 200) {
        [self _sendError];
        return;
      }
      
      NSError *parseError = nil;
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

      self-> _sessionStatus.redirect = [responseDictionary objectForKey:@"redirect"];

      if (self->_sessionStatus.redirect == nil) {
        [self _sendRedirectError];
      } else {
        [self _getFinishedPaymentInfo];
      }
      });
    }];
    [dataTask resume];
  }
  
  - (NSArray<CardKBinding *> *) _convertBindingItemsToCardKBinding:(NSArray<NSDictionary *> *) bindingItems {
    
    NSMutableArray<CardKBinding *> *bindings = [[NSMutableArray alloc] init];
    
    for (NSDictionary *binding in bindingItems) {
      CardKBinding *cardKBinding = [[CardKBinding alloc] init];
      
      NSArray *label = [(NSString *) binding[@"label"] componentsSeparatedByString:@" "];
      cardKBinding.bindingId = binding[@"id"];
      cardKBinding.paymentSystem = binding[@"paymentSystem"];
      
      cardKBinding.cardNumber = label[0];
      cardKBinding.expireDate = label[1];
      
      [bindings addObject:cardKBinding];
    }
  
    return bindings;
  }

  - (void) _getSessionStatusRequest:(void (^)(CardKPaymentSessionStatus *)) handler {
    NSString *mdOrder = [NSString stringWithFormat:@"%@%@", @"MDORDER=", CardKConfig.shared.mdOrder];
    NSString *URL = [NSString stringWithFormat:@"%@%@?%@", _url, @"/rest/getSessionStatus.do", mdOrder];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];

    request.HTTPMethod = @"GET";

    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      
      dispatch_async(dispatch_get_main_queue(), ^{
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
  
      if(httpResponse.statusCode != 200) {
        [self _sendError];
        return;
      }
      
      NSError *parseError = nil;
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
      
      self->_sessionStatus = [[CardKPaymentSessionStatus alloc] init];
        
      NSArray<NSDictionary *> *bindingItems = (NSArray<NSDictionary *> *) responseDictionary[@"bindingItems"];

      self->_sessionStatus.bindingItems = [self _convertBindingItemsToCardKBinding: bindingItems];
      self->_sessionStatus.bindingEnabled = (BOOL)[responseDictionary[@"bindingEnabled"] boolValue];
      self->_sessionStatus.cvcNotRequired = (BOOL)[responseDictionary[@"cvcNotRequired"] boolValue];
      self-> _sessionStatus.redirect = [responseDictionary objectForKey:@"redirect"];
      
      CardKConfig.shared.bindings = [[NSArray alloc] initWithArray:self->_sessionStatus.bindingItems];
      CardKConfig.shared.bindingCVCRequired = !self->_sessionStatus.cvcNotRequired;
      
      if (self->_sessionStatus.redirect != nil) {
        [self _sendRedirectError];
      } else {
        [self _moveChoosePaymentMethodController];
      }
        
        handler(self->_sessionStatus);
      });
    }];
    [dataTask resume];
  }

  - (void) _processBindingFormRequest:(ConfirmChoosedCard *) choosedCard callback: (void (^)(NSDictionary *)) handler {
    NSString *mdOrder = [NSString stringWithFormat:@"%@%@", @"orderId=", CardKConfig.shared.mdOrder];
    NSString *bindingId = [NSString stringWithFormat:@"%@%@", @"bindingId=", choosedCard.cardKBinding.bindingId];
    NSString *cvc = [NSString stringWithFormat:@"%@%@", @"cvc=", choosedCard.cardKBinding.secureCode];
    NSString *language = [NSString stringWithFormat:@"%@%@", @"language=", CardKConfig.shared.language];
    NSString *threeDSSDK = [NSString stringWithFormat:@"%@%@", @"threeDSSDK=", @"true"];
    
    NSString *parameters = @"";
    
    if (CardKConfig.shared.bindingCVCRequired) {
      parameters = [self _urlParameters:@[mdOrder, bindingId, cvc, language, threeDSSDK]];
    } else {
      parameters = [self _urlParameters:@[mdOrder, bindingId, language, threeDSSDK]];
    }
    
    NSString *URL = [NSString stringWithFormat:@"%@%@", _url, @"/rest/processBindingForm.do"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];

    request.HTTPMethod = @"POST";
    
    NSData *postData = [parameters dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    [request setHTTPBody:postData];


    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
      
      dispatch_async(dispatch_get_main_queue(), ^{
        
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

      if(httpResponse.statusCode != 200) {
        [self _sendError];
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
        RequestParams.shared.threeDSServerTransId = [responseDictionary objectForKey:@"threeDSServerTransId"];
        RequestParams.shared.threeDSSDKKey = [responseDictionary objectForKey:@"threeDSSDKKey"];

        self->_transactionManager.pubKey = RequestParams.shared.threeDSSDKKey;
       
        
        [self->_transactionManager setUpUICustomizationWithIsDarkMode:NO error:nil];
        [self->_transactionManager initializeSdk];
        [self->_transactionManager showProgressDialog];
        NSDictionary *reqParams = [self->_transactionManager getAuthRequestParameters];
        
        RequestParams.shared.threeDSSDKEncData = reqParams[@"threeDSSDKEncData"];
        RequestParams.shared.threeDSSDKEphemPubKey = reqParams[@"threeDSSDKEphemPubKey"];
        RequestParams.shared.threeDSSDKAppId = reqParams[@"threeDSSDKAppId"];
        RequestParams.shared.threeDSSDKTransId = reqParams[@"threeDSSDKTransId"];

        [self _processBindingFormRequestStep2:(ConfirmChoosedCard *) choosedCard  callback: (void (^)(NSDictionary *)) handler];
      }
    });
      
    }];
    [dataTask resume];
  }

  - (void) _processBindingFormRequestStep2:(ConfirmChoosedCard *) choosedCard callback: (void (^)(NSDictionary *)) handler {
    NSString *mdOrder = [NSString stringWithFormat:@"%@%@", @"orderId=", CardKConfig.shared.mdOrder];
    NSString *bindingId = [NSString stringWithFormat:@"%@%@", @"bindingId=", choosedCard.cardKBinding.bindingId];
    NSString *cvc = [NSString stringWithFormat:@"%@%@", @"cvc=", choosedCard.cardKBinding.secureCode];
    NSString *language = [NSString stringWithFormat:@"%@%@", @"language=", CardKConfig.shared.language];
    
    NSString *threeDSSDK = [NSString stringWithFormat:@"%@%@", @"threeDSSDK=", @"true"];
    NSString *threeDSSDKEncData = [NSString stringWithFormat:@"%@%@", @"threeDSSDKEncData=", RequestParams.shared.threeDSSDKEncData];
    NSString *threeDSSDKEphemPubKey = [NSString stringWithFormat:@"%@%@", @"threeDSSDKEphemPubKey=", RequestParams.shared.threeDSSDKEphemPubKey];
    NSString *threeDSSDKAppId = [NSString stringWithFormat:@"%@%@", @"threeDSSDKAppId=", RequestParams.shared.threeDSSDKAppId];
    NSString *threeDSSDKTransId = [NSString stringWithFormat:@"%@%@", @"threeDSSDKTransId=", RequestParams.shared.threeDSSDKTransId];
    NSString *threeDSServerTransId = [NSString stringWithFormat:@"%@%@", @"threeDSServerTransId=", RequestParams.shared.threeDSServerTransId];
    
    NSString *parameters = @"";
    
    if (CardKConfig.shared.bindingCVCRequired) {
      parameters = [self _urlParameters:@[mdOrder, bindingId, cvc, threeDSSDK, language, threeDSSDKEncData, threeDSSDKEphemPubKey, threeDSSDKAppId, threeDSSDKTransId, threeDSServerTransId]];
    } else {
      parameters = [self _urlParameters:@[mdOrder, bindingId, threeDSSDK, language, threeDSSDKEncData, threeDSSDKEphemPubKey, threeDSSDKAppId, threeDSSDKTransId, threeDSServerTransId]];
    }
    
    NSString *URL = [NSString stringWithFormat:@"%@%@", _url, @"/rest/processBindingForm.do"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];

    request.HTTPMethod = @"POST";
    
    NSData *postData = [parameters dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    [request setHTTPBody:postData];

    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

      if (httpResponse.statusCode != 200) {
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
      
      if (errorCode != 0 || ![errorMessage isEqual:@""]) {
        self->_cardKPaymentError.massage = errorMessage;
        [self->_cardKPaymentFlowDelegate didErrorPaymentFlow: self->_cardKPaymentError];
        [self->_transactionManager closeProgressDialog];
      } else if (redirect != nil) {
        self->_cardKPaymentError.massage = redirect;
        [self->_cardKPaymentFlowDelegate didErrorPaymentFlow: self->_cardKPaymentError];
        [self->_transactionManager closeProgressDialog];
      } else if (is3DSVer2){
        [self _runChallange: responseDictionary];
      }
      
    }];
    [dataTask resume];
  }

- (void)_initSDK:(CardKCardView *) cardView cardOwner:(NSString *) cardOwner seToken:(NSString *) seToken allowSaveBinding:(BOOL) allowSaveBinding callback: (void (^)(NSDictionary *)) handler {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self->_transactionManager setUpUICustomizationWithIsDarkMode:NO error:nil];
    [self->_transactionManager initializeSdk];
    [self->_transactionManager showProgressDialog];
    NSDictionary *reqParams = [self->_transactionManager getAuthRequestParameters];
    
    RequestParams.shared.threeDSSDKEncData = reqParams[@"threeDSSDKEncData"];
    RequestParams.shared.threeDSSDKEphemPubKey = reqParams[@"threeDSSDKEphemPubKey"];
    RequestParams.shared.threeDSSDKAppId = reqParams[@"threeDSSDKAppId"];
    RequestParams.shared.threeDSSDKTransId = reqParams[@"threeDSSDKTransId"];

    [self _processFormRequestStep2:(CardKCardView *) cardView cardOwner:(NSString *) cardOwner seToken:(NSString *) seToken allowSaveBinding:(BOOL) allowSaveBinding callback: (void (^)(NSDictionary *)) handler];
  });
}

- (void) _processFormRequest:(CardKCardView *) cardView cardOwner:(NSString *) cardOwner seToken:(NSString *) seToken allowSaveBinding:(BOOL) allowSaveBinding callback: (void (^)(NSDictionary *)) handler {
  NSString *mdOrder = [NSString stringWithFormat:@"%@%@", @"MDORDER=", CardKConfig.shared.mdOrder];
  NSString *language = [NSString stringWithFormat:@"%@%@", @"language=", CardKConfig.shared.language];
  NSString *owner = [NSString stringWithFormat:@"%@%@", @"TEXT=", cardOwner];
  NSString *threeDSSDK = [NSString stringWithFormat:@"%@%@", @"threeDSSDK=", @"true"];
  NSString *seTokenParam = [NSString stringWithFormat:@"%@%@", @"seToken=", [seToken stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]];
  NSString *bindingNotNeeded = [NSString stringWithFormat:@"%@%@", @"bindingNotNeeded=", allowSaveBinding ? @"false" : @"true"];

  NSString *parameters = [self _urlParameters:@[mdOrder, seTokenParam, language, owner, bindingNotNeeded, threeDSSDK]];
  NSString *URL = [NSString stringWithFormat:@"%@%@", _url, @"/rest/processform.do"];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
  request.HTTPMethod = @"POST";

  NSData *postData = [parameters dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
  [request setHTTPBody:postData];

  NSURLSession *session = [NSURLSession sharedSession];

  NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

    if(httpResponse.statusCode != 200) {
      [self _sendError];
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
      RequestParams.shared.threeDSServerTransId = [responseDictionary objectForKey:@"threeDSServerTransId"];
      RequestParams.shared.threeDSSDKKey = [responseDictionary objectForKey:@"threeDSSDKKey"];

      self->_transactionManager.pubKey = RequestParams.shared.threeDSSDKKey;
     
      [self _initSDK:(CardKCardView *) cardView cardOwner:(NSString *) cardOwner seToken:(NSString *) seToken allowSaveBinding:(BOOL) allowSaveBinding callback: (void (^)(NSDictionary *)) handler];
    }
  });
  }];
  [dataTask resume];
}

- (void) _runChallange:(NSDictionary *) responseDictionary {
  ARes *aRes = [[ARes alloc] init];
  aRes.acsTransID = [responseDictionary objectForKey:@"threeDSAcsTransactionId"];
  aRes.acsReferenceNumber = [responseDictionary objectForKey:@"threeDSAcsRefNumber"];
  aRes.acsSignedContent = [responseDictionary objectForKey:@"threeDSAcsSignedContent"];
  aRes.threeDSServerTransID = RequestParams.shared.threeDSServerTransId;

  [self->_transactionManager handleResponseWithResponseObject:aRes];
}

- (void) _processFormRequestStep2:(CardKCardView *) cardView cardOwner:(NSString *) cardOwner seToken:(NSString *) seToken allowSaveBinding:(BOOL) allowSaveBinding callback: (void (^)(NSDictionary *)) handler {
    NSString *mdOrder = [NSString stringWithFormat:@"%@%@", @"MDORDER=", CardKConfig.shared.mdOrder];
    NSString *threeDSSDK = [NSString stringWithFormat:@"%@%@", @"threeDSSDK=", @"true"];
    NSString *language = [NSString stringWithFormat:@"%@%@", @"language=", CardKConfig.shared.language];
    NSString *owner = [NSString stringWithFormat:@"%@%@", @"TEXT=", cardOwner];
    NSString *bindingNotNeeded = [NSString stringWithFormat:@"%@%@", @"bindingNotNeeded=", allowSaveBinding ? @"false" : @"true"];
    NSString *seTokenParam = [NSString stringWithFormat:@"%@%@", @"seToken=", [seToken stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]];
  
    NSString *threeDSSDKEncData = [NSString stringWithFormat:@"%@%@", @"threeDSSDKEncData=", RequestParams.shared.threeDSSDKEncData];
    NSString *threeDSSDKEphemPubKey = [NSString stringWithFormat:@"%@%@", @"threeDSSDKEphemPubKey=", RequestParams.shared.threeDSSDKEphemPubKey];
    NSString *threeDSSDKAppId = [NSString stringWithFormat:@"%@%@", @"threeDSSDKAppId=", RequestParams.shared.threeDSSDKAppId];
    NSString *threeDSSDKTransId = [NSString stringWithFormat:@"%@%@", @"threeDSSDKTransId=", RequestParams.shared.threeDSSDKTransId];
    NSString *threeDSServerTransId = [NSString stringWithFormat:@"%@%@", @"threeDSServerTransId=", RequestParams.shared.threeDSServerTransId];
  
    NSString *parameters = [self _urlParameters:@[mdOrder, threeDSSDK, language, owner, bindingNotNeeded, threeDSSDKEncData, threeDSSDKEphemPubKey, threeDSSDKAppId, threeDSSDKTransId, threeDSServerTransId, seTokenParam]];

    NSData *postData = [parameters dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *URL = [NSString stringWithFormat:@"%@%@", _url, @"/rest/processform.do"];
  
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];

    request.HTTPMethod = @"POST";
    [request setHTTPBody:postData];
  
    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

      if (httpResponse.statusCode != 200) {
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
      
      if (errorCode != 0 || ![errorMessage isEqual:@""]) {
        self->_cardKPaymentError.massage = errorMessage;
        [self->_cardKPaymentFlowDelegate didErrorPaymentFlow: self->_cardKPaymentError];
        [self->_transactionManager closeProgressDialog];
      } else if (redirect != nil) {
        self->_cardKPaymentError.massage = redirect;
        [self->_cardKPaymentFlowDelegate didErrorPaymentFlow: self->_cardKPaymentError];
        [self->_transactionManager closeProgressDialog];
      } else if (is3DSVer2){
        [self _runChallange: responseDictionary];
      }
    }];
    [dataTask resume];
  }

- (void)_getFinishedPaymentInfo {
  NSString *mdOrder = [NSString stringWithFormat:@"%@%@", @"orderId=", CardKConfig.shared.mdOrder];
  NSString *withCart = [NSString stringWithFormat:@"%@%@", @"withCart=", @"false"];
  NSString *language = [NSString stringWithFormat:@"%@%@", @"language=", CardKConfig.shared.language];

  NSString *parameters = [self _urlParameters:@[mdOrder, withCart, language]];

  NSString *URL = [NSString stringWithFormat:@"%@%@?%@", _url, @"/rest/getFinishedPaymentInfo.do", parameters];

  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];

  request.HTTPMethod = @"GET";

  NSURLSession *session = [NSURLSession sharedSession];

  NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      dispatch_async(dispatch_get_main_queue(), ^{
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
          
        if(httpResponse.statusCode != 200) {
          [self _sendError];
          return;
        }
        
        NSError *parseError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        
        [self->_cardKPaymentFlowDelegate didFinishPaymentFlow:responseDictionary];
    });
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

    }
  }];
  [dataTask resume];
}

// CardKDelegate
- (void)cardKPaymentView:(nonnull CardKPaymentView *)paymentView didAuthorizePayment:(nonnull PKPayment *)pKPayment {
}

- (void)cardKitViewController:(nonnull UIViewController *)controller didCreateSeToken:(nonnull NSString *)seToken allowSaveBinding:(BOOL)allowSaveBinding isNewCard:(BOOL)isNewCard {
  
  _seToken = seToken;
  if (isNewCard) {
    CardKViewController *cardKViewController = (CardKViewController *) controller;
    [self _processFormRequest: [cardKViewController getCardKView]
               cardOwner:[cardKViewController getCardOwner]
                seToken:seToken
     allowSaveBinding: allowSaveBinding
                callback:^(NSDictionary * sessionStatus) {}];
    
  } else {
    ConfirmChoosedCard *confirmChoosedCardController = (ConfirmChoosedCard *) controller;
    _cardKBinding = confirmChoosedCardController.cardKBinding;
    [self _processBindingFormRequest:confirmChoosedCardController
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

// PaymentFlowDelegate
- (void)encodeWithCoder:(nonnull NSCoder *)coder {
  
}

- (void)cancelled {
  
}

- (void)completedWithTransactionStatus:(NSString *) transactionStatus {
  NSString *threeDSServerTransId = [NSString stringWithFormat:@"%@%@", @"threeDSServerTransId=", RequestParams.shared.threeDSServerTransId];

  NSString *URL = [NSString stringWithFormat:@"%@%@", _url, @"/rest/finish3dsVer2PaymentAnonymous.do"];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
  request.HTTPMethod = @"POST";

  NSData *postData = [threeDSServerTransId dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
  [request setHTTPBody:postData];

  NSURLSession *session = [NSURLSession sharedSession];

  NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    dispatch_async(dispatch_get_main_queue(), ^{
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
      if(httpResponse.statusCode != 200) {
        [self _sendError];
        return;
      }

      NSError *parseError = nil;
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

      NSString *redirect = [responseDictionary objectForKey:@"redirect"];
      NSString *errorMessage = [responseDictionary objectForKey:@"error"];
      NSInteger errorCode = [responseDictionary[@"errorCode"] integerValue];
      NSInteger remainingSecs = [responseDictionary[@"remainingSecs"] integerValue];
        
      if (errorCode != 0) {
        self->_cardKPaymentError.massage = errorMessage;
        [self->_cardKPaymentFlowDelegate didErrorPaymentFlow: self->_cardKPaymentError];
      } else if (redirect == nil || remainingSecs > 0 ) {
        // Повторный запуск проекта
      } else {
        [self _getFinishSessionStatusRequest];
      }
    });
  }];
  [dataTask resume];
}

- (void)errorEventReceived {
  
}

@end
