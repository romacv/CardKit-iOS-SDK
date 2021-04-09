//
//  NSObject+CardKPaymentFlow.h
//  CardKit
//
//  Created by Alex Korotkov on 3/26/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardKViewController.h"
#import "CardKPaymentInfo.h"
#import "CardKPaymentError.h"
#import "RequestParams.h"

@protocol CardKPaymentFlowDelegate <NSObject>

- (void)didFinishPaymentFlow:(CardKPaymentInfo *) paymentInfo;
- (void)didErrorPaymentFlow:(CardKPaymentError *) paymentError;

@end

@interface CardKPaymentFlowController: UIViewController<CardKDelegate>
  @property (weak, nonatomic) id<CardKPaymentFlowDelegate> cardKPaymentFlowDelegate;

  @property NSString* userName;
  @property NSString* password;
@end
