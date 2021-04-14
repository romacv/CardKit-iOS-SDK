//
//  NSObject+CardKPaymentFlowController.m
//  CardKitTests
//
//  Created by Alex Korotkov on 4/5/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PaymentFlowController.h"

@interface CardKPaymentFlowControllerTest: XCTestCase<PaymentFlowControllerDelegate>

@end

const NSInteger __doneButtonTag = 10000;
const NSInteger __resendSMSButtonTag = 10001;
const NSInteger __cancelButtonTag = 10002;
const NSInteger __SMSCodeTextFieldTag = 20000;

@implementation CardKPaymentFlowControllerTest {
  PaymentFlowController *payment;
}

- (void)setUp {
  CardKConfig.shared.language = @"ru";
  CardKConfig.shared.bindingCVCRequired = YES;
  CardKConfig.shared.bindings = @[];
  CardKConfig.shared.isTestMod = true;
  CardKConfig.shared.mrBinApiURL = @"https://mrbin.io/bins/display";
  CardKConfig.shared.mrBinURL = @"https://mrbin.io/bins/";
  CardKConfig.shared.pubKey = @"-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAws0r6I8emCsURXfuQcU2c9mwUlOiDjuCZ/f+EdadA4vq/kYt3w6kC5TUW97Fm/HTikkHd0bt8wJvOzz3T0O4so+vBaC0xjE8JuU1eCd+zUX/plw1REVVii1RNh9gMWW1fRNu6KDNSZyfftY2BTcP1dbE1itpXMGUPW+TOk3U9WP4vf7pL/xIHxCsHzb0zgmwShm3D46w7dPW+HO3PEHakSWV9bInkchOvh/vJBiRw6iadAjtNJ4+EkgNjHwZJDuo/0bQV+r9jeOe+O1aXLYK/s1UjRs5T4uGeIzmdLUKnu4eTOQ16P6BHWAjyqPnXliYIKfi+FjZxyWEAlYUq+CRqQIDAQAB-----END PUBLIC KEY-----";

  payment = [[PaymentFlowController alloc] init];  
  UIApplication.sharedApplication.windows.firstObject.rootViewController = payment;
}

- (void)tearDown {
}

- (void)testPaymentFlowWithNewCard {
  payment.delegate = self;
  
  payment.userName = @"3ds2-api";
  payment.password = @"testPwd";

  payment.moveChoosePaymentMethodControllerExpectation = [self expectationWithDescription:@"moveChoosePaymentMethodControllerExpectation"];

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
        
        
        [self->payment _getSessionStatusRequest:^(CardKPaymentSessionStatus * sessionStatus) {
          
        }];
      }
  }];
  [dataTask resume];
  
  [self waitForExpectations:@[payment.moveChoosePaymentMethodControllerExpectation] timeout:200];
}

- (void)fillForm {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIWindow *window = UIApplication.sharedApplication.windows[1];
    UITextField *textField = (UITextField *)[window.rootViewController.view viewWithTag:__SMSCodeTextFieldTag];

    [textField insertText:@"123456"];
    
    UIButton *confirmButton = (UIButton *)[window.rootViewController.view viewWithTag:__doneButtonTag];
    
    [confirmButton sendActionsForControlEvents:UIControlEventTouchUpInside];
  });
}
@end
