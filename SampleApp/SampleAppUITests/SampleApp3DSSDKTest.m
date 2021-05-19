//
//  SampleApp3DSSDKTest.m
//  SampleAppUITests
//
//  Created by Alex Korotkov on 5/17/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface SampleApp3DSSDKTest : XCTestCase

@end

@implementation SampleApp3DSSDKTest {
  XCUIApplication *_app;
  NSBundle *_bundle;
  NSBundle *_languageBundle;
}

- (void)setUp {
  self.continueAfterFailure = NO;

  _app = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.anjlab.SampleApp"];
  [_app launch];
  
  _bundle = [NSBundle bundleForClass:[SampleApp3DSSDKTest class]];

  NSString *language = _app.accessibilityLanguage;
  
  if (language != nil) {
    _languageBundle = [NSBundle bundleWithPath:[_bundle pathForResource:language ofType:@"lproj"]];
  } else {
    _languageBundle = _bundle;
  }
}

- (void)tearDown {
}

- (void) _runFlowWithBindingWithCVC:(NSString *) cvc {
  [[_app.buttons elementBoundByIndex:1] tap];
  
  [_app.cells.firstMatch tap];

  XCUIElement *cellWithBindingInfo = [_app.cells elementBoundByIndex:0];

  [cellWithBindingInfo tap];
  [cellWithBindingInfo typeText:cvc];

  XCUIElement *cell = [_app.cells elementBoundByIndex:1];

  [cell tap];
}

- (void) _runFlowWithBinding {
  [[_app.buttons elementBoundByIndex:1] tap];
  
  [_app.cells.firstMatch tap];

  XCUIElement *cellWithBindingInfo = [_app.cells elementBoundByIndex:0];

  [cellWithBindingInfo tap];
  [cellWithBindingInfo typeText:@"123"];

  XCUIElement *cell = [_app.cells elementBoundByIndex:1];

  [cell tap];
}

- (void) _fillNewCardForm {
  [_app.buttons[@"New card"] tap];

  [_app.textFields[@"Number"] tap];
  [_app.textFields[@"Number"] typeText:@"5777777777777775"];

  [_app.textFields[@"MM/YY"] tap];
  [_app.textFields[@"MM/YY"] typeText:@"1224"];

  [_app.secureTextFields[@"CVC"] tap];
  [_app.secureTextFields[@"CVC"] typeText:@"123"];

  [_app.textFields[@"NAME"].firstMatch tap];
  [_app.textFields[@"NAME"] typeText:@"ALEX KOROTKOV"];

  [_app.buttons[@"Submit payment"] tap];
}

- (void) _fillNewCardFormWithIncorrectCVC {
  [_app.buttons[@"New card"] tap];

  [_app.textFields[@"Number"] tap];
  [_app.textFields[@"Number"] typeText:@"5777777777777775"];

  [_app.textFields[@"MM/YY"] tap];
  [_app.textFields[@"MM/YY"] typeText:@"1224"];

  [_app.secureTextFields[@"CVC"] tap];
  [_app.secureTextFields[@"CVC"] typeText:@"666"];

  [_app.textFields[@"NAME"].firstMatch tap];
  [_app.textFields[@"NAME"] typeText:@"ALEX KOROTKOV"];

  [_app.buttons[@"Submit payment"] tap];
}

- (void) _openKindPaymentController {
  [[_app.buttons elementBoundByIndex:1] tap];
}

- (void) _openPassCodeFlowWithNewCard {
  [_app.cells.allElementsBoundByAccessibilityElement[9] tap];
  [self _openKindPaymentController];
  [self _fillNewCardForm];
}

- (void) _runFlowWithCheckBoxsWithNewCard {
  [_app.cells.allElementsBoundByAccessibilityElement[11] tap];
  [self _openKindPaymentController];
  [self _fillNewCardForm];
}

- (void) _runFlowWithRadioButtonsWithNewCard {
  [_app.cells.allElementsBoundByAccessibilityElement[10] tap];
  [self _openKindPaymentController];
  [self _fillNewCardForm];
}

- (void) _openPassCodeFlowWithIncorrectNewCard {
  [_app.cells.allElementsBoundByAccessibilityElement[9] tap];
  
  [self _sleep];
  
  [[_app.buttons elementBoundByIndex:1] tap];

  [self _fillNewCardFormWithIncorrectCVC];
}

- (void) _runPassCodeFlow {
  [_app.cells.allElementsBoundByAccessibilityElement[9] tap];
  [self _runFlowWithBinding];
}

- (void) _runFlowWithCheckBoxs {
  [_app.cells.allElementsBoundByAccessibilityElement[11] tap];
  [self _runFlowWithBinding];
}

- (void) _runFlowWithRadioButtons {
  [_app.cells.allElementsBoundByAccessibilityElement[10] tap];
  [self _runFlowWithBinding];
}

- (void) _runPassCodeFlowWithIncorrectCVC {
  [_app.cells.allElementsBoundByAccessibilityElement[9] tap];
  [self _runFlowWithBindingWithCVC: @"666"];
}

- (void) _pressConfirmButton {
  [_app.buttons[@"Confirm"] tap];
}

- (void) _pressResendSMSButton {
  [_app.buttons[@"Send SMS again"] tap];
}

- (void) _fillTextFieldCorrectCode {
  XCUIElement *textField = [_app.textFields elementBoundByIndex:0];
  
  [textField tap];
  
  [textField typeText:@"123456"];
}

- (void) _fillTextFieldIncorrectCode {
  XCUIElement *textField = [_app.textFields elementBoundByIndex:0];
  
  [textField tap];
  
  [textField typeText:@"1234"];
}

- (void) _fillTextFieldResentCode {
  XCUIElement *textField = [_app.textFields elementBoundByIndex:0];
  
  [textField tap];
  
  [textField typeText:@"111111"];
}

- (void) _sleep:(NSTimeInterval) timeInterval {
  [NSThread sleepForTimeInterval:timeInterval];
}

- (void) _sleep {
  [NSThread sleepForTimeInterval:3];
}

- (NSString *) _alertLable {
  return _app.alerts.element.label;
}

- (NSString *) _textDescrition {
  return[_app.staticTexts elementBoundByIndex:3].label;
}

- (void) testRunThreeDSSDKFlowWithBinding {
  [self _runPassCodeFlow];
  
  [self _sleep];
  
  [self _fillTextFieldCorrectCode];
  
  [self _pressConfirmButton];
  
  [self _sleep];
  
  XCTAssertTrue([[self _alertLable] isEqualToString:@"Success"]);
}

- (void) testRunThreeDSSDKFlowWithBindingWithIncorrectCVC {
  [self _runPassCodeFlowWithIncorrectCVC];
  
  [self _sleep];
  
  [self _fillTextFieldCorrectCode];
  
  [self _pressConfirmButton];
  
  [self _sleep];
  
  XCTAssertTrue([[self _alertLable] isEqualToString:@"Error"]);
}

- (void) testRunThreeDSSDKFlowWithBindingWithIncorrectSMSCode {
  [self _runPassCodeFlow];
  
  [self _sleep];
  
  [self _fillTextFieldIncorrectCode];
  
  NSString *textDescritionBeforeError = [self _textDescrition];
  
  [self _pressConfirmButton];
  
  [self _sleep];
  
  XCTAssertFalse([textDescritionBeforeError isEqualToString:[self _textDescrition]]);
}

- (void) testRunThreeDSSDKFlowWithBindingWithFillIncorrectCodeUntilCancelFlow {
  [self _runPassCodeFlow];
  
  [self _sleep];
  
  for (NSInteger i = 0; i < 3; i++) {
    [self _fillTextFieldIncorrectCode];
    [self _pressConfirmButton];
    [self _sleep];
  }
  
  XCTAssertTrue([[self _alertLable] isEqualToString:@"Cancel"]);
}

- (void) testRunResendMessageFlow {
  [self _runPassCodeFlow];
  
  [self _sleep];
  
  [self _fillTextFieldIncorrectCode];
  
  [self _pressResendSMSButton];
  
  [self _sleep];
  
  [self _fillTextFieldResentCode];
  
  [self _pressConfirmButton];
  
  [self _sleep];
  
  XCTAssertTrue([[self _alertLable] isEqualToString:@"Success"]);
}

- (void) testRunSingleSelectFlowWithBinding{
  [self _runFlowWithRadioButtons];
  
  [self _sleep];

  [[_app.otherElements elementBoundByIndex:10] tap];

  [self _pressConfirmButton];
  
  [self _sleep];
  
  XCTAssertTrue([[self _alertLable] isEqualToString:@"Success"]);
}

- (void) testRunSingleSelectFlowWithBindingNoSelectButtons{
  [self _runFlowWithRadioButtons];
  
  [self _sleep];

  [self _pressConfirmButton];
  
  [self _sleep];
  
  XCTAssertTrue([[self _alertLable] isEqualToString:@"Success"]);
}

- (void) testRunMultiSelectFlowWithBinding{
  [self _runFlowWithCheckBoxs];
  
  [self _sleep];

  [[_app.otherElements elementBoundByIndex:10] tap];

  [self _pressConfirmButton];
  
  [self _sleep];
  
  XCTAssertTrue([[self _alertLable] isEqualToString:@"Success"]);
}

- (void) testRunMultiSelectFlowWithBindingNoSelectCheckBoxs{
  [self _runFlowWithCheckBoxs];
  
  [self _sleep];

  [self _pressConfirmButton];
  
  [self _sleep];
  
  XCTAssertTrue([[self _alertLable] isEqualToString:@"Success"]);
}

- (void)testFillNewCardForm {
  [self _openPassCodeFlowWithNewCard];
  
  [self _sleep];
  
  [self _fillTextFieldCorrectCode];
  
  [self _pressConfirmButton];
  
  [self _sleep];
  
  XCTAssertTrue([[self _alertLable] isEqualToString:@"Success"]);
}

- (void)testFillNewCardFormWithIncorrectCVC {
  [self _openPassCodeFlowWithIncorrectNewCard];
  
  [self _sleep];
  
  [self _fillTextFieldCorrectCode];

  [self _pressConfirmButton];

  [self _sleep];
  
  XCTAssertTrue([[self _alertLable] isEqualToString:@"Error"]);
}



@end
