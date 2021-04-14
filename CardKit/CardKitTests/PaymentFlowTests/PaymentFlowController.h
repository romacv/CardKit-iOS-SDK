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

@protocol PaymentFlowControllerDelegate

- (void)fillForm;

@end


@interface PaymentFlowController: CardKPaymentFlowController
  @property (weak, nonatomic) id<PaymentFlowControllerDelegate> delegate;
  @property (weak, nonatomic) id<CardKDelegate> cKitDelegate;

  @property (nullable) XCTestExpectation* sendErrorExpectation;
  - (void) _sendError;

  @property (nullable) XCTestExpectation* sendRedirectErrorExpectation;
  - (void)_sendRedirectError;

  @property (nullable) XCTestExpectation* moveChoosePaymentMethodControllerExpectation;
  - (void)_moveChoosePaymentMethodController;

  - (void)_initSDK:(CardKCardView *) cardView cardOwner:(NSString *) cardOwner seToken:(NSString *) seToken callback: (void (^)(NSDictionary *)) handler;

  - (void) _runChallange:(NSDictionary *) responseDictionary;

  - (void)_getSessionStatusRequest:(void (^_Nullable)(CardKPaymentSessionStatus *)) handler;
@end
