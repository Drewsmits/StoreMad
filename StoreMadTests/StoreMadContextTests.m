//
//  StoreMadContextTests.m
//  StoreMad
//
//  Created by Andrew Smith on 8/15/12.
//  Copyright (c) 2012 Andrew B. Smith. All rights reserved.
//

#import "StoreMadContextTests.h"

@implementation StoreMadContextTests

- (void)testObjectForURI
{    
    NSManagedObject *employee        = [storeController.managedObjectContext insertNewObjectForEntityNamed:@"Employee"];
    NSManagedObject *fetchedEmployee = [storeController.managedObjectContext objectForURI:employee.objectURI];
    STAssertEqualObjects(employee, fetchedEmployee, @"Should be the same NSManagedObject!");
}

- (void)testObjectForNilURI
{
    NSManagedObject *object = [storeController.managedObjectContext objectForURI:nil];
    STAssertNil(object, @"Object should be nil!");
}

- (void)testDeleteObjectAtURI
{
    NSManagedObject *employee = [storeController.managedObjectContext insertNewObjectForEntityNamed:@"Employee"];
    [storeController.managedObjectContext deleteObjectAtURI:employee.objectURI];
    STAssertTrue([employee hasBeenDeleted], @"Object should be deleted");
}

- (void)testDeleteObjects
{
    NSManagedObject *employee1 = [storeController.managedObjectContext insertNewObjectForEntityNamed:@"Employee"];
    NSManagedObject *employee2 = [storeController.managedObjectContext insertNewObjectForEntityNamed:@"Employee"];
    NSManagedObject *employee3 = [storeController.managedObjectContext insertNewObjectForEntityNamed:@"Employee"];

    [storeController.managedObjectContext deleteObjects:@[employee1, employee2, employee3]];

    STAssertTrue([employee1 hasBeenDeleted], @"Object should be deleted");
    STAssertTrue([employee2 hasBeenDeleted], @"Object should be deleted");
    STAssertTrue([employee3 hasBeenDeleted], @"Object should be deleted");
}

- (void)testQueueDeleteObject
{
    NSManagedObject *employee = [storeController.managedObjectContext insertNewObjectForEntityNamed:@"Employee"];
    [storeController.managedObjectContext queueDeleteObject:employee];
    STAssertTrue([employee hasBeenDeleted], @"Object should be deleted");
}

@end
