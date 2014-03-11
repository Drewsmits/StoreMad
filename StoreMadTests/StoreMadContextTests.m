//
//  StoreMadContextTests.m
//  StoreMad
//
//  Created by Andrew Smith on 8/15/12.
//  Copyright (c) 2012 Andrew B. Smith. All rights reserved.
//

#import "StoreMadContextTests.h"
#import "Department.h"
#import "Employee.h"

@implementation StoreMadContextTests

- (void)testObjectForURI
{    
    NSManagedObject *employee        = [Employee createInContext:self.testContext];
    NSManagedObject *fetchedEmployee = [self.testContext objectForURI:employee.objectURI];
    XCTAssertEqualObjects(employee, fetchedEmployee, @"Should be the same NSManagedObject!");
}

- (void)testObjectForNilURI
{
    NSManagedObject *object = [self.testContext objectForURI:nil];
    XCTAssertNil(object, @"Object should be nil!");
}

- (void)testDeleteObjectAtURI
{
    NSManagedObject *employee = [Employee createInContext:self.testContext];
    [self.testContext deleteObjectAtURI:employee.objectURI];
    XCTAssertTrue([employee hasBeenDeleted], @"Object should be deleted");
}

- (void)testDeleteObject
{
    NSManagedObject *employee = [Employee createInContext:self.testContext];
    [self.testContext save];
    [self.testContext deleteObject:employee];
    XCTAssertTrue([employee hasBeenDeleted], @"Object should be deleted");
}

- (void)testDeleteObjects
{
    NSManagedObject *employee1 = [Employee createInContext:self.testContext];
    NSManagedObject *employee2 = [Employee createInContext:self.testContext];
    NSManagedObject *employee3 = [Employee createInContext:self.testContext];

    [self.testContext deleteObjects:@[employee1, employee2, employee3]];

    XCTAssertTrue([employee1 hasBeenDeleted], @"Object should be deleted");
    XCTAssertTrue([employee2 hasBeenDeleted], @"Object should be deleted");
    XCTAssertTrue([employee3 hasBeenDeleted], @"Object should be deleted");
}

- (void)testExecuteFetchRequest
{
    Employee *employee1 = [Employee createInContext:self.testContext];
    Employee *employee2 = [Employee createInContext:self.testContext];

    employee1.firstName = @"Kevin";
    employee1.lastName = @"Bacon";
    
    employee2.firstName = @"David";
    employee2.lastName = @"Bowie";

    NSFetchRequest *baconFetch = [self.testContext fetchRequestForObjectClass:[Employee class]];
    baconFetch.predicate = [NSPredicate predicateWithFormat:@"lastName == %@", @"Bacon"];
    
    NSArray *fetchedBacons = [self.testContext executeFetchRequest:baconFetch];
    
    XCTAssertEqual(fetchedBacons.count, 1U, @"Context should execute fetch request and return all the correct objects");
    
    if (fetchedBacons.count < 1) return;
    NSManagedObject *fetchedBacon = [fetchedBacons objectAtIndex:0];
    
    BOOL same = ([employee1.objectID isEqual:fetchedBacon.objectID]);
    XCTAssertTrue(same, @"Context should execute fetch request and return the correct object");
}

- (void)testCountForFetchRequest
{
    [Employee createInContext:self.testContext];
    [Employee createInContext:self.testContext];
    
    // create some extra stuff
    [Department createInContext:self.testContext];
    
    NSFetchRequest *employeeFetch = [self.testContext fetchRequestForObjectClass:[Employee class]];
    NSArray *fetchedEmployees = [self.testContext executeFetchRequest:employeeFetch];

    XCTAssertEqual(fetchedEmployees.count, 2U, @"Context should count the correct number of objects");
}

- (void)testAllValuesForPropertyFetchRequest
{
    Employee *employee1 = [Employee createInContext:self.testContext];
    Employee *employee2 = [Employee createInContext:self.testContext];
    Employee *employee3 = [Employee createInContext:self.testContext];

    employee1.employeeId = @(1);
    employee2.employeeId = @(2);
    employee3.employeeId = @(42);
    
    // Need to save to persist properties.
    [self.testContext save];
    
    NSFetchRequest *employeeFetch = [self.testContext findAllFetchRequestForObjectClass:[Employee class]];

    NSArray *fetchedProperties = [self.testContext allValuesForProperty:@"employeeId"
                                                            withRequest:employeeFetch];

    
    BOOL hasAllIds = ([fetchedProperties containsObject:@(1)]
                      && [fetchedProperties containsObject:@(2)]
                      && [fetchedProperties containsObject:@(42)]);
    
    XCTAssertEqual(fetchedProperties.count, 3U, @"Should have 3 properties");
    XCTAssertTrue(hasAllIds, @"Should fetch all the ids that were previously set");
}

@end
