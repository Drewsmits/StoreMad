//
//  StoreMadContextObserverTests.m
//  StoreMad
//
//  Created by Andrew Smith on 10/9/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import "StoreMadContextObserverTests.h"

@implementation StoreMadContextObserverTests

- (void)testSetNotificationName
{
    SMContextObserver *observer = [SMContextObserver new];
    NSString *invalidNotification = @"burrito";
    STAssertThrows([observer setNotificationName:invalidNotification], @"Setting invalid notification should assert");

    STAssertNoThrow([observer setNotificationName:NSManagedObjectContextWillSaveNotification], @"Setting valid notification should not assert");
    STAssertNoThrow([observer setNotificationName:NSManagedObjectContextDidSaveNotification], @"Setting valid notification should not assert");
    STAssertNoThrow([observer setNotificationName:NSManagedObjectContextObjectsDidChangeNotification], @"Setting valid notification should not assert");
}

- (void)testNilNoticationName
{
    SMContextObserver *observer = [SMContextObserver new];
    STAssertThrows([observer startObservingNotifications], @"Observing a nil notification name should assert");
}

- (void)testNilContext
{
    SMContextObserver *observer = [SMContextObserver new];
    observer.notificationName = NSManagedObjectContextDidSaveNotification;
    STAssertThrows([observer startObservingNotifications], @"Observing a nil context should assert");
}

- (void)testWorkBlock
{
    SMContextObserver *observer = [SMContextObserver new];
    observer.notificationName = NSManagedObjectContextDidSaveNotification;
    observer.context = storeController.managedObjectContext;
    
    __block NSSet *insertedEmployees;
    __block BOOL wasNotified = NO;
    observer.workBlock = ^(NSSet *updateObjects, NSSet *insertedOjects, NSSet *deletedObjects)
    {
        insertedEmployees = [insertedOjects copy];
        wasNotified = YES;
    };
    
    [storeController addContextObserver:observer];
    
    NSManagedObject *employee = [storeController.managedObjectContext insertNewObjectForEntityNamed:@"Employee"];
    
    [storeController.managedObjectContext queueBlockSaveAndWait];
    
    STAssertTrue([insertedEmployees containsObject:employee], @"Work block should run correctly");
}

- (void)testFilterWorkBlock
{
    SMContextObserver *observer = [SMContextObserver new];
    observer.notificationName = NSManagedObjectContextDidSaveNotification;
    observer.context = storeController.managedObjectContext;
    
    NSEntityDescription *employeeEntity = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:storeController.managedObjectContext];
    observer.predicate = [NSPredicate predicateWithFormat:@"entity == %@", employeeEntity];
    
    __block BOOL wasNotified = NO;
    observer.workBlock = ^(NSSet *updateObjects, NSSet *insertedOjects, NSSet *deletedObjects)
    {
        wasNotified = YES;
    };
    
    [storeController addContextObserver:observer];
    
    [storeController.managedObjectContext insertNewObjectForEntityNamed:@"Employee"];
    [storeController.managedObjectContext queueBlockSaveAndWait];
    
    STAssertTrue(wasNotified, @"Work block should run");
    
    wasNotified = NO;
    
    [storeController.managedObjectContext insertNewObjectForEntityNamed:@"Department"];
    [storeController.managedObjectContext queueBlockSaveAndWait];
    
    STAssertFalse(wasNotified, @"Work block should not run");
}

- (void)testAddSaveObserver
{
    __block BOOL wasNotified = NO;
    SMContextObserverBlock workBlock = ^(NSSet *updateObjects, NSSet *insertedOjects, NSSet *deletedObjects)
    {
        wasNotified = YES;
    };
    
    SMContextObserver *observer = [storeController addContextDidSaveObserverWithWorkBlock:workBlock];
    
    [storeController.managedObjectContext insertNewObjectForEntityNamed:@"Employee"];
    [storeController.managedObjectContext queueBlockSaveAndWait];
    
    STAssertTrue(wasNotified, @"Work block should run");
    
    [storeController removeContextObserver:observer];
    
    wasNotified = NO;
    
    [storeController.managedObjectContext insertNewObjectForEntityNamed:@"Department"];
    [storeController.managedObjectContext queueBlockSaveAndWait];
    
    STAssertFalse(wasNotified, @"Work block should not run");
}

@end
