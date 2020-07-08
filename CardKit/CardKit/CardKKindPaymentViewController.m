//
//  UITableViewController+CardKKindPaymentViewController.m
//  CardKit
//
//  Created by Alex Korotkov on 5/13/20.
//  Copyright © 2020 AnjLab. All rights reserved.
//

#import <PassKit/PassKit.h>
#import "CardKKindPaymentViewController.h"
#import "CardKViewController.h"
#import "CardKConfig.h"
#import "CardKBinding.h"
#import "ConfirmChoosedCard.h"
#import "CardKBankLogoView.h"
#import "CardKPaymentView.h"
#import "PaymentSystemProvider.h"

const NSString *CardKSavedCardsCellID = @"savedCards";
const NSString *CardKPayCardButtonCellID = @"button";
const NSString *CardKKindPayRows = @"rows";

@implementation CardKKindPaymentViewController {
  UIButton *_button;
  NSBundle *_bundle;
  NSBundle *_languageBundle;
  NSArray *_sections;
  CardKBankLogoView *_bankLogoView;
}

- (instancetype)init {
  self = [super initWithStyle:UITableViewStyleGrouped];

  if (self) {
    _button =  [UIButton buttonWithType:UIButtonTypeSystem];
  
    _bundle = [NSBundle bundleForClass:[CardKKindPaymentViewController class]];
     
     NSString *language = CardKConfig.shared.language;
     if (language != nil) {
       _languageBundle = [NSBundle bundleWithPath:[_bundle pathForResource:language ofType:@"lproj"]];
     } else {
       _languageBundle = _bundle;
     }

    [_button
      setTitle: NSLocalizedStringFromTableInBundle(@"payByCard", nil, _languageBundle,  @"Pay by card")
      forState: UIControlStateNormal];
    [_button addTarget:self action:@selector(_buttonPressed:)
    forControlEvents:UIControlEventTouchUpInside];
    
    _sections = [self _defaultSections];
    
    _bankLogoView = [[CardKBankLogoView alloc] init];
    _bankLogoView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _bankLogoView.title = NSLocalizedStringFromTableInBundle(@"title", nil, _languageBundle, @"Title");
  }
  return self;
}

- (void)_buttonPressed:(UIButton *)button {
  CardKViewController *controller = [[CardKViewController alloc] init];
  controller.cKitDelegate = _cKitDelegate;
  
  [self.navigationController pushViewController:controller animated:YES];
}

- (NSArray *)_defaultSections {
  return @[@{CardKKindPayRows: @[@{CardKPayCardButtonCellID: @[]}]}, @{CardKKindPayRows: @[ @{CardKSavedCardsCellID:  CardKConfig.shared.bindings}] }];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  for (NSString *cellID in @[CardKSavedCardsCellID, CardKPayCardButtonCellID]) {
   [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
  }
  
  CardKTheme *theme = CardKConfig.shared.theme;
  _button.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40);

  self.tableView.separatorColor = theme.colorSeparatar;
  self.tableView.backgroundColor = theme.colorTableBackground;
  self.tableView.sectionFooterHeight = UITableViewAutomaticDimension;
  self.tableView.cellLayoutMarginsFollowReadableWidth = YES;
  
  UINavigationBar *bar = [self.navigationController navigationBar];
  bar.barTintColor = theme.colorCellBackground;

  _button.tintColor = theme.colorButtonText;
  _bankLogoView.frame = CGRectMake(self.view.bounds.size.width * 2, 0, 0, 0);
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  
  CGRect bounds = _button.superview.bounds;
  _button.center = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSArray *keys = [_sections[section][CardKKindPayRows][0] allKeys];
  NSString *keyName = keys[0];
  NSArray *rows = _sections[section][CardKKindPayRows][0][keyName];
  
  return [rows count] == 0 ? 1 : [rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *cellID = [_sections[indexPath.section][CardKKindPayRows][0] allKeys][0];
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellID forIndexPath:indexPath];

  if([CardKSavedCardsCellID isEqual:cellID]) {
    CardKBinding *cardKBinding = _sections[indexPath.section][CardKKindPayRows][0][CardKSavedCardsCellID][indexPath.row];
    
    CGRect r = tableView.readableContentGuide.layoutFrame;
    cardKBinding.frame = CGRectMake(r.origin.x + 50, 0, r.size.width - 70, cell.contentView.bounds.size.height);
    
    [cell addSubview:cardKBinding];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = cardKBinding.imagePath;
    cardKBinding.autoresizingMask = UIViewAutoresizingFlexibleHeight;

  } else if ([CardKPayCardButtonCellID isEqual:cellID]) {
    [cell addSubview:_button];
  }
   
  CardKTheme *theme = CardKConfig.shared.theme;
  if (theme.colorCellBackground != nil) {
   cell.backgroundColor = theme.colorCellBackground;
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *cellID = [_sections[indexPath.section][CardKKindPayRows][0] allKeys][0];
  
  if ([CardKSavedCardsCellID isEqual:cellID]) {
    ConfirmChoosedCard *confirmChoosedCard = [[ConfirmChoosedCard alloc] init];
    CardKBinding *cardKBinding = [[CardKBinding alloc] init];
    CardKBinding *selectedCardBinding = _sections[indexPath.section][CardKKindPayRows][0][CardKSavedCardsCellID][indexPath.row];
    
    cardKBinding.bindingId = selectedCardBinding.bindingId;
    cardKBinding.paymentSystem = selectedCardBinding.paymentSystem;
    cardKBinding.cardNumber = selectedCardBinding.cardNumber;
    cardKBinding.expireDate = selectedCardBinding.expireDate;

    confirmChoosedCard.cardKBinding = cardKBinding;
    confirmChoosedCard.bankLogoView = _bankLogoView;
    confirmChoosedCard.cKitDelegate = _cKitDelegate;
    
    [self.navigationController pushViewController:confirmChoosedCard animated:true];
  }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == 1) {
    return CardKConfig.shared.bindingsSectionTitle;
  }
  
  return @"";
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
   [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
   [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 38;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  return 38;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *cellID = [_sections[indexPath.section][CardKKindPayRows][0] allKeys][0];
  
  return [CardKSavedCardsCellID isEqual:cellID];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}

@end
