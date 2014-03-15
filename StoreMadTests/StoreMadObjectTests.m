//
//  StoreMadObjectTests.m
//  StoreMad
//
//  Created by Andrew Smith on 9/28/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import "StoreMadBaseTest.h"
#import "Employee.h"

@interface StoreMadObjectTests : StoreMadBaseTest

@end

@implementation StoreMadObjectTests

- (void)testHasBeenDeleted
{
    Employee *object = [Employee createInContext:self.testContext];
    
    XCTAssertFalse([object hasBeenDeleted], @"Object should not be deleted");
    
    [self.testContext queueBlockSave];
    
    XCTAssertFalse([object hasBeenDeleted], @"Object should not be deleted");
    
    [self.testContext deleteObject:object];
    
    XCTAssertTrue([object hasBeenDeleted], @"Object should be deleted");
}

- (void)testHasBeenSaved
{
    Employee *object = [Employee createInContext:self.testContext];
    
    XCTAssertFalse([object hasBeenSaved], @"Object should not be saved");
    
    [self.testContext save:nil];

    XCTAssertTrue([object hasBeenSaved], @"Object should be saved");
}

- (void)testCreateInContext
{
    Employee *object = [Employee createInContext:self.testContext];

    XCTAssertTrue([object isInserted], @"Object should be inserted");
    XCTAssertFalse([object hasBeenSaved], @"Object should not be saved");
}

- (void)testExecuteFetchRequest
{
    
}

@end
