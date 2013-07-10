//
//  EmployeeFireOperation.m
//  StoreMadApp
//
//  Created by Andrew Smith on 7/8/13.
//  Copyright (c) 2013 Burgess. All rights reserved.
//

#import "EmployeeFireOperation.h"

#import "Employee.h"

@interface EmployeeFireOperation ()

@property (nonatomic, strong) NSManagedObjectID *employeeObjectId;
@property (nonatomic, strong) NSManagedObjectContext *mainContext;

@end

@implementation EmployeeFireOperation

+ (EmployeeFireOperation *)fireOperationForEmplyeeWithID:(NSManagedObjectID *)employeeObjectId
                                               inContext:(NSManagedObjectContext *)context
{
    EmployeeFireOperation *operation = [self new];
    operation.employeeObjectId = employeeObjectId;
    operation.mainContext = context;
    return operation;
}

- (void)main
{
    NSManagedObjectContext *backgroundContext = [self.mainContext threadSafeCopy];
    
    Employee *employee = [backgroundContext objectWithID:self.employeeObjectId];
    if (!employee) {
        // do something
        return;
    }

    // Maybe some long running thing
    sleep(3);
    employee.fireDate = [NSDate date];
    
    // save
    [backgroundContext save];
}

@end
