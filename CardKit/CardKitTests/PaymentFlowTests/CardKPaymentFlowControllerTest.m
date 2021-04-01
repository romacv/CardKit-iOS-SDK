//
//  NSObject+CardKPaymentFlowController.m
//  CardKitTests
//
//  Created by Alex Korotkov on 4/5/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PaymentFlowController.h"

@interface CardKPaymentFlowControllerTest: XCTestCase

@end

@implementation CardKPaymentFlowControllerTest {
}

- (void)setUp {
    CardKConfig.shared.language = @"ru";
    CardKConfig.shared.bindingCVCRequired = YES;
    CardKConfig.shared.bindings = @[];
    CardKConfig.shared.isTestMod = true;
    CardKConfig.shared.mrBinApiURL = @"https://mrbin.io/bins/display";
    CardKConfig.shared.mrBinURL = @"https://mrbin.io/bins/";
    CardKConfig.shared.pubKey = @"-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAws0r6I8emCsURXfuQcU2c9mwUlOiDjuCZ/f+EdadA4vq/kYt3w6kC5TUW97Fm/HTikkHd0bt8wJvOzz3T0O4so+vBaC0xjE8JuU1eCd+zUX/plw1REVVii1RNh9gMWW1fRNu6KDNSZyfftY2BTcP1dbE1itpXMGUPW+TOk3U9WP4vf7pL/xIHxCsHzb0zgmwShm3D46w7dPW+HO3PEHakSWV9bInkchOvh/vJBiRw6iadAjtNJ4+EkgNjHwZJDuo/0bQV+r9jeOe+O1aXLYK/s1UjRs5T4uGeIzmdLUKnu4eTOQ16P6BHWAjyqPnXliYIKfi+FjZxyWEAlYUq+CRqQIDAQAB-----END PUBLIC KEY-----";
//

//
//    PaymentFlowController.requestParams.amount = @"2000";
//    PaymentFlowController.requestParams.userName = @"3ds2-api";
//    PaymentFlowController.requestParams.password = @"testPwd";
//    PaymentFlowController.requestParams.returnUrl = @"../merchants/rbs/finish.html";
//    PaymentFlowController.requestParams.failUrl = @"errors_ru.html";
//    PaymentFlowController.requestParams.email = @"test@test.ru";
//    PaymentFlowController.requestParams.text = @"DE DE";
//    PaymentFlowController.requestParams.threeDSSDK = @"true";
//    PaymentFlowController.requestParams.cliendId = @"clientId";
//    _button.setTitle("Начать Payement flow", for: .normal);
//    _button.frame = CGRect(x: 0, y: 0, width: 200, height: 100);
//    _button.center = CGPoint(x: self.view.bounds.size.width / 2, y: self.view.bounds.size.height / 2);
//    _button.addTarget(self, action: #selector(_pressedButton), for: .touchDown);
}

- (void)tearDown {
}

- (void)testRequest {
  XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
  PaymentFlowController *payment = [[PaymentFlowController alloc] init];
  payment.userName = @"3ds2-api";
  payment.password = @"testPwd";
  
  NSString *amount = [NSString stringWithFormat:@"%@%@", @"amount=", @"2000"];
  NSString *userName = [NSString stringWithFormat:@"%@%@", @"userName=", @"3ds2-api"];
  NSString *password = [NSString stringWithFormat:@"%@%@", @"password=", @"testPwd"];
  NSString *returnUrl = [NSString stringWithFormat:@"%@%@", @"returnUrl=", @"../merchants/rbs/finish.html"];
  NSString *failUrl = [NSString stringWithFormat:@"%@%@", @"failUrl=", @"errors_ru.html"];
  NSString *email = [NSString stringWithFormat:@"%@%@", @"email=", @"test@test.ru"];
  
  NSString *parameters = [NSString stringWithFormat:@"%@&%@&%@&%@&%@&%@", amount, userName, password, returnUrl, failUrl, email];

  NSData *postData = [parameters dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
  
  NSString *url = @"https://web.rbsdev.com/soyuzpayment";
  
  NSString *URL = [NSString stringWithFormat:@"%@%@", url, @"/rest/register.do"];

  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];

  request.HTTPMethod = @"POST";
  [request setHTTPBody:postData];

  NSURLSession *session = [NSURLSession sharedSession];

  NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

      if(httpResponse.statusCode == 200) {
        NSError *parseError = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        
        CardKConfig.shared.mdOrder = responseDictionary[@"orderId"];
        
        [payment _getSessionStatusRequest:^(CardKPaymentSessionStatus * sessionStatus) {
//          [expectation fulfill];
        }];
      }
  }];
  [dataTask resume];
  
  
  [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
