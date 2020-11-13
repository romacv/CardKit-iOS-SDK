//
//  CardKitCoreTests.m
//  CardKitCoreTests
//
//  Created by Alex Korotkov on 11/12/20.
//  Copyright © 2020 AnjLab. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "CKCToken.h"
#import "CKCTokenResult.h"
#import "CKCBindingParams.h"
#import "CKCCardParams.h"
#import "CKCPubKey.h"

@interface CardKitCoreTests : XCTestCase

@end

@implementation CardKitCoreTests

- (void)setUp {
}

- (void)tearDown {
}

- (void)testGenerateTokenWithBinding {
    CKCBindingParams *bindingParams = [[CKCBindingParams alloc] init];
    bindingParams.bindingID = @"das";
    bindingParams.cvc = @"123";
    bindingParams.mdOrder = @"mdOrder";
    bindingParams.pubKey = @"-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoIITqh9xlGx4tWA+aucb0V0YuFC9aXzJb0epdioSkq3qzNdRSZIxe/dHqcbMN2SyhzvN6MRVl3xyjGAV+lwk8poD4BRW3VwPUkT8xG/P/YLzi5N8lY6ILlfw6WCtRPK5bKGGnERcX5dqL60LhOPRDSYT5NHbbp/J2eFWyLigdU9Sq7jvz9ixOLh6xD7pgNgHtnOJ3Cw0Gqy03r3+m3+CBZwrzcp7ZFs41bit7/t1nIqgx78BCTPugap88Gs+8ZjdfDvuDM+/3EwwK0UVTj0SQOv0E5KcEHENL9QQg3ujmEi+zAavulPqXH5907q21lwQeemzkTJH4o2RCCVeYO+YrQIDAQAB-----END PUBLIC KEY-----";

    CKCTokenResult *resForTesting = [[CKCTokenResult alloc] init];
    resForTesting.token = nil;
    resForTesting.errors = nil;
    
    CKCTokenResult *res = [CKCToken generateWithBinding:(bindingParams)];

    XCTAssertNil(res.token, @"pointer:%p", res.token);
}

- (void)testGenerateTokenWithCard {
    CKCCardParams *cardParams = [[CKCCardParams alloc] init];
    cardParams.cardholder=@"Korotkov Alex";
    cardParams.expiryMMYY=@"1222";
    cardParams.pan=@"5536913776755304";
    cardParams.cvc = @"123";
    cardParams.mdOrder = @"mdorder";
    cardParams.pubKey = @"-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoIITqh9xlGx4tWA+aucb0V0YuFC9aXzJb0epdioSkq3qzNdRSZIxe/dHqcbMN2SyhzvN6MRVl3xyjGAV+lwk8poD4BRW3VwPUkT8xG/P/YLzi5N8lY6ILlfw6WCtRPK5bKGGnERcX5dqL60LhOPRDSYT5NHbbp/J2eFWyLigdU9Sq7jvz9ixOLh6xD7pgNgHtnOJ3Cw0Gqy03r3+m3+CBZwrzcp7ZFs41bit7/t1nIqgx78BCTPugap88Gs+8ZjdfDvuDM+/3EwwK0UVTj0SQOv0E5KcEHENL9QQg3ujmEi+zAavulPqXH5907q21lwQeemzkTJH4o2RCCVeYO+YrQIDAQAB-----END PUBLIC KEY-----";

    CKCTokenResult *resForTesting = [[CKCTokenResult alloc] init];
    resForTesting.token = nil;
    resForTesting.errors = nil;
    
    CKCTokenResult *res = [CKCToken generateWithCard:cardParams];
    
    XCTAssertNil(res.token, @"pointer:%p", res.token);
}

- (void)testReturnPubKeyFromJSONString {
    NSString *pubKey = @"-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAhjH8R0jfvvEJwAHRhJi2Q4fLi1p2z10PaDMIhHbD3fp4OqypWaE7p6n6EHig9qnwC/4U7hCiOCqY6uYtgEoDHfbNA87/X0jV8UI522WjQH7Rgkmgk35r75G5m4cYeF6OvCHmAJ9ltaFsLBdr+pK6vKz/3AzwAc/5a6QcO/vR3PHnhE/qU2FOU3Vd8OYN2qcw4TFvitXY2H6YdTNF4YmlFtj4CqQoPL1u/uI0UpsG3/epWMOk44FBlXoZ7KNmJU29xbuiNEm1SWRJS2URMcUxAdUfhzQ2+Z4F0eSo2/cxwlkNA+gZcXnLbEWIfYYvASKpdXBIzgncMBro424z/KUr3QIDAQAB-----END PUBLIC KEY-----";
    NSString *jsonString = @"{\"keys\":[{\"keyValue\":\"-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAhjH8R0jfvvEJwAHRhJi2Q4fLi1p2z10PaDMIhHbD3fp4OqypWaE7p6n6EHig9qnwC/4U7hCiOCqY6uYtgEoDHfbNA87/X0jV8UI522WjQH7Rgkmgk35r75G5m4cYeF6OvCHmAJ9ltaFsLBdr+pK6vKz/3AzwAc/5a6QcO/vR3PHnhE/qU2FOU3Vd8OYN2qcw4TFvitXY2H6YdTNF4YmlFtj4CqQoPL1u/uI0UpsG3/epWMOk44FBlXoZ7KNmJU29xbuiNEm1SWRJS2URMcUxAdUfhzQ2+Z4F0eSo2/cxwlkNA+gZcXnLbEWIfYYvASKpdXBIzgncMBro424z/KUr3QIDAQAB-----END PUBLIC KEY-----\",\"protocolVersion\":\"RSA\",\"keyExpiration\":1661599747000}]}";

    NSString *result = [CKCPubKey fromJSONString: jsonString];


    XCTAssertTrue([result isEqualToString:pubKey]);
}

@end
