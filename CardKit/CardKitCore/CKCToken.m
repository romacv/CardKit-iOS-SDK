//
//  NSObject+CKCToken.m
//  Core
//
//  Created by Alex Korotkov on 11/12/20.
//  Copyright © 2020 AnjLab. All rights reserved.
//

#import "CKCToken.h"
#import "CKCTokenResult.h"
#import "CKCBindingParams.h"
#import "CKCCardParams.h"
#import "RSA.h"
#import "Luhn.h"

@implementation CKCToken: NSObject
+ (nullable NSString *)getFullYearFromExpirationDate: (NSString *) time {
  NSString *text = [time stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if (text.length != 4) {
    return nil;
  }
  NSString *year = [text substringFromIndex:2];
  NSString *fullYearStr = [NSString stringWithFormat:@"20%@", year];
  
  NSInteger fullYear = [fullYearStr integerValue];
  
  NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]];
  
  if (fullYear < comps.year || fullYear >= comps.year + 10) {
    return nil;
  }
  
  return fullYearStr;
}

+ (nullable NSString *)getMonthFromExpirationDate: (NSString *) time {
  NSString *text = [time stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if (text.length != 4) {
    return nil;
  }
  NSString *monthStr = [text substringToIndex:2];
  
  NSInteger month = [monthStr integerValue];
  if (month < 1 || month > 12) {
    return nil;
  }
  
  return monthStr;
}

+ (BOOL) isValidCreditCardNumber: (NSString *) pan {
  return [Luhn validateString:pan];
}

+ (BOOL) allDigitsInString:(NSString *)str {
  NSString *string = [str stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, str.length)];
  return [str isEqual:string];
}

+ (NSDictionary *)_validateCardNumber: (NSString *) number {
  NSString *cardNumber = number;

  NSInteger len = [cardNumber length];
  if (len < 16 || len > 19) {
      return @{@"field": CKCFieldPan, @"error": CKCErrorInvalidLength};
  } else if (![self allDigitsInString:cardNumber] || ![self isValidCreditCardNumber: cardNumber]) {
      return @{@"field": CKCFieldPan, @"error": CKCErrorInvalid};
  }

    return nil;
}

+ (NSDictionary *)_validateSecureCode: (NSString *) cvc {
  NSString *secureCode = cvc;

  if ([secureCode length] != 3 || ![self allDigitsInString:secureCode]) {
      return @{@"field": CKCFieldCVC, @"error": CKCErrorInvalid};
  }
  
    return nil;
}

+ (NSDictionary *)_validateExpireDate:(NSString *) expireDate {
    NSString * month = [self getMonthFromExpirationDate: expireDate];
    NSString * year = [self getFullYearFromExpirationDate: expireDate];

  if (month == nil || year == nil) {
      return @{@"field": CKCFieldExpiryMMYY, @"error": CKCErrorRequired};
  } else {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.day = 1;
    comps.month = [month integerValue] + 1;
    comps.year = [year integerValue];
    
    NSDate *expDate = [calendar dateFromComponents:comps];
    
    if ([[NSDate date] compare:expDate] != NSOrderedAscending) {
        return @{@"field": CKCFieldExpiryMMYY, @"error": CKCErrorInvalidFormat};
    }
  }
  
    return nil;
}

+ (NSDictionary *)_validateOwner:(NSString *) cardOwner {
  NSString *owner = [cardOwner stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSInteger len = owner.length;
  if (len == 0 || len > 40) {
      return @{@"field": CKCFieldCardholder, @"error": CKCErrorInvalidLength};
  } else {
    NSString *str = [owner stringByReplacingOccurrencesOfString:@"[^a-zA-Z' .]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, owner.length)];
    if (![str isEqual:owner]) {
        return @{@"field": CKCFieldCardholder, @"error": CKCErrorInvalidFormat};
    }
  }
  
    return nil;
}

+ (NSArray *) validateCardForm: (CKCBindingParams *) params {
    NSArray *errors = [[NSArray alloc] init];
    return errors;
}

+ (NSString *) getTimeStampWithDate:(NSDate *) date {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
  [dateFormatter setLocale:enUSPOSIXLocale];
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
  [dateFormatter setCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];
  
  return [dateFormatter stringFromDate:date];
}

+ (NSString *) getTimeStamp {
  NSDate *currentDate = [NSDate date];
  
  return [self getTimeStampWithDate:currentDate];
}

+ (CKCTokenResult *) generateWithBinding: (CKCBindingParams *) params  {
    NSMutableArray *errors = [[NSMutableArray alloc] init];

    if ([params.bindingID isEqual: nil] || [params.bindingID isEqual:@""]) {
        [errors addObject:@{@"field": CKCFieldBindingID, @"error": CKCErrorRequired}];
    }
    
    if ([params.mdOrder isEqual: nil] || [params.mdOrder isEqual:@""]) {
        [errors addObject:@{@"field": CKCFieldMdOrder, @"error": CKCErrorRequired}];
    }
    
    if ([params.pubKey isEqual: nil] || [params.pubKey isEqual:@""]) {
        [errors addObject:@{@"field": CKCFieldPubKey, @"error": CKCErrorRequired}];
    }
    
    CKCTokenResult * tokenResult = [[CKCTokenResult alloc] init];
    tokenResult.token = nil;
    tokenResult.errors = errors;
    
    if (errors.count > 0) {
        return tokenResult;
    }
    
    NSDictionary *validatedSecureCode;

    if (params.cvc != nil) {
        validatedSecureCode = [self _validateSecureCode: params.cvc];
    }

    if (validatedSecureCode != nil) {
        [errors addObject:validatedSecureCode];
        tokenResult.errors = errors;

        return tokenResult;
    }

    NSString *timeStamp = [self getTimeStamp];
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *cardData = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", timeStamp, uuid, params.cvc, params.mdOrder, params.bindingID];

    NSString *seToken = [RSA encryptString:cardData publicKey:params.pubKey];
    
    if ([seToken isEqual:@""]) {
        [errors addObject:@{@"field": CKCFieldPubKey, @"error": CKCErrorInvalid}];
        return tokenResult;
    }

    return tokenResult;
}

+ (CKCTokenResult *) generateWithCard: (CKCCardParams *) params  {
    NSMutableArray *errors = [[NSMutableArray alloc] init];

    if ([params.mdOrder isEqual: nil] || [params.mdOrder isEqual:@""]) {
        [errors addObject:@{@"field": CKCFieldMdOrder, @"error": CKCErrorRequired}];
    }
    
    if ([params.pubKey isEqual: nil] || [params.pubKey isEqual:@""]) {
        [errors addObject:@{@"field": CKCFieldPubKey, @"error": CKCErrorRequired}];
    }
    
    CKCTokenResult * tokenResult = [[CKCTokenResult alloc] init];
    tokenResult.token = nil;
    
    if (errors.count > 0) {
        tokenResult.errors = errors;
        return tokenResult;
    }
    
    NSDictionary *validatedSecureCode = [self _validateSecureCode: params.cvc];
    NSDictionary *validatedExpireDate = [self _validateExpireDate: params.expiryMMYY];
    NSDictionary *validatedCardNumber = [self _validateCardNumber: params.pan];
    NSDictionary *validatedCarHolder = [self _validateOwner: params.cardholder];

    if (validatedSecureCode != nil) {
        [errors addObject:validatedSecureCode];
    }
    
    if (validatedExpireDate != nil) {
        [errors addObject:validatedExpireDate];
    }
    
    if (validatedCardNumber != nil) {
        [errors addObject:validatedCardNumber];
    }
    
    if (validatedCarHolder != nil) {
        [errors addObject:validatedCarHolder];
    }
    
    if (errors.count > 0) {
        tokenResult.errors = errors;
        return tokenResult;
    }

    NSString *timeStamp = [self getTimeStamp];
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *cardNumber = params.pan;
    NSString *secureCode = params.cvc;
    NSString *fullYear = [self getFullYearFromExpirationDate: params.expiryMMYY];
    NSString *month = [self getMonthFromExpirationDate: params.expiryMMYY];
    NSString *expirationDate = [NSString stringWithFormat:@"%@%@", fullYear, month];
    
    NSString *cardData = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", timeStamp, uuid, cardNumber, secureCode, expirationDate];
    
    if (params.mdOrder != nil) {
      cardData = [NSString stringWithFormat:@"%@/%@", cardData, params.mdOrder];
    } else {
      cardData = [NSString stringWithFormat:@"%@//", cardData];
    }

    NSString *seToken = [RSA encryptString:cardData publicKey: params.pubKey];
    
    if ([seToken isEqual:@""]) {
        [errors addObject:@{@"field": CKCFieldPubKey, @"error": CKCErrorInvalid}];
        tokenResult.errors = errors;

        return tokenResult;
    }
    
    tokenResult.token = seToken;

    return tokenResult;
}

@end
