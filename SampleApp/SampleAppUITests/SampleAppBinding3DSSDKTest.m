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

- (void) _run3DSSDKWithFirstBinding {
  [_app.cells.allElementsBoundByAccessibilityElement[9] tap];

  [[_app.buttons elementBoundByIndex:1] tap];
  
  [_app.cells.firstMatch tap];

  XCUIElement *cellWithBindingInfo = [_app.cells elementBoundByIndex:0];

  [cellWithBindingInfo tap];
  [cellWithBindingInfo typeText:@"123"];

  XCUIElement *cell = [_app.cells elementBoundByIndex:1];

  [cell tap];
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

- (void) testRunThreeDSSDKFlowWithBinding {
  [self _run3DSSDKWithFirstBinding];
  
  [NSThread sleepForTimeInterval:2];
  
  [self _fillTextFieldCorrectCode];
  
  [self _pressConfirmButton];
  
  [NSThread sleepForTimeInterval:3];
  
  XCTAssertTrue([_app.alerts.element.label isEqualToString:@"Success"]);
}

- (void)testRunThreeDSSDKFlowWithBindingWithIncorrectSMSCode {
  [self _run3DSSDKWithFirstBinding];
  
  [NSThread sleepForTimeInterval:2];
  
  [self _fillTextFieldIncorrectCode];
  
  NSString *textDescrition = [_app.staticTexts elementBoundByIndex:3].label;
  
  [_app.buttons[@"Confirm"] tap];
  
  [NSThread sleepForTimeInterval:3];
  
  XCTAssertFalse([textDescrition isEqualToString:[_app.staticTexts elementBoundByIndex:3].label]);
}

- (void) testRunThreeDSSDKFlowWithBindingWithFillIncorrectCodeUntilCancelFlow {
  [self _run3DSSDKWithFirstBinding];
  
  [NSThread sleepForTimeInterval:2];
  
  for (NSInteger i = 0; i < 3; i++) {
    [self _fillTextFieldIncorrectCode];
    [_app.buttons[@"Confirm"] tap];
    [NSThread sleepForTimeInterval:3];
  }
  
  XCTAssertTrue([_app.alerts.element.label isEqualToString:@"Cancel"]);
}

- (void) testRunResendMessageFlow {
  [self _run3DSSDKWithFirstBinding];
  
  [NSThread sleepForTimeInterval:2];
  
  [self _fillTextFieldIncorrectCode];
  
  [self _pressResendSMSButton];
  
  [NSThread sleepForTimeInterval:3];
  
  [self _fillTextFieldResentCode];
  
  [self _pressConfirmButton];
  
  [NSThread sleepForTimeInterval:3];
  
  XCTAssertTrue([_app.alerts.element.label isEqualToString:@"Success"]);
}
@end
