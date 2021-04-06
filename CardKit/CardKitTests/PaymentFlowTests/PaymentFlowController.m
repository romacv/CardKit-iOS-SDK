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

@interface CardKPaymentFlowController (Test)
  - (void)_sePayment;
  - (void)_sendError;
  - (void)_getSessionStatusRequest:(void (^_Nullable)(CardKPaymentSessionStatus *)) handler;
@end

@implementation PaymentFlowController: CardKPaymentFlowController
  - (void)_sePayment{
    [super _sePayment];
    [self.sePaymentExpectation fulfill];
  }

  - (void) _getSessionStatusRequest:(void (^)(CardKPaymentSessionStatus *)) handler {
    [super _getSessionStatusRequest:handler];
  }

  - (void)_sendError {
    [super _sendError];
    [_sendErrorExpectation fulfill];
  }
@end
