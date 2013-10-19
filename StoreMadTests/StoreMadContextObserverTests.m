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

//- (void)testSetNotificationName
//{
//    SMContextObserver *observer = [SMContextObserver new];
//    NSString *invalidNotification = @"burrito";
//    STAssertThrows([observer setNotificationName:invalidNotification], @"Setting invalid notification should assert");
//
//    STAssertNoThrow([observer setNotificationName:NSManagedObjectContextWillSaveNotification], @"Setting valid notification should not assert");
//    STAssertNoThrow([observer setNotificationName:NSManagedObjectContextDidSaveNotification], @"Setting valid notification should not assert");
//    STAssertNoThrow([observer setNotificationName:NSManagedObjectContextObjectsDidChangeNotification], @"Setting valid notification should not assert");
//}

//- (void)testNilContext
//{
//    SMContextObserver *observer = [SMContextObserver new];
//    observer.notificationName = NSManagedObjectContextDidSaveNotification;
//    STAssertThrows([observer startObservingNotifications], @"Observing a nil context should assert");
//}

//- (void)testWorkBlock
//{
//    SMContextObserver *observer = [SMContextObserver new];
//    observer.notificationName = NSManagedObjectContextDidSaveNotification;
//    observer.context = self.testContext;
//    
//    __block NSSet *insertedEmployees;
//    __block BOOL wasNotified = NO;
//    observer.workBlock = ^(NSSet *updateObjects, NSSet *insertedOjects, NSSet *deletedObjects)
//    {
//        insertedEmployees = [insertedOjects copy];
//        wasNotified = YES;
//    };
//    
//    [self.storeController addContextObserver:observer];
//    
//    NSManagedObject *employee = [self.testContext insertNewObjectForEntityNamed:@"Employee"];
//    
//    [self.testContext queueBlockSaveAndWait];
//    
//    STAssertTrue([insertedEmployees containsObject:employee], @"Work block should run correctly");
//}

//- (void)testFilterWorkBlock
//{
//    SMContextObserver *observer = [SMContextObserver new];
//    observer.notificationName = NSManagedObjectContextDidSaveNotification;
//    observer.context = self.testContext;
//    
//    NSEntityDescription *employeeEntity = [NSEntityDescription entityForName:@"Employee"
//                                                      inManagedObjectContext:self.testContext];
//    observer.predicate = [NSPredicate predicateWithFormat:@"entity == %@", employeeEntity];
//    
//    __block BOOL wasNotified = NO;
//    observer.workBlock = ^(NSSet *updateObjects, NSSet *insertedOjects, NSSet *deletedObjects)
//    {
//        wasNotified = YES;
//    };
//    
//    [self.storeController addContextObserver:observer];
//    
//    [self.testContext insertNewObjectForEntityNamed:@"Employee"];
//    [self.testContext queueBlockSaveAndWait];
//    
//    STAssertTrue(wasNotified, @"Work block should run");
//    
//    wasNotified = NO;
//    
//    [self.testContext insertNewObjectForEntityNamed:@"Department"];
//    [self.testContext queueBlockSaveAndWait];
//    
//    STAssertFalse(wasNotified, @"Work block should not run");
//}

//- (void)testAddSaveObserver
//{
//    __block BOOL wasNotified = NO;
//    SMContextObserverBlock workBlock = ^(NSSet *updateObjects, NSSet *insertedOjects, NSSet *deletedObjects)
//    {
//        wasNotified = YES;
//    };
//    
//    SMContextObserver *observer = [self.storeController addContextDidSaveObserverWithWorkBlock:workBlock];
//    
//    [self.testContext insertNewObjectForEntityNamed:@"Employee"];
//    [self.testContext queueBlockSaveAndWait];
//    
//    STAssertTrue(wasNotified, @"Work block should run");
//    
//    [self.storeController removeContextObserver:observer];
//    
//    wasNotified = NO;
//    
//    [self.testContext insertNewObjectForEntityNamed:@"Department"];
//    [self.testContext queueBlockSaveAndWait];
//    
//    STAssertFalse(wasNotified, @"Work block should not run");
//}

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
