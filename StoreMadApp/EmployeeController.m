//
//  EmployeeController.m
//  StoreMadApp
//
//  Created by Andrew Smith on 7/1/13.
//  Copyright (c) 2013 Burgess. All rights reserved.
//

#import "EmployeeController.h"
#import "Employee.h"

@implementation EmployeeController

#pragma mark - Core Data

+ (NSFetchRequest *)allEmployeesSortedFetchRequestInContext:(NSManagedObjectContext *)context
{
    // Request
    NSFetchRequest *fetchRequest = [context fetchRequestForObjectClass:[Employee class]];
    
    // Sort
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"hireDate" ascending:NO]];
    
    return fetchRequest;
}

#pragma mark - Actions

+ (void)fireEmployee:(Employee *)employee
          completion:(void (^)(void))completion
{
    NSManagedObjectContext *context = employee.managedObjectContext;
    [context performBlockAndWait:^{
        employee.fireDate = [NSDate date];
        [context save];
        if (completion) completion ();
    }];
}

+ (void)hireEmployee:(Employee *)employee
          completion:(void (^)(void))completion
{
    if (!employee.isFired) {
        if (completion) completion();
        return;
    }
    NSManagedObjectContext *context = employee.managedObjectContext;
    [context performBlockAndWait:^{
        employee.fireDate = nil;
        employee.hireDate = [NSDate date];
        [context save];
        if (completion) completion ();
    }];
}

@end
