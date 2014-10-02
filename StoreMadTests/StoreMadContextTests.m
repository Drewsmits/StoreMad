//
//  StoreMadContextTests.m
//  StoreMad
//
//  Created by Andrew Smith on 8/15/12.
//  Copyright (c) 2012 Andrew B. Smith. All rights reserved.
//

#import "Department.h"
#import "Employee.h"

#import "StoreMadBaseTest.h"

@interface StoreMadContextTests : StoreMadBaseTest

@end

@implementation StoreMadContextTests

- (void)testObjectForURI
{    
    NSManagedObject *employee        = [Employee stm_createInContext:self.testContext];
    NSManagedObject *fetchedEmployee = [self.testContext stm_objectForURI:employee.stm_objectURI];
    XCTAssertEqualObjects(employee, fetchedEmployee, @"Should be the same NSManagedObject!");
}

- (void)testObjectForNilURI
{
    NSManagedObject *object = [self.testContext stm_objectForURI:nil];
    XCTAssertNil(object, @"Object should be nil!");
}

- (void)testDeleteObjectAtURI
{
    NSManagedObject *employee = [Employee stm_createInContext:self.testContext];
    [self.testContext stm_deleteObjectAtURI:employee.stm_objectURI];
    XCTAssertTrue([employee stm_hasBeenDeleted], @"Object should be deleted");
}

- (void)testDeleteObject
{
    NSManagedObject *employee = [Employee stm_createInContext:self.testContext];
    [self.testContext stm_save];
    [self.testContext deleteObject:employee];
    XCTAssertTrue([employee stm_hasBeenDeleted], @"Object should be deleted");
}

- (void)testDeleteObjects
{
    NSManagedObject *employee1 = [Employee stm_createInContext:self.testContext];
    NSManagedObject *employee2 = [Employee stm_createInContext:self.testContext];
    NSManagedObject *employee3 = [Employee stm_createInContext:self.testContext];

    [self.testContext stm_deleteObjects:@[employee1, employee2, employee3]];

    XCTAssertTrue([employee1 stm_hasBeenDeleted], @"Object should be deleted");
    XCTAssertTrue([employee2 stm_hasBeenDeleted], @"Object should be deleted");
    XCTAssertTrue([employee3 stm_hasBeenDeleted], @"Object should be deleted");
}

- (void)testExecuteFetchRequest
{
    Employee *employee1 = [Employee stm_createInContext:self.testContext];
    Employee *employee2 = [Employee stm_createInContext:self.testContext];

    employee1.firstName = @"Kevin";
    employee1.lastName = @"Bacon";
    
    employee2.firstName = @"David";
    employee2.lastName = @"Bowie";

    NSFetchRequest *baconFetch = [self.testContext stm_fetchRequestForObjectClass:[Employee class]];
    baconFetch.predicate = [NSPredicate predicateWithFormat:@"lastName == %@", @"Bacon"];
    
    NSArray *fetchedBacons = [self.testContext stm_executeFetchRequest:baconFetch];
    
    XCTAssertEqual(fetchedBacons.count, 1U, @"Context should execute fetch request and return all the correct objects");
    
    if (fetchedBacons.count < 1) return;
    NSManagedObject *fetchedBacon = [fetchedBacons objectAtIndex:0];
    
    BOOL same = ([employee1.objectID isEqual:fetchedBacon.objectID]);
    XCTAssertTrue(same, @"Context should execute fetch request and return the correct object");
}

- (void)testExecuteFetchForFirstObject
{
    Employee *employee1 = [Employee stm_createInContext:self.testContext];
    Employee *employee2 = [Employee stm_createInContext:self.testContext];
    
    employee1.firstName = @"Kevin";
    employee1.lastName = @"Bacon";
    
    employee2.firstName = @"Zazzle";
    employee2.lastName = @"Zeesleson";
    
    NSFetchRequest *baconFetch = [self.testContext stm_fetchRequestForObjectClass:[Employee class]];
    [baconFetch setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]]];
    
    NSManagedObject *fetchedBacon = [self.testContext stm_executeFetchRequestAndReturnFirstObject:baconFetch];
    
    XCTAssertEqualObjects(employee1, fetchedBacon, @"Should fetch the correct employee");
}

- (void)testCountForFetchRequest
{
    [Employee stm_createInContext:self.testContext];
    [Employee stm_createInContext:self.testContext];
    
    // create some extra stuff
    [Department stm_createInContext:self.testContext];
    
    NSFetchRequest *employeeFetch = [self.testContext stm_fetchRequestForObjectClass:[Employee class]];
    NSUInteger count = [self.testContext stm_countForFetchRequest:employeeFetch];

    XCTAssertEqual(count, 2U, @"Context should count the correct number of objects");
}

- (void)testAllValuesForPropertyFetchRequest
{
    Employee *employee1 = [Employee stm_createInContext:self.testContext];
    Employee *employee2 = [Employee stm_createInContext:self.testContext];
    Employee *employee3 = [Employee stm_createInContext:self.testContext];

    employee1.employeeId = @(1);
    employee2.employeeId = @(2);
    employee3.employeeId = @(42);
    
    // Need to save to persist properties.
    [self.testContext stm_save];
    
    NSFetchRequest *employeeFetch = [self.testContext stm_findAllFetchRequestForObjectClass:[Employee class]];

    NSArray *fetchedProperties = [self.testContext stm_allValuesForProperty:@"employeeId"
                                                            withRequest:employeeFetch];

    
    BOOL hasAllIds = ([fetchedProperties containsObject:@(1)]
                      && [fetchedProperties containsObject:@(2)]
                      && [fetchedProperties containsObject:@(42)]);
    
    XCTAssertEqual(fetchedProperties.count, 3U, @"Should have 3 properties");
    XCTAssertTrue(hasAllIds, @"Should fetch all the ids that were previously set");
}

@end
