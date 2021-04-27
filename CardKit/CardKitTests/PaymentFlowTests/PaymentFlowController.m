//
//  NSObject+PaymentFlowController.m
//  CardKitTests
//
//  Created by Alex Korotkov on 4/5/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardKit.h"

#import "PaymentFlowController.h"
#import "CardKPaymentSessionStatus.h"
#import "SeTokenGenerator.h"
#import "CardKViewControllerInher.h"
#import "CardKPaymentSessionStatus.h"
#import "CardKCardView.h"
#import "ConfirmChoosedCard.h"
#import "CardKSwitchView.h"

@interface CardKPaymentFlowController (Test)
  - (void)_sePayment;
  - (void)_sendError;

  - (void)_sePaymentStep2;
  - (void)_sendRedirectError;
  - (void)_moveChoosePaymentMethodController;
  - (void)didCompleteWithTransactionStatus:(NSString *) transactionStatus;
  - (void)_getFinishSessionStatusRequest;
  - (void)_getFinishedPaymentInfo;
  - (void)didCancel;

  - (void)_initSDK:(CardKCardView *) cardView cardOwner:(NSString *) cardOwner seToken:(NSString *) seToken callback: (void (^)(NSDictionary *)) handler;
  - (void) _runChallange:(NSDictionary *) responseDictionary;

  - (void)_getSessionStatusRequest;

  - (NSArray<CardKBinding *> *) _convertBindingItemsToCardKBinding:(NSArray<NSDictionary *> *) bindingItems;

  - (void) _processBindingFormRequest:(ConfirmChoosedCard *) choosedCard callback: (void (^)(NSDictionary *)) handler;
  - (void) _processBindingFormRequestStep2:(ConfirmChoosedCard *) choosedCard callback: (void (^)(NSDictionary *)) handler;
@end

@implementation PaymentFlowController: CardKPaymentFlowController
  - (void) _getSessionStatusRequest {
    [super _getSessionStatusRequest];
  }

//  - (void)viewDidAppear:(BOOL)animated {
//
//  }

  - (void)_sendError {
    [super _sendError];
    [self.sendErrorExpectation fulfill];
  }

  - (void)_sendRedirectError {
    [super _sendRedirectError];
    [self.sendRedirectErrorExpectation fulfill];
  }

  - (void)_initSDK:(CardKCardView *) cardView cardOwner:(NSString *) cardOwner seToken:(NSString *) seToken callback: (void (^)(NSDictionary *)) handler {
    
    [super _initSDK:(CardKCardView *) cardView cardOwner:(NSString *) cardOwner seToken:(NSString *) seToken callback: (void (^)(NSDictionary *)) handler];
  }

  - (void) _runChallange:(NSDictionary *) responseDictionary {
    [super _runChallange:(NSDictionary *) responseDictionary];
    
    [self.runChallangeExpectation fulfill];
    [NSThread  sleepForTimeInterval:7.0f];
    [self _fillForm];
  }

  - (void) _fillForm {
    [_delegate fillForm];
  }

  - (void)_moveChoosePaymentMethodController {
    [super _moveChoosePaymentMethodController];
    
    double delayInSeconds = 1.0;

    dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));

    dispatch_after(timer, dispatch_get_main_queue(), ^(void){
      if (self->_doUseNewCard) {
        [self _runNewCardFlow];
      } else {
        [self _runBindingFlow];
      }
      
      [self.moveChoosePaymentMethodControllerExpectation fulfill];
    });
  }

  - (void) _runNewCardFlow {
    NSInteger newCardButtonTag = 20000;
    NSInteger cardNumberTextFieldTag = 30000;
    NSInteger expireDateTextFieldTag = 30001;
    NSInteger secureCodeTextFieldTag = 30002;
    NSInteger cardOwnerTextFieldTag = 30003;
    NSInteger switchViewTag = 30004;
    NSInteger payButtonTag = 30005;
    
    UIWindow *window = UIApplication.sharedApplication.windows[0];
    UIButton *confirmButton = (UIButton *)[window.rootViewController.view viewWithTag:newCardButtonTag];
    
    [confirmButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    
    double delayInSeconds = 2.0;

    dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));

    dispatch_after(timer, dispatch_get_main_queue(), ^(void){
      UIWindow *window = UIApplication.sharedApplication.windows[0];
      
      UITextField *cardNumberTextField = (UITextField *)[window.rootViewController.view viewWithTag:cardNumberTextFieldTag];
      
      [cardNumberTextField setText:@"5777777777777775"];
      
      UITextField *expireDateTextField = (UITextField *)[window.rootViewController.view viewWithTag:expireDateTextFieldTag];
      
      [expireDateTextField setText:@"1224"];
      
      UITextField *secureCodeTextField = (UITextField *)[window.rootViewController.view viewWithTag:secureCodeTextFieldTag];
      
      [secureCodeTextField setText:@"123"];
      
      UITextField *cardOwnerTextField = (UITextField *)[window.rootViewController.view viewWithTag:cardOwnerTextFieldTag];
      
      [cardOwnerTextField setText:@"Alex Korotkov"];
      
      CardKSwitchView *switchView = (CardKSwitchView *)[window.rootViewController.view viewWithTag:switchViewTag];
      
      switchView.isSaveBinding = YES;
      
      UIButton *payButton = (UIButton *)[window.rootViewController.view viewWithTag:payButtonTag];

      [payButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    });
  }

  - (void) _runBindingFlow {
    ConfirmChoosedCard *confirmChoosedCardController = [[ConfirmChoosedCard alloc] init];
    confirmChoosedCardController.cKitDelegate = self;
    CardKBinding *cardKBinding = CardKConfig.shared.bindings[0];
    
    if (CardKConfig.shared.bindingCVCRequired) {
      cardKBinding.secureCode = @"123";
    }
    
    self.cKitDelegate = self;
    NSString *seToken = [SeTokenGenerator generateSeTokenWithBinding:cardKBinding];
    
    confirmChoosedCardController.cardKBinding = cardKBinding;
    
    [_cKitDelegate cardKitViewController:confirmChoosedCardController didCreateSeToken:seToken allowSaveBinding:NO isNewCard: NO];
  }

  - (void)didCompleteWithTransactionStatus:(NSString *) transactionStatus{
    [super didCompleteWithTransactionStatus:transactionStatus];
    [self.didCompleteWithTransactionStatusExpectation fulfill];
  }

  - (void)_getFinishSessionStatusRequest {
    [super _getFinishSessionStatusRequest];
    [self.getFinishSessionStatusRequestExpectation fulfill];
  }

  - (void)_getFinishedPaymentInfo {
    [super _getFinishedPaymentInfo];
    [self.getFinishedPaymentInfoExpectation fulfill];
  }

  - (void) _processBindingFormRequest:(ConfirmChoosedCard *) choosedCard callback: (void (^)(NSDictionary *)) handler {
    [super _processBindingFormRequest:choosedCard callback:handler];
    [self.processBindingFormRequestExpectation fulfill];
  }

  - (void) _processBindingFormRequestStep2:(ConfirmChoosedCard *) choosedCard callback: (void (^)(NSDictionary *)) handler {
    [super _processBindingFormRequestStep2:choosedCard callback:handler];
    [self.processBindingFormRequestStep2Expectation fulfill];
  }

  - (void)didCancel {
    [super didCancel];
    
    [self.didCancelExpectation fulfill];
  }

  - (NSArray<CardKBinding *> *) _convertBindingItemsToCardKBinding:(NSArray<NSDictionary *> *) bindingItems {
    NSArray<CardKBinding *> *cardKBindings = [super _convertBindingItemsToCardKBinding:bindingItems];
    return  cardKBindings;
  }
@end
