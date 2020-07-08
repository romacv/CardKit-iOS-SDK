//
//  BankImageProvider.h
//  CardKit
//
//  Created by Yury Korolev on 01.09.2019.
//  Copyright © 2019 AnjLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SVGKit/SVGKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BankImageProvider : NSObject

- (void)preloadData;
- (nullable SVGKImage *)svgImageForNumber:(NSString *)number;

@end

NS_ASSUME_NONNULL_END
