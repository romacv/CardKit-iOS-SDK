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
  - (void)_getSessionStatusRequest:(void (^)(CardKPaymentSessionStatus *)) handler;
@end

@implementation PaymentFlowController: CardKPaymentFlowController

    - (NSString *) _urlParameters:(NSArray<NSString *> *) parameters {
        
//        [super _urlParameters:parameters];
        return @"";
    }

  - (void)_sePayment{
      [super _sePayment];
//      [_sePaymentExpectation fulfill];
  }

  - (void)_getSessionStatusRequest:(void (^)(CardKPaymentSessionStatus *)) handler {
    [super _getSessionStatusRequest: handler];
//    [_sePaymentExpectation fulfill];
  }

@end
