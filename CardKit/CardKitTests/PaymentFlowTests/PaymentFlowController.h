//
//  PaymentFlowController.h
//  CardKit
//
//  Created by Alex Korotkov on 4/5/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "CardKit.h"
#import "CardKPaymentSessionStatus.h"

@interface PaymentFlowController: CardKPaymentFlowController
  @property (weak, nonatomic) id<CardKDelegate> cKitDelegate;

  @property (nullable) XCTestExpectation* sendErrorExpectation;
  - (void) _sendError;

  @property (nullable) XCTestExpectation* sendRedirectErrorExpectation;
  - (void)_sendRedirectError;

  @property (nullable) XCTestExpectation* moveChoosePaymentMethodControllerExpectation;
  - (void)_moveChoosePaymentMethodController;

  - (void)_getSessionStatusRequest:(void (^_Nullable)(CardKPaymentSessionStatus *)) handler;
@end
