//
//  RootViewController.m
//  StoreMadApp
//
//  Created by Andrew Smith on 7/1/13.
//  Copyright (c) 2013 Burgess. All rights reserved.
//

#import "RootViewController.h"

#import "Employee.h"
#import "EmployeeController.h"

@implementation RootViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.storeController = [[AppDelegate sharedInstance] storeController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(createEmployees)
               withObject:nil
               afterDelay:3.0];
}

- (void)createEmployees
{
    NSManagedObjectContext *context = self.storeController.managedObjectContext;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSArray *firstNames = @[@"Poison", @"Clark", @"Bruce", @"Peter", @"Wonder"];
        NSArray *lastNames = @[@"Ivy", @"Kent", @"Wayne", @"Parker", @"Woman"];
        
        [context performBlock:^{
            // Create a lot of employees
            [firstNames enumerateObjectsUsingBlock:^(NSString *firstName, NSUInteger idx, BOOL *stop) {
                Employee *employee = [EmployeeController newEmployeeInContext:context];
                employee.firstName = firstName;
                employee.lastName = [lastNames objectAtIndex:idx];
            }];
            
            // save
            [context save];
        }];
    });
}

@end
