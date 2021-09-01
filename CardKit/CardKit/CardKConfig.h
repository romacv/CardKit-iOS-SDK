//
//  CardKConfig.h
//  CardKit
//
//  Created by Alex Korotkov on 10/1/19.
//  Copyright © 2019 AnjLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>
#import "CardKTheme.h"
#import "CardKBinding.h"

NS_ASSUME_NONNULL_BEGIN

@interface CardKConfig : NSObject

@property (strong, nonatomic) CardKTheme *theme;
@property (nullable, strong, nonatomic) NSString *language;

@property (class, readonly, strong, nonatomic) CardKConfig *shared;

/*! Обязательный ввод CVC*/
@property BOOL bindingCVCRequired;

/*! Режим запуска */
@property BOOL isTestMod;

/*! Публичный ключ */
@property NSString *pubKey;

@property NSString *rootCertificate;

/*! Идентификатор заказа*/
@property NSString *mdOrder;

/*! Массив связок*/
@property NSArray<CardKBinding *> *bindings;

/*! Массив связок*/
@property BOOL isEditBindingListMode;

/*! URL для запроса тестового ключа */
@property NSString *testURL;

/*! URL для запроса продакшин ключа */
@property NSString *prodURL;

@property NSString *mrBinURL;

@property NSString *mrBinApiURL;

@property NSString *bindingsSectionTitle;

@property (nullable) NSString *seTokenTimestamp;

+ (void) fetchKeys:(NSString *)url;

+ (NSString *) timestampForDate:(NSDate *) date;
@end

NS_ASSUME_NONNULL_END
