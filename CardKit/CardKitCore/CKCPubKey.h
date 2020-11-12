//
//  NSObject+CKCPubKey.h
//  Core
//
//  Created by Alex Korotkov on 11/12/20.
//  Copyright © 2020 AnjLab. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CKCPubKey: NSObject
+ (NSString *) fromJSONString:(NSDictionary *) pubKeyObject;
@end

NS_ASSUME_NONNULL_END
