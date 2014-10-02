//
//  SMStoreControllerTests.m
//  StoreMad
//
//  Created by Andrew Smith on 10/15/13.
//  Copyright (c) 2013 eGraphs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "StoreMadBaseTest.h"

@interface SMStoreControllerTests : StoreMadBaseTest

@end

@implementation SMStoreControllerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testResetController
{
    NSManagedObjectContext *context = self.storeController.managedObjectContext;
    
    [self.storeController reset];
    
    BOOL equal = [context isEqual:self.storeController.managedObjectContext];
    
    XCTAssertFalse(equal, @"Contexts should not be equal after reset");
}

- (void)testDeleteStore
{
    [self.storeController.managedObjectContext stm_save];
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[self.storeController.storeURL path]];

    XCTAssertTrue(exists, @"Store should exist at URL before delete store");
    
    [self.storeController deleteStore];
    
    exists = [[NSFileManager defaultManager] fileExistsAtPath:[self.storeController.storeURL path]];

    XCTAssertFalse(exists, @"Store should not exist at URL after delete store");
}

@end
