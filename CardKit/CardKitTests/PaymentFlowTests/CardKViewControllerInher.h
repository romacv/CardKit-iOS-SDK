//
//  NSObject+CardKViewController.h
//  CardKitTests
//
//  Created by Alex Korotkov on 4/7/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface CardKViewControllerInher: CardKViewController
@property (nonatomic) CardKCardView* cardView;
@property UITextField* ownerTextField;
@end

NS_ASSUME_NONNULL_END
