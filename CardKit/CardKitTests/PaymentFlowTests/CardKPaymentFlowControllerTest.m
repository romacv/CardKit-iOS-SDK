//
//  NSObject+CardKPaymentFlowController.m
//  CardKitTests
//
//  Created by Alex Korotkov on 4/5/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PaymentFlowController.h"
#import <ThreeDSSDK/ThreeDSSDK.h>
@interface CardKPaymentFlowControllerTest: XCTestCase<PaymentFlowControllerDelegate>

@end

@interface OptionView: UIView
  - (void) handleTapWithSender:(UITapGestureRecognizer *) sender;
@end

@interface WKWebViewTest: NSObject
- (void)evaluateJavaScript:(NSString *)javaScriptString
         completionHandler:(void (^)(id, NSError *error))completionHandler;
@end

const NSInteger __doneButtonTag = 10000;
const NSInteger __resendSMSButtonTag = 10001;
const NSInteger __cancelButtonTag = 10002;
const NSInteger __doneButtonInGroupFlowTag = 10003;

const NSInteger __SMSCodeTextFieldTag = 20000;
const NSInteger __optionGroupViewTag = 20001;
const NSInteger __webViewTag = 20002;

typedef NS_ENUM(NSUInteger, ActionTypeInForm) {
  ActionTypeCancelFlow = 0,
  ActionTypeFillOTPForm = 1,
  ActionTypeFillMultiSelectForm = 2,
  ActionTypeFillWebViewForm = 3,
  ActionTypeFillOTPFormWithIncorrectCode = 4
};

@implementation CardKPaymentFlowControllerTest {
  int actionTypeInForm;
  PaymentFlowController *payment;
}

- (void)setUp {
  payment = [[PaymentFlowController alloc] init];
  
  payment.delegate = self;
  payment.url = @"https://web.rbsdev.com/soyuzpayment";
  payment.primaryColor = UIColor.systemBlueColor;
  payment.textDoneButtonColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.00];
  payment.headerLabel = @"Custom header label";
  
  CardKConfig.shared.language = @"ru";
  CardKConfig.shared.bindingCVCRequired = YES;
  CardKConfig.shared.bindings = @[];
  CardKConfig.shared.isTestMod = true;
  CardKConfig.shared.mrBinApiURL = @"https://mrbin.io/bins/display";
  CardKConfig.shared.mrBinURL = @"https://mrbin.io/bins/";
  CardKConfig.shared.pubKey = @"-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAws0r6I8emCsURXfuQcU2c9mwUlOiDjuCZ/f+EdadA4vq/kYt3w6kC5TUW97Fm/HTikkHd0bt8wJvOzz3T0O4so+vBaC0xjE8JuU1eCd+zUX/plw1REVVii1RNh9gMWW1fRNu6KDNSZyfftY2BTcP1dbE1itpXMGUPW+TOk3U9WP4vf7pL/xIHxCsHzb0zgmwShm3D46w7dPW+HO3PEHakSWV9bInkchOvh/vJBiRw6iadAjtNJ4+EkgNjHwZJDuo/0bQV+r9jeOe+O1aXLYK/s1UjRs5T4uGeIzmdLUKnu4eTOQ16P6BHWAjyqPnXliYIKfi+FjZxyWEAlYUq+CRqQIDAQAB-----END PUBLIC KEY-----";
}

- (void)tearDown {
}

- (void)testConvertBindingItemToCardKBinding {
  NSDictionary *binding = @{@"cardHolder": @"Alex", @"createdDate": @"1618475680663", @"id": @"17900526-aaf8-7672-8d99-288600c305c8", @"isMaestro": @"0", @"label": @"577777**7775 12/24", @"payerEmail": @"test@test.ru", @"payerPhone": @"", @"paymentSystem": @"MASTERCARD"};
  
  CardKBinding *cardKBinding = [[CardKBinding alloc] init];
  cardKBinding.bindingId = binding[@"id"];
  cardKBinding.paymentSystem = binding[@"paymentSystem"];
  cardKBinding.cardNumber = @"577777**7775";
  cardKBinding.expireDate = @"12/24";
  
  NSArray<CardKBinding *> *prepareCardKBinding = @[cardKBinding];
  NSArray<CardKBinding *> *cardKBindings  = [payment _convertBindingItemsToCardKBinding:@[binding]];
  
  XCTAssertEqualObjects(cardKBindings[0].bindingId, prepareCardKBinding[0].bindingId);
  XCTAssertEqualObjects(cardKBindings[0].paymentSystem, prepareCardKBinding[0].paymentSystem);
  XCTAssertEqualObjects(cardKBindings[0].cardNumber, prepareCardKBinding[0].cardNumber);
  XCTAssertEqualObjects(cardKBindings[0].expireDate, prepareCardKBinding[0].expireDate);
}

- (void)testPaymentFlowWithNewCard {
  actionTypeInForm = ActionTypeFillOTPForm;
  payment.doUseNewCard = YES;
  payment.moveChoosePaymentMethodControllerExpectation = [self expectationWithDescription:@"moveChoosePaymentMethodControllerExpectation"];
  payment.runChallangeExpectation = [self expectationWithDescription:@"runChallangeExpectation"];
  payment.didCompleteWithTransactionStatusExpectation = [self expectationWithDescription:@"didCompleteWithTransactionStatusExpectation"];
  payment.getFinishSessionStatusRequestExpectation = [self expectationWithDescription:@"getFinishSessionStatusRequestExpectation"];
  payment.getFinishedPaymentInfoExpectation = [self expectationWithDescription:@"getFinishedPaymentInfoExpectation"];
  
  [self _registerOrderWithAmount: @"2000" callback:^() {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self _runCardKPaymentFlow];
    });
  }];
  
  [self waitForExpectations:@[
      payment.moveChoosePaymentMethodControllerExpectation,
      payment.runChallangeExpectation,
      payment.didCompleteWithTransactionStatusExpectation,
      payment.getFinishSessionStatusRequestExpectation,
      payment.getFinishedPaymentInfoExpectation] timeout:20];
}

- (void)testPaymentFlowWithBinding {
  actionTypeInForm = ActionTypeFillOTPForm;
  payment.doUseNewCard = NO;
  
  payment.moveChoosePaymentMethodControllerExpectation = [self expectationWithDescription:@"moveChoosePaymentMethodControllerExpectation"];
  payment.processBindingFormRequestExpectation = [self expectationWithDescription:@"processBindingFormRequestExpectation"];
  payment.processBindingFormRequestStep2Expectation = [self expectationWithDescription:@"processBindingFormRequestStep2Expectation"];
  payment.runChallangeExpectation = [self expectationWithDescription:@"runChallangeExpectation"];
  payment.didCompleteWithTransactionStatusExpectation = [self expectationWithDescription:@"didCompleteWithTransactionStatusExpectation"];
  payment.getFinishSessionStatusRequestExpectation = [self expectationWithDescription:@"getFinishSessionStatusRequestExpectation"];
  payment.getFinishedPaymentInfoExpectation = [self expectationWithDescription:@"getFinishedPaymentInfoExpectation"];
  
  [self _registerOrderWithAmount: @"2000" callback:^() {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self _runCardKPaymentFlow];
    });
  }];
  
  [self waitForExpectations:@[
      payment.moveChoosePaymentMethodControllerExpectation,
      payment.processBindingFormRequestExpectation,
      payment.processBindingFormRequestStep2Expectation,
      payment.runChallangeExpectation,
      payment.didCompleteWithTransactionStatusExpectation,
      payment.getFinishSessionStatusRequestExpectation,
      payment.getFinishedPaymentInfoExpectation] timeout:20];
}

- (void)testPaymentFlowWithNewCardWithIncorrectSecureCode {
  actionTypeInForm = ActionTypeFillOTPForm;
  payment.doUseNewCard = YES;
  payment.bindingSecureCode = @"666";
  
  payment.moveChoosePaymentMethodControllerExpectation = [self expectationWithDescription:@"moveChoosePaymentMethodControllerExpectation"];
  payment.moveChoosePaymentMethodControllerExpectation.expectedFulfillmentCount = 2;
  
  payment.runChallangeExpectation = [self expectationWithDescription:@"runChallangeExpectation"];
  payment.runChallangeExpectation.expectedFulfillmentCount = 2;
  
  payment.sendErrorWithCardPaymentErrorExpectation = [self expectationWithDescription:@"sendErrorWithCardPaymentErrorExpectation"];
  
  payment.didCompleteWithTransactionStatusExpectation = [self expectationWithDescription:@"didCompleteWithTransactionStatusExpectation"];
  payment.didCompleteWithTransactionStatusExpectation.expectedFulfillmentCount = 2;
  
  payment.getFinishSessionStatusRequestExpectation = [self expectationWithDescription:@"getFinishSessionStatusRequestExpectation"];
  payment.getFinishSessionStatusRequestExpectation.expectedFulfillmentCount = 2;
  
  payment.getFinishedPaymentInfoExpectation = [self expectationWithDescription:@"getFinishedPaymentInfoExpectation"];
  payment.getFinishedPaymentInfoExpectation.expectedFulfillmentCount = 1;
  
  [self _registerOrderWithAmount: @"2000" callback:^() {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self _runCardKPaymentFlow];
    });
  }];
  
  [self waitForExpectations:@[
      payment.moveChoosePaymentMethodControllerExpectation,
      payment.runChallangeExpectation,
      payment.didCompleteWithTransactionStatusExpectation,
      payment.getFinishSessionStatusRequestExpectation,
      payment.getFinishedPaymentInfoExpectation,
      payment.sendErrorWithCardPaymentErrorExpectation] timeout:40];
}

- (void)testPaymentFlowWithBindingWithIncorrectSecureCode {
  actionTypeInForm = ActionTypeFillOTPForm;
  payment.doUseNewCard = NO;
  payment.bindingSecureCode = @"666";
  
  payment.moveChoosePaymentMethodControllerExpectation = [self expectationWithDescription:@"moveChoosePaymentMethodControllerExpectation"];
  payment.moveChoosePaymentMethodControllerExpectation.expectedFulfillmentCount = 2;
  
  payment.processBindingFormRequestExpectation = [self expectationWithDescription:@"processBindingFormRequestExpectation"];
  payment.processBindingFormRequestExpectation.expectedFulfillmentCount = 2;
  
  payment.sendErrorWithCardPaymentErrorExpectation = [self expectationWithDescription:@"sendErrorWithCardPaymentErrorExpectation"];
  
  payment.processBindingFormRequestStep2Expectation = [self expectationWithDescription:@"processBindingFormRequestStep2Expectation"];
  payment.processBindingFormRequestStep2Expectation.expectedFulfillmentCount = 2;
  
  payment.runChallangeExpectation = [self expectationWithDescription:@"runChallangeExpectation"];
  payment.runChallangeExpectation.expectedFulfillmentCount = 2;
  
  payment.didCompleteWithTransactionStatusExpectation = [self expectationWithDescription:@"didCompleteWithTransactionStatusExpectation"];
  payment.didCompleteWithTransactionStatusExpectation.expectedFulfillmentCount = 2;
  
  payment.getFinishSessionStatusRequestExpectation = [self expectationWithDescription:@"getFinishSessionStatusRequestExpectation"];
  payment.getFinishSessionStatusRequestExpectation.expectedFulfillmentCount = 2;
  
  payment.getFinishedPaymentInfoExpectation = [self expectationWithDescription:@"getFinishedPaymentInfoExpectation"];
  payment.getFinishedPaymentInfoExpectation.expectedFulfillmentCount = 1;
  
  [self _registerOrderWithAmount: @"2000" callback:^() {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self _runCardKPaymentFlow];
    });
  }];
  
  [self waitForExpectations:@[
      payment.moveChoosePaymentMethodControllerExpectation,
      payment.processBindingFormRequestExpectation,
      payment.processBindingFormRequestStep2Expectation,
      payment.runChallangeExpectation,
      payment.didCompleteWithTransactionStatusExpectation,
      payment.getFinishSessionStatusRequestExpectation,
      payment.getFinishedPaymentInfoExpectation,
      payment.sendErrorWithCardPaymentErrorExpectation] timeout:40];
}

- (void)testCancelFlowWithBinding {
  actionTypeInForm = ActionTypeCancelFlow;
  payment.doUseNewCard = NO;
  
  payment.moveChoosePaymentMethodControllerExpectation = [self expectationWithDescription:@"moveChoosePaymentMethodControllerExpectation"];
  payment.processBindingFormRequestExpectation = [self expectationWithDescription:@"processBindingFormRequestExpectation"];
  payment.processBindingFormRequestStep2Expectation = [self expectationWithDescription:@"processBindingFormRequestStep2Expectation"];
  payment.didCancelExpectation = [self expectationWithDescription:@"didCancelExpectation"];
  
  [self _registerOrderWithAmount: @"2000" callback:^() {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self _runCardKPaymentFlow];
    });
  }];
  
  [self waitForExpectations:@[
      payment.moveChoosePaymentMethodControllerExpectation,
      payment.processBindingFormRequestExpectation,
      payment.processBindingFormRequestStep2Expectation,
      payment.didCancelExpectation] timeout:20];
}

- (void)testCancelFlowWhenSendIncorrectCodeFreeTimes {
  actionTypeInForm = ActionTypeFillOTPFormWithIncorrectCode;
  payment.doUseNewCard = NO;
  
  payment.moveChoosePaymentMethodControllerExpectation = [self expectationWithDescription:@"moveChoosePaymentMethodControllerExpectation"];
  payment.processBindingFormRequestExpectation = [self expectationWithDescription:@"processBindingFormRequestExpectation"];
  payment.processBindingFormRequestStep2Expectation = [self expectationWithDescription:@"processBindingFormRequestStep2Expectation"];
  payment.didCancelExpectation = [self expectationWithDescription:@"didCancelExpectation"];
  
  [self _registerOrderWithAmount: @"2000" callback:^() {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self _runCardKPaymentFlow];
    });
  }];
  
  [self waitForExpectations:@[
      payment.moveChoosePaymentMethodControllerExpectation,
      payment.processBindingFormRequestExpectation,
      payment.processBindingFormRequestStep2Expectation,
      payment.didCancelExpectation] timeout:50];
}

- (void)testMultiSelectFlowWithNewCard{
  actionTypeInForm = ActionTypeFillMultiSelectForm;
  payment.doUseNewCard = YES;

  payment.moveChoosePaymentMethodControllerExpectation = [self expectationWithDescription:@"moveChoosePaymentMethodControllerExpectation"];
  payment.runChallangeExpectation = [self expectationWithDescription:@"runChallangeExpectation"];
  payment.didCompleteWithTransactionStatusExpectation = [self expectationWithDescription:@"didCompleteWithTransactionStatusExpectation"];
  payment.getFinishSessionStatusRequestExpectation = [self expectationWithDescription:@"getFinishSessionStatusRequestExpectation"];
  payment.getFinishedPaymentInfoExpectation = [self expectationWithDescription:@"getFinishedPaymentInfoExpectation"];

  [self _registerOrderWithAmount: @"222" callback:^() {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self _runCardKPaymentFlow];
    });
  }];
  
  [self waitForExpectations:@[
      payment.moveChoosePaymentMethodControllerExpectation,
      payment.runChallangeExpectation,
      payment.didCompleteWithTransactionStatusExpectation,
      payment.getFinishSessionStatusRequestExpectation,
      payment.getFinishedPaymentInfoExpectation] timeout:20];
}

- (void)testSingleSelectFlowWithNewCard{
  actionTypeInForm = ActionTypeFillMultiSelectForm;
  payment.doUseNewCard = YES;

  payment.moveChoosePaymentMethodControllerExpectation = [self expectationWithDescription:@"moveChoosePaymentMethodControllerExpectation"];
  payment.runChallangeExpectation = [self expectationWithDescription:@"runChallangeExpectation"];
  payment.didCompleteWithTransactionStatusExpectation = [self expectationWithDescription:@"didCompleteWithTransactionStatusExpectation"];
  payment.getFinishSessionStatusRequestExpectation = [self expectationWithDescription:@"getFinishSessionStatusRequestExpectation"];
  payment.getFinishedPaymentInfoExpectation = [self expectationWithDescription:@"getFinishedPaymentInfoExpectation"];

  [self _registerOrderWithAmount: @"111" callback:^() {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self _runCardKPaymentFlow];
    });
  }];

  [self waitForExpectations:@[
      payment.moveChoosePaymentMethodControllerExpectation,
      payment.runChallangeExpectation,
      payment.didCompleteWithTransactionStatusExpectation,
      payment.getFinishSessionStatusRequestExpectation,
      payment.getFinishedPaymentInfoExpectation] timeout:20];
}

- (void)testWebViewFlowWithNewCard{
  actionTypeInForm = ActionTypeFillWebViewForm;
  payment.doUseNewCard = YES;

  payment.moveChoosePaymentMethodControllerExpectation = [self expectationWithDescription:@"moveChoosePaymentMethodControllerExpectation"];
  payment.runChallangeExpectation = [self expectationWithDescription:@"runChallangeExpectation"];
  payment.didCompleteWithTransactionStatusExpectation = [self expectationWithDescription:@"didCompleteWithTransactionStatusExpectation"];
  payment.getFinishSessionStatusRequestExpectation = [self expectationWithDescription:@"getFinishSessionStatusRequestExpectation"];
  payment.getFinishedPaymentInfoExpectation = [self expectationWithDescription:@"getFinishedPaymentInfoExpectation"];

  [self _registerOrderWithAmount: @"333" callback:^() {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self _runCardKPaymentFlow];
    });
  }];

  [self waitForExpectations:@[
      payment.moveChoosePaymentMethodControllerExpectation,
      payment.runChallangeExpectation,
      payment.didCompleteWithTransactionStatusExpectation,
      payment.getFinishSessionStatusRequestExpectation,
      payment.getFinishedPaymentInfoExpectation] timeout:20];
}

- (void)testUnbindCard {
  CardKConfig.shared.isEditBindingListMode = YES;
  payment.unbindCard = YES;
  payment.moveChoosePaymentMethodControllerExpectation = [self expectationWithDescription:@"moveChoosePaymentMethodControllerExpectation"];
  
  payment.unbindCardExpectation = [self expectationWithDescription:@"unbindCardExpectation"];


  [self _registerOrderWithAmount: @"333" callback:^() {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self _runCardKPaymentFlow];
    });
  }];

  [self waitForExpectations:@[
      payment.moveChoosePaymentMethodControllerExpectation,
      payment.unbindCardExpectation
  ] timeout:20];
}

- (void)_fillOTPForm {
  UIWindow *window = UIApplication.sharedApplication.windows[1];
  UITextField *textField = (UITextField *)[window.rootViewController.view viewWithTag:__SMSCodeTextFieldTag];

  [textField insertText:@"123456"];
  
  UIButton *confirmButton = (UIButton *)[window.rootViewController.view viewWithTag:__doneButtonTag];
  
  [confirmButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)_fillOTPFormWithIncorrectCode {
  UIWindow *window = UIApplication.sharedApplication.windows[1];
  UITextField *textField = (UITextField *)[window.rootViewController.view viewWithTag:__SMSCodeTextFieldTag];

  [textField insertText:@"1"];
  
  UIButton *confirmButton = (UIButton *)[window.rootViewController.view viewWithTag:__doneButtonTag];
  
  [confirmButton sendActionsForControlEvents:UIControlEventTouchUpInside];
  
  if (confirmButton == nil) {
    return;
  }
  
  dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC));

  dispatch_after(timer, dispatch_get_main_queue(), ^(void){
    [self _fillOTPFormWithIncorrectCode];
  });
}

- (void)_fillMultiSelectForm {
  UIWindow *window = UIApplication.sharedApplication.windows[1];
  UIView *uiStackView = (UIView *)[window.rootViewController.view viewWithTag:__optionGroupViewTag];

  NSArray<OptionView *> * checkboxs = [uiStackView subviews];
  
  OptionView *checkbox = checkboxs[0];
  
  UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] init];
  [gesture setValue:@(UIGestureRecognizerStateEnded) forKey:@"state"];
  
  [checkbox handleTapWithSender:gesture];
  
  UIButton *confirmButton = (UIButton *)[window.rootViewController.view viewWithTag:__doneButtonInGroupFlowTag];
  
  
  [confirmButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)_fillWebViewForm {
  UIWindow *window = UIApplication.sharedApplication.windows[1];
  WKWebViewTest *wkWebView = (WKWebViewTest *)[window.rootViewController.view viewWithTag:__webViewTag];
  
  [wkWebView evaluateJavaScript:@"document.getElementsByTagName('input')[0].value = 123456;document.getElementsByTagName('button')[0].click();" completionHandler:^(NSString *result, NSError *error)
  {
      NSLog(@"Error %@",error);
      NSLog(@"Result %@",result);
  }];
}


- (void)_cancelPaymentFlow {
  UIWindow *window = UIApplication.sharedApplication.windows[1];
 
  UIButton *confirmButton = (UIButton *)[window.rootViewController.view viewWithTag:__cancelButtonTag];
  
  [confirmButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)fillForm {
  dispatch_async(dispatch_get_main_queue(), ^{
    switch (self->actionTypeInForm) {
      case ActionTypeCancelFlow:
        [self _cancelPaymentFlow];
        break;
      case ActionTypeFillOTPForm:
        [self _fillOTPForm];
        break;
      case ActionTypeFillMultiSelectForm:
        [self _fillMultiSelectForm];
        break;
      case ActionTypeFillWebViewForm:
        [self _fillWebViewForm];
      case ActionTypeFillOTPFormWithIncorrectCode:
        [self _fillOTPFormWithIncorrectCode];
      default:
        break;
    }
  });
}

- (void)_registerOrderWithAmount:(NSString*) amount callback:(void (^)(void)) handler {
  NSString *amountParameter = [NSString stringWithFormat:@"%@%@", @"amount=", amount];
  NSString *userName = [NSString stringWithFormat:@"%@%@", @"userName=", @"3ds2-api"];
  NSString *password = [NSString stringWithFormat:@"%@%@", @"password=", @"testPwd"];
  NSString *returnUrl = [NSString stringWithFormat:@"%@%@", @"returnUrl=", @"returnUrl"];
  NSString *failUrl = [NSString stringWithFormat:@"%@%@", @"failUrl=", @"errors_ru.html"];
  NSString *email = [NSString stringWithFormat:@"%@%@", @"email=", @"test@test.ru"];
  NSString *clientId = [NSString stringWithFormat:@"%@%@", @"clientId=", @"clientId"];
  
  NSString *parameters = [NSString stringWithFormat:@"%@&%@&%@&%@&%@&%@&%@", amountParameter, userName, password, returnUrl, failUrl, email, clientId];

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
        
        handler();
      }
  }];
  [dataTask resume];
};

- (void)_runCardKPaymentFlow {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self->payment];
    UIApplication.sharedApplication.windows.firstObject.rootViewController = navController;
}
@end
