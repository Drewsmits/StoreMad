//
//  StoreMadObjectTests.m
//  StoreMad
//
//  Created by Andrew Smith on 9/28/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import "StoreMadObjectTests.h"
#import "Employee.h"

@implementation StoreMadObjectTests

- (void)testHasBeenDeleted
{
    Employee *object = [Employee createInContext:self.testContext];
    
    STAssertFalse([object hasBeenDeleted], @"Object should not be deleted");
    
    [self.testContext queueBlockSave];
    
    STAssertFalse([object hasBeenDeleted], @"Object should not be deleted");
    
    [self.testContext deleteObject:object];
    
    STAssertTrue([object hasBeenDeleted], @"Object should be deleted");
}

- (void)testHasBeenSaved
{
    Employee *object = [Employee createInContext:self.testContext];
    
    STAssertFalse([object hasBeenSaved], @"Object should not be saved");
    
    [self.testContext save:nil];

    STAssertTrue([object hasBeenSaved], @"Object should be saved");
}

- (void)testCreateInContext
{
    Employee *object = [Employee createInContext:self.testContext];

    STAssertTrue([object isInserted], @"Object should be inserted");
}

- (void)testDeleteObject
{
    Employee *object = [Employee createInContext:self.testContext];
    
    [object deleteObject];
    
    STAssertTrue(object.isDeleted, @"Object should be deleted");
}

@end
