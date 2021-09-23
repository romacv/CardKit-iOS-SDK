//
//  SampleAppUITests.m
//  SampleAppUITests
//
//  Created by Alex Korotkov on 5/17/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface SampleAppUITests : XCTestCase

@end

@implementation SampleAppUITests {
  XCUIApplication *_app;
}

- (void)setUp {
  self.continueAfterFailure = NO;

  _app = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.anjlab.SampleApp"];

  [_app launch];
}

- (void)tearDown {
}

- (void)testChooseBindingWithoutCVCGetSeToken {
  [_app.cells.allElementsBoundByAccessibilityElement[5] tap];

  [_app.cells.firstMatch tap];
  
  XCUIElement *cell = [_app.cells elementBoundByIndex:1];
  
  [cell tap];

  XCTAssertTrue([_app.alerts.element.label isEqualToString:@"SeToken"]);
}

- (void)testRemoveBindingBySwipe {
  [_app.cells.allElementsBoundByAccessibilityElement[5] tap];

  [_app.cells.firstMatch swipeLeft];
  
  [_app.buttons[@"Delete"] tap];

  XCTAssertTrue([_app.alerts.element.label isEqualToString:@"Removed bindings"]);
}

- (void)testRemoveAllBindingsByOne {
  [_app.cells.allElementsBoundByAccessibilityElement[5] tap];

  [_app.cells.firstMatch swipeLeft];
  
  [_app.buttons[@"Delete"] tap];
  
  [_app.alerts.firstMatch.buttons.firstMatch tap];

  [_app.cells.firstMatch swipeLeft];

  [_app.buttons[@"Delete"] tap];
  
  [_app.alerts.firstMatch.buttons.firstMatch tap];
  
  XCTAssertFalse([_app.buttons[@"Edit"] isEnabled]);
}

- (void)testRemoveAllBindingsOnEditMode {
  [_app.cells.allElementsBoundByAccessibilityElement[5] tap];

  [_app.buttons[@"Edit"] tap];

  [_app.cells.firstMatch.buttons.firstMatch tap];

  [_app.buttons[@"Delete"] tap];

  [_app.cells.firstMatch.buttons.firstMatch tap];

  [_app.buttons[@"Delete"] tap];

  [_app.buttons[@"Save"] tap];

  XCTAssertTrue([_app.alerts.element.label isEqualToString:@"Removed bindings"]);
}

- (void)testChooseBindingAndGenerateSeToken {
  [_app.cells.allElementsBoundByAccessibilityElement[5] tap];

  [_app.cells.firstMatch tap];
  
  XCTAssertFalse(_app.textFields[@"CVC"].exists);
  
  XCUIElement *cell = [_app.cells elementBoundByIndex:1];
  
  [cell tap];

  XCTAssertTrue([_app.alerts.element.label isEqualToString:@"SeToken"]);
}

- (void)testChooseBindingFillCVCAndGenerateSeToken {
  [_app.cells.allElementsBoundByAccessibilityElement[4] tap];

  [_app.cells.firstMatch tap];
  
  XCUIElement *cellWithBindingInfo = [_app.cells elementBoundByIndex:0];

  [cellWithBindingInfo tap];
  [cellWithBindingInfo typeText:@"123"];
  
  XCUIElement *cell = [_app.cells elementBoundByIndex:1];
  
  [cell tap];

  XCTAssertTrue([_app.alerts.element.label isEqualToString:@"SeToken"]);
}

- (void)testChooseBindingFillIncorrectCVCAndGenerateSeToken {
  [_app.cells.allElementsBoundByAccessibilityElement[4] tap];
  [_app.cells.firstMatch tap];
  
  XCUIElement *cellWithBindingInfo = [_app.cells elementBoundByIndex:0];

  [cellWithBindingInfo tap];
  [cellWithBindingInfo typeText:@"1"];
  
  XCUIElement *cell = [_app.cells elementBoundByIndex:1];
  
  [cell tap];
  
  XCUIElement *errorMassage = _app.staticTexts.allElementsBoundByAccessibilityElement[0];

  XCTAssertTrue([errorMassage.label isEqualToString:@"CVC2/CVV2 is incorrect"]);
}

@end
