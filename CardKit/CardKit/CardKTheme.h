//
//  CardKTheme.h
//  CardKit
//
//  Created by Yury Korolev on 01.09.2019.
//  Copyright © 2019 AnjLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CardKTheme : NSObject

/*! Цвет текста */
@property (strong, nonatomic) UIColor *colorLabel;
/*! Цвет плэйсхолдера */
@property (strong, nonatomic) UIColor *colorPlaceholder;
/*! Цвет  ошибки*/
@property (strong, nonatomic) UIColor *colorErrorLabel;
/*! Цвет  фона */
@property (strong, nonatomic) UIColor *colorTableBackground;
/*! Цвет ячейки */
@property (strong, nonatomic, nullable) UIColor *colorCellBackground;
/*! Цвет  рамки у ячейки */
@property (strong, nonatomic) UIColor *colorSeparatar;
/*! Цвет текста кнопки */
@property (strong, nonatomic) UIColor *colorButtonText;
@property (strong, nonatomic, nullable) NSString *imageAppearance;

/*!
@brief Cтандартная тема
@return Объект CardKTheme
 */
+ (CardKTheme *)defaultTheme;
/*!
@brief Темная тема
@return Объект CardKTheme
 */
+ (CardKTheme *)darkTheme;
/*!
@brief Светлая тема
@return Объект CardKTheme
 */
+ (CardKTheme *)lightTheme;
/*!
@brief Системная тема ТОЛЬКО iOS 13.0 +
@return Объект CardKTheme
 */
+ (CardKTheme *)systemTheme API_AVAILABLE(ios(13.0));
//+ (CardKTheme *)shared;
/*!
@brief Присвоить тему
 */
//+ (void)setTheme:(CardKTheme *)theme;
@end

NS_ASSUME_NONNULL_END
