//
//  SMContextObserverControllerTests.m
//  StoreMad
//
//  Created by Andrew Smith on 3/13/14.
//  Copyright (c) 2014 eGraphs. All rights reserved.
//

#import "StoreMadBaseTest.h"

#import "SMContextObserverController.h"

#import "Employee.h"

@interface SMContextObserverControllerTests : StoreMadBaseTest

@property (nonatomic, readonly) SMContextObserverController *controller;

@end

@implementation SMContextObserverControllerTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (SMContextObserverController *)controller
{
    return [SMContextObserverController defaultController];
}

- (void)testFilterWorkBlock
{
    NSEntityDescription *employeeEntity = [NSEntityDescription entityForName:@"Employee"
                                                      inManagedObjectContext:self.testContext];
    
    __block BOOL wasNotified = NO;
    [self.controller addContextObserverForContext:self.testContext
                                        predicate:[NSPredicate predicateWithFormat:@"entity == %@", employeeEntity]
                          contextNotificationType:NSManagedObjectContextDidSaveNotification
                                            queue:nil
                                        workBlock:^(NSSet *updateObjects, NSSet *insertedOjects, NSSet *deletedObjects) {
                                            wasNotified = YES;
                                        }];
    
    [self.testContext stm_insertNewObjectForEntityNamed:@"Employee"];
    [self.testContext stm_queueBlockSaveAndWait];
    
    XCTAssertTrue(wasNotified, @"Work block should run");
    
    wasNotified = NO;
    
    [self.testContext stm_insertNewObjectForEntityNamed:@"Department"];
    [self.testContext stm_queueBlockSaveAndWait];
    
    XCTAssertFalse(wasNotified, @"Work block should not run");
}

- (void)testSetNotificationName
{
    XCTAssertThrows([self.controller addContextObserverForContext:self.testContext
                                                        predicate:nil
                                          contextNotificationType:@"burrito"
                                                            queue:nil
                                                        workBlock:nil],
                    @"Setting invalid notification should assert");
    
    XCTAssertNoThrow([self.controller addContextObserverForContext:self.testContext
                                                        predicate:nil
                                          contextNotificationType:NSManagedObjectContextWillSaveNotification
                                                            queue:nil
                                                        workBlock:nil],
                    @"Setting invalid notification should not assert");
    
    XCTAssertNoThrow([self.controller addContextObserverForContext:self.testContext
                                                         predicate:nil
                                           contextNotificationType:NSManagedObjectContextDidSaveNotification
                                                             queue:nil
                                                         workBlock:nil],
                     @"Setting invalid notification should assert");
    
    XCTAssertNoThrow([self.controller addContextObserverForContext:self.testContext
                                                         predicate:nil
                                           contextNotificationType:NSManagedObjectContextObjectsDidChangeNotification
                                                             queue:nil
                                                         workBlock:nil],
                     @"Setting invalid notification should assert");
}

- (void)testNilContext
{
    XCTAssertThrows([self.controller addContextObserverForContext:nil
                                                        predicate:nil
                                          contextNotificationType:NSManagedObjectContextDidSaveNotification
                                                            queue:nil
                                                        workBlock:nil],
                    @"Observing a nil context should assert");
}

- (void)testStopObserver
{
    NSEntityDescription *employeeEntity = [NSEntityDescription entityForName:@"Employee"
                                                      inManagedObjectContext:self.testContext];

    
    __block BOOL wasNotified = NO;
    id observer = [self.controller addContextObserverForContext:self.testContext
                                                      predicate:[NSPredicate predicateWithFormat:@"entity == %@", employeeEntity]
                                        contextNotificationType:NSManagedObjectContextDidSaveNotification
                                                          queue:nil
                                                      workBlock:^(NSSet *updateObjects,
                                                                  NSSet *insertedOjects,
                                                                  NSSet *deletedObjects) {
                                                          wasNotified = YES;
                                                      }];
    
    
    [self.testContext stm_insertNewObjectForEntityNamed:@"Employee"];
    [self.testContext stm_queueBlockSaveAndWait];
    
    XCTAssertTrue(wasNotified, @"Work block should run");
    
    [self.controller removeContextObserver:observer];
    
    wasNotified = NO;
    
    [self.testContext stm_insertNewObjectForEntityNamed:@"Department"];
    [self.testContext stm_queueBlockSaveAndWait];
    
    XCTAssertFalse(wasNotified, @"Work block should not run");
    
    [self.controller removeContextObserver:observer];
}

- (void)testObserveSpecificObject
{
    Employee *employee = [Employee stm_createInContext:self.testContext];
    [employee.managedObjectContext stm_save];
    
    __block NSManagedObject *updatedObject;
    void(^workBlock)(NSManagedObject *object) = ^(NSManagedObject *object) {
        updatedObject = object;
    };
    
    id observer = [self.controller addContextObserverForChangesToObject:employee
                                                              workBlock:workBlock];
    
    [self.testContext performBlockAndWait:^{
        employee.firstName = @"Bob";
        [self.testContext stm_save];
    }];
    
    XCTAssertEqual(updatedObject, employee, @"Updated object should be employee");
    
    [self.controller removeContextObserver:observer];
}


@end
