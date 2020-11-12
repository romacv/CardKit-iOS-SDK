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
#import "CardKConfig.h"

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
    

    
//    XCTAssertEqual(res, resForTesting, @"(%@) equal to (%@)", res, resForTesting);
}

- (void)testPerformanceExample {
    CKCBindingParams *bindingParams = [[CKCBindingParams alloc] init];
    bindingParams.bindingID = @"das";
    bindingParams.cvc = @"123";
    bindingParams.mdOrder = @"mdOrder";
    bindingParams.pubKey = @"-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoIITqh9xlGx4tWA+aucb0V0YuFC9aXzJb0epdioSkq3qzNdRSZIxe/dHqcbMN2SyhzvN6MRVl3xyjGAV+lwk8poD4BRW3VwPUkT8xG/P/YLzi5N8lY6ILlfw6WCtRPK5bKGGnERcX5dqL60LhOPRDSYT5NHbbp/J2eFWyLigdU9Sq7jvz9ixOLh6xD7pgNgHtnOJ3Cw0Gqy03r3+m3+CBZwrzcp7ZFs41bit7/t1nIqgx78BCTPugap88Gs+8ZjdfDvuDM+/3EwwK0UVTj0SQOv0E5KcEHENL9QQg3ujmEi+zAavulPqXH5907q21lwQeemzkTJH4o2RCCVeYO+YrQIDAQAB-----END PUBLIC KEY-----";

    CKCTokenResult *resForTesting = [[CKCTokenResult alloc] init];
    resForTesting.token = nil;
    resForTesting.errors = nil;
    
    CKCTokenResult *res = [CKCToken generateWithBinding:(bindingParams)];
}

@end
