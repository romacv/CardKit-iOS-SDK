//
//  SampleAppNewCardUITest.m
//  SampleAppUITests
//
//  Created by Alex Korotkov on 5/17/21.
//  Copyright © 2021 AnjLab. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface SampleAppNewCardUITest : XCTestCase

@end

@implementation SampleAppNewCardUITest {
  XCUIApplication *_app;
  NSBundle *_bundle;
  NSBundle *_languageBundle;
}

- (void)setUp {
  self.continueAfterFailure = NO;

  _app = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.anjlab.SampleApp"];
  [_app launch];
  
  _bundle = [NSBundle bundleForClass:[SampleAppNewCardUITest class]];

  NSString *language = _app.accessibilityLanguage;
  
  if (language != nil) {
    _languageBundle = [NSBundle bundleWithPath:[_bundle pathForResource:language ofType:@"lproj"]];
  } else {
    _languageBundle = _bundle;
  }
}

- (void)tearDown {
}

- (void)testFillNewCardForm {
  [_app.cells.allElementsBoundByAccessibilityElement[4] tap];
  
  [_app.buttons[@"New card"] tap];

  [_app.textFields[@"Number"] tap];
  [_app.textFields[@"Number"] typeText:@"22222222222222222"];
  
  [_app.textFields[@"MM/YY"] tap];
  [_app.textFields[@"MM/YY"] typeText:@"1224"];
  
  [_app.secureTextFields[@"CVC"] tap];
  [_app.secureTextFields[@"CVC"] typeText:@"123"];
  
  [_app.textFields[@"NAME"].firstMatch tap];
  [_app.textFields[@"NAME"] typeText:@"ALEX KOROTKOV"];
  
  [_app.buttons[@"Custom purchase button"] tap];
  
  XCTAssertTrue([_app.alerts.element.label isEqualToString:@"SeToken"]);
}

- (void)testFillNewCardFormWithIncorrectLengthCardNumber {
  [_app.cells.allElementsBoundByAccessibilityElement[4] tap];
  
  [_app.buttons[@"New card"] tap];

  [_app.textFields[@"Number"] tap];
  [_app.textFields[@"Number"] typeText:@"1234"];
  
  [_app.textFields[@"MM/YY"] tap];
  [_app.textFields[@"MM/YY"] typeText:@"1224"];
  
  [_app.secureTextFields[@"CVC"] tap];
  [_app.secureTextFields[@"CVC"] typeText:@"123"];
  
  [_app.textFields[@"NAME"].firstMatch tap];
  [_app.textFields[@"NAME"] typeText:@"ALEX KOROTKOV"];
  
  [_app.buttons[@"Custom purchase button"] tap];
  
  XCUIElement *errorMassage = _app.staticTexts.allElementsBoundByAccessibilityElement[2];

  XCTAssertTrue([errorMassage.label isEqualToString: @"Card number length should be 16-19 digits"]);
}

- (void)testFillNewCardFormWithIncorrectCardNumber {
  [_app.cells.allElementsBoundByAccessibilityElement[4] tap];
  
  [_app.buttons[@"New card"] tap];

  [_app.textFields[@"Number"] tap];
  [_app.textFields[@"Number"] typeText:@"1234567891011121334"];
  
  [_app.textFields[@"MM/YY"] tap];
  [_app.textFields[@"MM/YY"] typeText:@"1224"];
  
  [_app.secureTextFields[@"CVC"] tap];
  [_app.secureTextFields[@"CVC"] typeText:@"123"];
  
  [_app.textFields[@"NAME"].firstMatch tap];
  [_app.textFields[@"NAME"] typeText:@"ALEX KOROTKOV"];
  
  [_app.buttons[@"Custom purchase button"] tap];
  
  XCUIElement *errorMassage = _app.staticTexts.allElementsBoundByAccessibilityElement[1];

  XCTAssertTrue([errorMassage.label isEqualToString: @"The card number is incorrect"]);
}

- (void)testFillNewCardFormWithIncorrectExpireDate {
  [_app.cells.allElementsBoundByAccessibilityElement[4] tap];
  
  [_app.buttons[@"New card"] tap];

  [_app.textFields[@"Number"] tap];
  [_app.textFields[@"Number"] typeText:@"22222222222222222"];
  
  [_app.textFields[@"MM/YY"] tap];
  [_app.textFields[@"MM/YY"] typeText:@"1220"];
  
  [_app.secureTextFields[@"CVC"] tap];
  [_app.secureTextFields[@"CVC"] typeText:@"123"];
  
  [_app.textFields[@"NAME"].firstMatch tap];
  [_app.textFields[@"NAME"] typeText:@"ALEX KOROTKOV"];
  
  [_app.buttons[@"Custom purchase button"] tap];
  
  XCUIElement *errorMassage = _app.staticTexts.allElementsBoundByAccessibilityElement[1];

  XCTAssertTrue([errorMassage.label isEqualToString: @"Card expiry date is incorrect"]);
}

- (void)testFillNewCardFormWithIncorrectCVC {
  [_app.cells.allElementsBoundByAccessibilityElement[4] tap];
  
  [_app.buttons[@"New card"] tap];

  [_app.textFields[@"Number"] tap];
  [_app.textFields[@"Number"] typeText:@"22222222222222222"];
  
  [_app.textFields[@"MM/YY"] tap];
  [_app.textFields[@"MM/YY"] typeText:@"1224"];
  
  [_app.secureTextFields[@"CVC"] tap];
  [_app.secureTextFields[@"CVC"] typeText:@""];
  
  [_app.textFields[@"NAME"].firstMatch tap];
  [_app.textFields[@"NAME"] typeText:@"ALEX KOROTKOV"];
  
  [_app.buttons[@"Custom purchase button"] tap];
  
  XCUIElement *errorMassage = _app.staticTexts.allElementsBoundByAccessibilityElement[1];

  XCTAssertTrue([errorMassage.label isEqualToString: @"CVC2/CVV2 is incorrect"]);
}

- (void)testFillNewCardFormWithIncorrectCardholder {
  [_app.cells.allElementsBoundByAccessibilityElement[4] tap];
  
  [_app.buttons[@"New card"] tap];

  [_app.textFields[@"Number"] tap];
  [_app.textFields[@"Number"] typeText:@"22222222222222222"];
  
  [_app.textFields[@"MM/YY"] tap];
  [_app.textFields[@"MM/YY"] typeText:@"1224"];
  
  [_app.secureTextFields[@"CVC"] tap];
  [_app.secureTextFields[@"CVC"] typeText:@"123"];
  
  [_app.textFields[@"NAME"].firstMatch tap];
  [_app.textFields[@"NAME"] typeText:@""];
  
  [_app.buttons[@"Custom purchase button"] tap];
  
  XCUIElement *errorMassage = _app.staticTexts.allElementsBoundByAccessibilityElement[1];

  XCTAssertTrue([errorMassage.label isEqualToString: @"The card holder is incorrect"]);
}

- (void)testFillNewCardAndMarkSaveCard {
    [_app.cells.allElementsBoundByAccessibilityElement[4] tap];
    
    [_app.buttons[@"New card"] tap];

    [_app.textFields[@"Number"] tap];
    [_app.textFields[@"Number"] typeText:@"22222222222222222"];
    
    [_app.textFields[@"MM/YY"] tap];
    [_app.textFields[@"MM/YY"] typeText:@"1224"];
    
    [_app.secureTextFields[@"CVC"] tap];
    [_app.secureTextFields[@"CVC"] typeText:@"123"];
    
    [_app.textFields[@"NAME"].firstMatch tap];
    [_app.textFields[@"NAME"] typeText:@"ALEX KOROTKOV"];
    
    [_app.switches.firstMatch tap];
    
    [_app.buttons[@"Custom purchase button"] tap];
    
    XCUIElement *element = [_app.alerts.element.staticTexts elementBoundByIndex:1];
    
    XCTAssertTrue([element.label containsString:@"allowSaveCard = true"]);
}

- (void) testStaticTextWichAreSetInClientApp {
    [_app.cells.allElementsBoundByAccessibilityElement[4] tap];
    
    BOOL isExistBindingSectionText = _app.staticTexts[@"Your cards"].exists;
    BOOL isExistNewCardButtonText = _app.buttons[@"New card"].exists;
    
    [_app.buttons[@"New card"] tap];
    
    BOOL isExistPurchaseButtonText = _app.buttons[@"Custom purchase button"].exists;
    
    XCTAssertTrue(isExistBindingSectionText);
    XCTAssertTrue(isExistNewCardButtonText);
    XCTAssertTrue(isExistPurchaseButtonText);
}


@end
