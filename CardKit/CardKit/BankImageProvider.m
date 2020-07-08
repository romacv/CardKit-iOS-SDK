//
//  BankImageProvider.m
//  CardKit
//
//  Created by Yury Korolev on 01.09.2019.
//  Copyright © 2019 AnjLab. All rights reserved.
//

#import "BankImageProvider.h"

@implementation BankImageProvider {
  dispatch_queue_t _queue;
  NSDictionary *_banksJSON;
  NSString *_lastPrefix;
  SVGKImage *_lastImage;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _queue = dispatch_queue_create(
                                   "bank.image.provider.queue",
                                   DISPATCH_QUEUE_SERIAL
                                   );
  }
  return self;
}

- (void)preloadData {
  __weak typeof(self) weakSelf = self;
  
  dispatch_async(_queue, ^{
    [weakSelf _loadJson];
  });
}

- (nullable SVGKImage *)_searchBank:(NSString *)curdNumberPrefix
{
  NSBundle *bundle = [NSBundle bundleForClass:[BankImageProvider class]];
  NSDictionary *prefixes = [_banksJSON objectForKey:@"prefixes"];
  NSString *bunkKey = [prefixes objectForKey:curdNumberPrefix];
  
  if (!bunkKey) {
    bunkKey = @"";
  }
  
  NSString *pathToImg = [NSString stringWithFormat:@"svg/bank-logos/color/%@", bunkKey];
  NSString *imagePath = [[[bundle resourcePath] stringByAppendingPathComponent:pathToImg] stringByAppendingPathExtension:@"svg"];
  
  //    SVGKImage *img = [SVGKImage imageWithContentsOfFile:imagePath];
  //    return img;
  return nil;
}

- (void)_loadJson {
  NSBundle *bundle = [NSBundle bundleForClass:[BankImageProvider class]];
  NSString *path = [[[bundle resourcePath] stringByAppendingPathComponent:@"svg/bank-logos/banks"
                     ] stringByAppendingPathExtension:@"json"];
  NSData *data = [NSData dataWithContentsOfFile:path];
  _banksJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (NSString *)_prefixFromCardNumber:(NSString *)cardNumber {
  return [cardNumber substringToIndex:5];
}

- (nullable SVGKImage *)svgImageForNumber:(NSString *)number {
  
  NSString *prefix = [self _prefixFromCardNumber:number];
  
  if (!prefix || [prefix length] < 6) {
    return nil;
  }
  
  // catching
  if ([prefix isEqual:_lastPrefix] && _lastImage) {
    return _lastImage;
  }
  
  __block SVGKImage *result = nil;
  
  dispatch_sync(_queue, ^{
    result = [self _searchBank:prefix];
  });
  
  _lastPrefix = prefix;
  _lastImage = result;
  
  return result;
}


@end
