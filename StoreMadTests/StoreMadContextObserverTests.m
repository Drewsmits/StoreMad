//
//  StoreMadContextObserverTests.m
//  StoreMad
//
//  Created by Andrew Smith on 10/9/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import "StoreMadContextObserverTests.h"

#import "Employee.h"

@implementation StoreMadContextObserverTests

- (void)testSetNotificationName
{
    STAssertThrows([SMContextObserver observerInContext:self.testContext
                                              predicate:nil
                                    contextNotification:@"burrito"
                                              workBlock:nil],
                   @"Setting invalid notification should assert");

    STAssertNoThrow([SMContextObserver observerInContext:self.testContext
                                               predicate:nil
                                     contextNotification:NSManagedObjectContextWillSaveNotification
                                               workBlock:nil],
                    @"Setting valid notification should not assert");
    
    STAssertNoThrow([SMContextObserver observerInContext:self.testContext
                                               predicate:nil
                                     contextNotification:NSManagedObjectContextDidSaveNotification
                                               workBlock:nil],
                    @"Setting valid notification should not assert");
    
    STAssertNoThrow([SMContextObserver observerInContext:self.testContext
                                               predicate:nil
                                     contextNotification:NSManagedObjectContextObjectsDidChangeNotification
                                               workBlock:nil],
                   @"Setting valid notification should not assert");
}

- (void)testNilContext
{
    STAssertThrows([SMContextObserver observerInContext:nil
                                              predicate:nil
                                    contextNotification:NSManagedObjectContextDidSaveNotification
                                              workBlock:nil], @"Observing a nil context should assert");
}

- (void)testFilterWorkBlock
{
    NSEntityDescription *employeeEntity = [NSEntityDescription entityForName:@"Employee"
                                                      inManagedObjectContext:self.testContext];
    
    __block BOOL wasNotified = NO;
    SMContextObserver *observer = [SMContextObserver observerInContext:self.testContext
                                                             predicate:[NSPredicate predicateWithFormat:@"entity == %@", employeeEntity]
                                                   contextNotification:NSManagedObjectContextDidSaveNotification
                                                             workBlock:^(NSSet *updateObjects, NSSet *insertedOjects, NSSet *deletedObjects) {                                                               wasNotified = YES;
                                                             }];
    
    [observer startObservingNotifications];
     
    [self.testContext insertNewObjectForEntityNamed:@"Employee"];
    [self.testContext queueBlockSaveAndWait];
    
    STAssertTrue(wasNotified, @"Work block should run");
    
    wasNotified = NO;
    
    [self.testContext insertNewObjectForEntityNamed:@"Department"];
    [self.testContext queueBlockSaveAndWait];
    
    STAssertFalse(wasNotified, @"Work block should not run");
}

- (void)testStopObserver
{
    __block BOOL wasNotified = NO;
    SMContextObserverBlock workBlock = ^(NSSet *updateObjects, NSSet *insertedOjects, NSSet *deletedObjects)
    {
        wasNotified = YES;
    };
    
    SMContextObserver *observer = [SMContextObserver observerInContext:self.testContext
                                                             predicate:nil
                                                   contextNotification:NSManagedObjectContextDidSaveNotification
                                                             workBlock:workBlock];
    [observer startObservingNotifications];
    
    [self.testContext insertNewObjectForEntityNamed:@"Employee"];
    [self.testContext queueBlockSaveAndWait];
    
    STAssertTrue(wasNotified, @"Work block should run");
    
    [observer stopObservingNotifications];
    
    wasNotified = NO;
    
    [self.testContext insertNewObjectForEntityNamed:@"Department"];
    [self.testContext queueBlockSaveAndWait];
    
    STAssertFalse(wasNotified, @"Work block should not run");
}

- (void)testObserveSpecificObject
{
    Employee *employee = [Employee createInContext:self.testContext];
    
    __block NSManagedObject *updatedObject;
    void(^workBlock)(NSManagedObject *object) = ^(NSManagedObject *object) {
        updatedObject = object;
    };

    SMContextObserver *observer = [SMContextObserver observerForChangesToObject:employee
                                                                      workBlock:workBlock];
    
    [observer startObservingNotifications];
    
    [self.testContext performBlockAndWait:^{
        employee.firstName = @"Bob";
        [self.testContext save];
    }];
    
    STAssertEquals(updatedObject, employee, @"Updated object should be employee");
}

@end
