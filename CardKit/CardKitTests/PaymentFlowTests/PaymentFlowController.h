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
  @property (weak, nonatomic, nullable) id<PaymentFlowControllerDelegate> delegate;
  @property (weak, nonatomic, nullable) id<CardKDelegate> cKitDelegate;

  @property (nullable) XCTestExpectation* sendErrorExpectation;
  - (void) _sendError;

  @property (nullable) XCTestExpectation* sendRedirectErrorExpectation;
  - (void)_sendRedirectError;

  @property (nullable) XCTestExpectation* moveChoosePaymentMethodControllerExpectation;
  - (void)_moveChoosePaymentMethodController;

  @property (nullable) XCTestExpectation* completedWithTransactionStatusExpectation;
  - (void)completedWithTransactionStatus:(NSString *_Nonnull) transactionStatus;

  @property (nullable) XCTestExpectation* getFinishSessionStatusRequestExpectation;
  - (void)_getFinishSessionStatusRequest;

  @property (nullable) XCTestExpectation* getFinishedPaymentInfoExpectation;
  - (void)_getFinishedPaymentInfo;

  - (void)_initSDK:(CardKCardView *_Nonnull) cardView cardOwner:(NSString *_Nonnull) cardOwner seToken:(NSString *_Nonnull) seToken callback: (void (^_Nonnull)(NSDictionary *_Nonnull)) handler;

  - (void) _runChallange:(NSDictionary *_Nonnull) responseDictionary;

  - (void)_getSessionStatusRequest:(void (^_Nullable)(CardKPaymentSessionStatus *_Nonnull)) handler;

  - (NSArray<CardKBinding *> *_Nonnull) _convertBindingItemsToCardKBinding:(NSArray<NSDictionary *> *_Nonnull) bindingItems;
@end
