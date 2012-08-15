//
//  StoreMadContextTests.m
//  StoreMad
//
//  Created by Andrew Smith on 8/15/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
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

@end
