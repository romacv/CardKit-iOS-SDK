//
//  PaymentFlowController.h
//  CardKit
//
//  Created by Alex Korotkov on 4/5/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CardKPaymentSessionStatus.h"
#import "CardKit.h"

@interface PaymentFlowController: CardKPaymentFlowController
  @property (nullable) XCTestExpectation* sePaymentExpectation;
  - (void) _sePayment;

  @property (nullable) XCTestExpectation* sendErrorExpectation;
  - (void) _sendError;

//    @property (nullable) XCTestExpectation* sePaymentExpectation;
    - (void)_getSessionStatusRequest:(void (^_Nullable)(CardKPaymentSessionStatus *)) handler;
@end
