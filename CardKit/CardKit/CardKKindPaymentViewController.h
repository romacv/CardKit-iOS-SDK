//
//  UITableViewController+CardKKindPaymentViewController.h
//  CardKit
//
//  Created by Alex Korotkov on 5/13/20.
//  Copyright © 2020 AnjLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardKViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CardKKindPaymentViewController : UITableViewController

/*! Делегат контроллера*/
@property (weak, nonatomic) id<CardKDelegate> cKitDelegate;

@end

NS_ASSUME_NONNULL_END
