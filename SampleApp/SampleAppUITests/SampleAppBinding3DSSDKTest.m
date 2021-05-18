//
//  SampleApp3DSSDKTest.m
//  SampleAppUITests
//
//  Created by Alex Korotkov on 5/17/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface SampleAppBinding3DSSDKTest : XCTestCase

@end

@implementation SampleAppBinding3DSSDKTest {
XCUIApplication *_app;
}

- (void)setUp {
  self.continueAfterFailure = NO;

  _app = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.anjlab.SampleApp"];

  [_app launch];
}

- (void)tearDown {
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

- (void)testRunThreeDSSDKFlowWithBindingWithIncorrectSMSCode {
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

- (void) testRunSingleSelectFlowNoSelectButtons{
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

- (void) testRunMultiSelectFlowNoSelectCheckBoxs{
  [self _runFlowWithCheckBoxs];
  
  [self _sleep];

  [self _pressConfirmButton];
  
  [self _sleep];
  
  XCTAssertTrue([[self _alertLable] isEqualToString:@"Success"]);
}
@end
