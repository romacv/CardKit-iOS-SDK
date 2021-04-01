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
    @property NSDictionary* _Nullable flowExpectation;
    - (void) _sePayment;
    - (void)_getSessionStatusRequest:(void (^)(CardKPaymentSessionStatus *)) handler;
@end
