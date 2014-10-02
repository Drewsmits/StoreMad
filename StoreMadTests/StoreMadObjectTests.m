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
    Employee *object = [Employee stm_createInContext:self.testContext];
    
    XCTAssertFalse([object stm_hasBeenDeleted], @"Object should not be deleted");
    
    [self.testContext stm_queueBlockSave];
    
    XCTAssertFalse([object stm_hasBeenDeleted], @"Object should not be deleted");
    
    [self.testContext deleteObject:object];
    
    XCTAssertTrue([object stm_hasBeenDeleted], @"Object should be deleted");
}

- (void)testHasBeenSaved
{
    Employee *object = [Employee stm_createInContext:self.testContext];
    
    XCTAssertFalse([object stm_hasBeenSaved], @"Object should not be saved");
    
    [self.testContext save:nil];

    XCTAssertTrue([object stm_hasBeenSaved], @"Object should be saved");
}

- (void)testCreateInContext
{
    Employee *object = [Employee stm_createInContext:self.testContext];

    XCTAssertTrue([object isInserted], @"Object should be inserted");
    XCTAssertFalse([object stm_hasBeenSaved], @"Object should not be saved");
}

- (void)testExecuteFetchRequest
{
    
}

@end
