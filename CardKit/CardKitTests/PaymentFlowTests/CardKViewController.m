//
//  NSObject+CardKViewController.m
//  CardKitTests
//
//  Created by Alex Korotkov on 4/7/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//

#import "CardKViewControllerInher.h"
#import "CardKit.h"

@interface CardKViewControllerInher (Test)
  - (CardKCardView *)getCardKView;
  - (NSString *)getCardOwner;
@end

@implementation CardKViewControllerInher: CardKViewController
  - (instancetype)init {
    return self;
  }

  - (CardKCardView *)getCardKView {
      return _cardView;
  }

  - (NSString *)getCardOwner {
      return _ownerTextField.text;
  }
@end
