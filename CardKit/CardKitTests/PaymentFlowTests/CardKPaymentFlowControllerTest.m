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
  
  CardKConfig.shared.rootCertificate = @"MIIF3jCCA8agAwIBAgIJAJMvvesjmDyhMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAk5MMSkwJwYDVQQKDCBVTCBUcmFuc2FjdGlvbiBTZWN1cml0eSBkaXZpc2lvbjEgMB4GA1UECwwXVUwgVFMgM0QtU2VjdXJlIFJPT1QgQ0ExIDAeBgNVBAMMF1VMIFRTIDNELVNlY3VyZSBST09UIENBMB4XDTE2MTIyMDEzNTAwNVoXDTM2MTIxNTEzNTAwNVowfDELMAkGA1UEBhMCTkwxKTAnBgNVBAoMIFVMIFRyYW5zYWN0aW9uIFNlY3VyaXR5IGRpdmlzaW9uMSAwHgYDVQQLDBdVTCBUUyAzRC1TZWN1cmUgUk9PVCBDQTEgMB4GA1UEAwwXVUwgVFMgM0QtU2VjdXJlIFJPT1QgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDEfY2xuLNjM8/3xrG6zd7FbuXHfCFieBERRuGQSLYMmES5khgjZteN59NeoDbIu3XNFCm4TR2TTpTdjmSFU8eD1E3+CXW9M6QczCoTu5OZh+h6yOYTMEkt+wDf3C0hZe/7jjy2PodiHHfue0SSZIJQ5Vm4sUkmEDbDbcSdRlFmxUe2ayX3tlYyxzmehZSGQ8jmVhnW0XWg36mQJNsvX2nLnBB58EE2GtGdX9bnKdXNfZTAPSrdSOnXMP97Gh+Rp1ud3YAncKO4ROziNSWjzDoa0OfwnaJWsx2I6dbWBPS5QHQZtn/w0iHaypXoTMeZUjIVSrKHx0ZAHr3v6pUH6oy+Q9B939ElOflOraFydalPk33i+txB6BzyLwlsDGZaeIm4Jblrqlx0QyzQZ/T0bafbflmFzodl6ZvAgSD4OnPo5AQ7Dl4E9XiIa85l0jlb71s+Xy/9pNBvspd3KHTt0b/J5j7szRkObtnikrFsEu55HcR9hz5fEofovcbkLBLvNCLcZrzmiDJhL6Wsrpo07UmY/9T/DBmjNOTiDKk3cy/N9sPjWeoauyCffsn6yLnNLZ4hsD+H7vCpoPMxyFxJaNOawv08ZF+17rqCcuRpfPU6UWLNCmCA1fSMYbctO28StS2o6acWF3nYdqgnVZCg0/H2M3b5TOeVmAuCQWDVAcoxgQIDAQABo2MwYTAdBgNVHQ4EFgQUmHZrhouCbMBgM5sAiDHv0vAbe/IwHwYDVR0jBBgwFoAUmHZrhouCbMBgM5sAiDHv0vAbe/IwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAYYwDQYJKoZIhvcNAQELBQADggIBAKRs5Voebxu4yzTMIc2nbwsoxe0ZdAiRU44An3j4gzwuqCic80K4YloiDOIAfRWG7HbF1bG37oSfQBhR0X2zvH/R8BVlSfaqovr78rGOyejNAstfGpmIaYT0zuE2jvjeR+YKmFCornhBojmALzYNQBbFpLUC45He8z5gB2jsnv7l0HRsXJGN11aUQvJgwjQTbc4FbAnWIWvAKcUtyeWiCBvFw/FTx23ZWMUW8jMrjdyiRan7dXc6n5vD/DV3tuM5rMWEA5x07D97DV/wvs/M8I8DL6mI2tEPfwVf/QIW4UONpnlAh6i9DevB+sKrqrilXE91pPOCmBXYXBxbAPW8M3Gh7k2VVW/jL4kqoB4HfH0IDHqIVeSXirSHxovK/fGIqjEuedLWzMMKTcEcYi7LVSqFvFYV/khimumAl8SFVpHQsQ7LvsKim1CsupkO+fUb44dkaUum6QC/iInk78KRgGV8XZA25yw4w/FJaWek0jnuCJk7V+77N6PGK0FxmSdrHRNzNSoTkma4PtZITnGNTGqXeTV0Hvr8ClbQfBWpqaZtKB8dTkhRCTUPasYZZLFtj2Y2WcXshMBAhEnBiCsoaIGz1xxcyFH4IoiC2GKbfi5pjXrHfRrtPIr1B4/uWMHxIttEFK3qK/3Vc1bjdX6H4IUWNV62P52kwdsMXNoQ55jw";
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
      payment.getFinishedPaymentInfoExpectation] timeout:30];
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
      payment.sendErrorWithCardPaymentErrorExpectation] timeout:60];
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
