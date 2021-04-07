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

@interface CardKPaymentFlowController (Test)
  - (void)_sePayment;
  - (void)_sendError;

  - (void)_sendRedirectError;
  - (void)_moveChoosePaymentMethodController;

  - (void)_getSessionStatusRequest:(void (^_Nullable)(CardKPaymentSessionStatus *)) handler;
@end

@implementation PaymentFlowController: CardKPaymentFlowController
  - (void) _getSessionStatusRequest:(void (^)(CardKPaymentSessionStatus *)) handler {
    [super _getSessionStatusRequest:handler];
  }

  - (void)_sePayment{
    [super _sePayment];
    [self.sePaymentExpectation fulfill];
  }

  - (void)_sePaymentStep2 {
    [super _sePaymentStep2];
    [self.sePaymentStep2Expectation fulfill];
  }

  - (void)_sendError {
    [super _sendError];
    [self.sendErrorExpectation fulfill];
  }

  - (void)_sendRedirectError {
    [super _sendRedirectError];
    [self.sendRedirectErrorExpectation fulfill];
  }

  - (void)_moveChoosePaymentMethodController {
    [super _moveChoosePaymentMethodController];
    
    CardKCardView *cardView = [[CardKCardView alloc] init];
    
    cardView.number = @"4777777777777778";
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
