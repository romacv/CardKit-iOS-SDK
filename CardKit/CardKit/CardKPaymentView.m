//
//  UIView+CardKPaymentView.m
//  CardKit
//
//  Created by Alex Korotkov on 5/28/20.
//  Copyright © 2020 AnjLab. All rights reserved.
//
#import <PassKit/PassKit.h>
#import "CardKPaymentView.h"
#import "CardKConfig.h"
#import "CardKViewController.h"

@implementation CardKPaymentView {
  PKPaymentButton *_applePayButton;
  NSBundle *_bundle;
  NSBundle *_languageBundle;
  NSArray *_sections;
  id<CardKDelegate> _cKitDelegate;
  PKPaymentAuthorizationViewController *_viewController;
  NSDictionary *_paymentData;
  PKPayment *_pKPayment;
}

- (instancetype)initWithDelegate:(id<CardKDelegate>)cKitDelegate {
  self = [super init];
  if (self) {
    _paymentRequest = [[PKPaymentRequest alloc] init];

    _cardPaybutton =  [UIButton buttonWithType:UIButtonTypeSystem];
    _cardPaybutton.layer.cornerRadius = 4;
    [_cardPaybutton setBackgroundColor: UIColor.whiteColor];
    [_cardPaybutton setTitleColor: UIColor.blackColor forState:UIControlStateNormal];
    _cardPaybutton.titleLabel.minimumScaleFactor = 0.5;
    _cardPaybutton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _cardPaybutton.titleLabel.allowsDefaultTighteningForTruncation = YES;
    [_cardPaybutton addTarget:self action:@selector(_cardPaybuttonPressed:)
    forControlEvents:UIControlEventTouchUpInside];
    

    
    _bundle = [NSBundle bundleForClass:[CardKPaymentView class]];
     
     NSString *language = CardKConfig.shared.language;
     if (language != nil) {
       _languageBundle = [NSBundle bundleWithPath:[_bundle pathForResource:language ofType:@"lproj"]];
     } else {
       _languageBundle = _bundle;
     }
    
    [_cardPaybutton
      setTitle: NSLocalizedStringFromTableInBundle(@"payByCard", nil, _languageBundle,  @"Pay by card")
      forState: UIControlStateNormal];
    
    [cKitDelegate willShowPaymentView:self];
    
    _applePayButton = [[PKPaymentButton alloc] initWithPaymentButtonType: _paymentButtonType paymentButtonStyle: _paymentButtonStyle];
    
    [_applePayButton addTarget:self action:@selector(onApplePayButtonPressed:)
    forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: _applePayButton];
    
  
    
    [self addSubview:_cardPaybutton];

    _cKitDelegate = cKitDelegate;
  }
  return self;
}

- (void)layoutSubviews {
  CGRect bounds = self.bounds;
  
  [_cardPaybutton.titleLabel setFont:_applePayButton.titleLabel.font];

  NSInteger height = bounds.size.height;
  NSInteger width = bounds.size.width;
  NSInteger maxButtonWidth = 288;
  NSInteger maxButtonHeight = 44;
  NSInteger minButtonHeight = 30;
  NSInteger minButtonWidth = 80;
  NSInteger minMargin = 20;

  NSInteger buttonHeight = height;
  
  if (height > maxButtonHeight) {
    buttonHeight = maxButtonHeight;
  } else if (height < minButtonHeight) {
    buttonHeight = minButtonHeight;
  }
  
  NSInteger buttonWidth = width / 2;
  
  if (width / 2 >= maxButtonWidth) {
    buttonWidth = maxButtonWidth;
  } else if (width / 2 < minButtonWidth) {
    buttonWidth = minButtonWidth;
  }
  
  if (![PKPaymentAuthorizationViewController canMakePayments] || [[_merchantId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]  isEqual: @""]) {
    
    _applePayButton.hidden = YES;
    _cardPaybutton.frame = CGRectMake(width * 0.5 - buttonWidth / 2, 0, buttonWidth, buttonHeight);

    return;
  }
  
  if (width / 2 < minButtonWidth) {
    _applePayButton.frame = CGRectMake(minMargin, 0, buttonWidth - minMargin, buttonHeight);
    _cardPaybutton.frame = CGRectMake(minMargin, CGRectGetMaxY(_applePayButton.frame) + 8, buttonWidth - minMargin, buttonHeight);
    return;
  }
  
  if (width > self.superview.bounds.size.width && self.traitCollection.userInterfaceIdiom != UIUserInterfaceIdiomPad) {
    _cardPaybutton.frame = CGRectMake(minMargin, 0, self.superview.bounds.size.width / 2 - minMargin, buttonHeight);
    _applePayButton.frame = CGRectMake(CGRectGetMaxX(_cardPaybutton.frame) + 8, 0, self.superview.bounds.size.width / 2 - minMargin - 8, buttonHeight);

    return;
  }
  
  if (width < buttonWidth * 2 + minMargin * 2) {
    _cardPaybutton.frame = CGRectMake(minMargin, 0, buttonWidth - minMargin - 8, buttonHeight);
    _applePayButton.frame = CGRectMake(CGRectGetMaxX(_cardPaybutton.frame) + 8, 0, buttonWidth - minMargin, buttonHeight);
    return;
  }
  
  _cardPaybutton.frame = CGRectMake(width * 0.5 - buttonWidth, 0, buttonWidth, buttonHeight);
  _applePayButton.frame = CGRectMake(CGRectGetMaxX(_cardPaybutton.frame) + 8, 0, buttonWidth - minMargin, buttonHeight);
}

-(IBAction)onApplePayButtonPressed:(id)sender
{
    _viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest: _paymentRequest];
    
    _viewController.delegate = (id <PKPaymentAuthorizationViewControllerDelegate>)self;
    [_controller presentViewController:_viewController animated:YES completion:nil];
}

-(void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    [_cKitDelegate cardKPaymentView:self didAuthorizePayment:_pKPayment];
    [_controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
  
  NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:payment.token.paymentData options:kNilOptions error:nil];
  
  _pKPayment = payment;
  
  if (dict == nil) {
    completion(PKPaymentAuthorizationStatusFailure);
    return;
  }
  
  _paymentData = dict;
  completion(PKPaymentAuthorizationStatusSuccess);
}

- (void)_cardPaybuttonPressed:(UIButton *)button {
  CardKViewController *controller = [[CardKViewController alloc] init];
  controller.cKitDelegate = _cKitDelegate;
  
  UIViewController *viewController = [CardKViewController create:_cKitDelegate controller: controller];

  [_controller presentViewController:viewController animated:YES completion:nil];
}

@end
