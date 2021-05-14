//
//  CardKitUITest.m
//  CardKitUITests
//
//  Created by Alex Korotkov on 5/13/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface CardKitUITest : XCTestCase

@end

@implementation CardKitUITest {
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

- (void)testChooseBindingAndGenerateSeToken {
  [_app.cells.allElementsBoundByAccessibilityElement[5] tap];

  [_app.cells.firstMatch tap];
  
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
