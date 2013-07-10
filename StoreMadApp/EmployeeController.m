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

+ (Employee *)newEmployeeInContext:(NSManagedObjectContext *)context
{
    Employee *newEmployee = [Employee createInContext:context];
    newEmployee.hireDate = [NSDate date];
    return newEmployee;
}

+ (NSFetchRequest *)allEmployeesSortedFetchRequestInContext:(NSManagedObjectContext *)context
{
    // Request
    NSFetchRequest *fetchRequest = [context fetchRequestForObjectClass:[Employee class]];
    
    // Sort
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"hireDate" ascending:YES]];
    
    return fetchRequest;
}

#pragma mark - Actions

+ (void)fireEmployee:(Employee *)employee
{
    
}

@end
