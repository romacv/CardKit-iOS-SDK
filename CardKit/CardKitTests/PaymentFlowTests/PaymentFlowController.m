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

@interface CardKPaymentFlowController (Test)
  - (void)_sePayment;
  - (void)_sendError;

  - (void)_sePaymentStep2;
  - (void)_sendRedirectError;
  - (void)_moveChoosePaymentMethodController;

- (void)_initSDK:(CardKCardView *) cardView cardOwner:(NSString *) cardOwner seToken:(NSString *) seToken callback: (void (^)(NSDictionary *)) handler;
- (void) _runChallange:(NSDictionary *) responseDictionary;

  - (void)_getSessionStatusRequest:(void (^_Nullable)(CardKPaymentSessionStatus *)) handler;
@end

@implementation PaymentFlowController: CardKPaymentFlowController
  - (void) _getSessionStatusRequest:(void (^)(CardKPaymentSessionStatus *)) handler {
    [super _getSessionStatusRequest:handler];
  }

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
    
    double delayInSeconds = 10.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      [self _fillForm];
    });
  }

  - (void) _fillForm {
    [_delegate fillForm];
  }

  - (void)_moveChoosePaymentMethodController {
    [super _moveChoosePaymentMethodController];
    
    CardKCardView *cardView = [[CardKCardView alloc] init];
    
    cardView.number = @"5777777777777775";
    cardView.secureCode = @"123";
    cardView.expirationDate = @"1224";
    
    NSString *seToken = [SeTokenGenerator generateSeTokenWithCardView: cardView];
    
    CardKViewControllerInher *cardKViewController = [[CardKViewControllerInher alloc] init];
    
    UITextField *ownetTextField = [[UITextField alloc] init];
    ownetTextField.text = @"Alex";
    cardKViewController.cardView = cardView;
    cardKViewController.ownerTextField = ownetTextField;
    
    self.cKitDelegate = self;
    
    [_cKitDelegate cardKitViewController:cardKViewController didCreateSeToken:seToken allowSaveBinding:YES isNewCard: YES];
  }
@end
