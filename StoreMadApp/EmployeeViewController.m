//
//  EmployeeViewController.m
//  StoreMadApp
//
//  Created by Andrew Smith on 7/8/13.
//  Copyright (c) 2013 Burgess. All rights reserved.
//

#import "EmployeeViewController.h"

#import "Employee.h"
#import "EmployeeController.h"

@interface EmployeeViewController ()

@property (nonatomic, weak) IBOutlet UILabel *firstNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *hireDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *fireDateLabel;

- (IBAction)fireEmployee:(id)sender;

@end

@implementation EmployeeViewController

+ (EmployeeViewController *)newEmployeeViewControllerFromStorybaord
{
    UIStoryboard *employeeStoryboard = [UIStoryboard storyboardWithName:[self description]
                                                                 bundle:nil];
    
    EmployeeViewController *employeeVC = [employeeStoryboard instantiateViewControllerWithIdentifier:[self description]];
    
    return employeeVC;
}

- (void)configureWithEmployee:(Employee *)employee
{
    self.firstNameLabel.text = employee.firstName;
    self.lastNameLabel.text = employee.lastName;
    self.hireDateLabel.text = employee.hireDate.description;
    
    if (employee.isFired) {
    
    } else {
        
    }

    self.employee = employee;
}

#pragma mark - IBAction

- (IBAction)fireEmployee:(id)sender
{
    [EmployeeController fireEmployee:self.employee
                          completion:^{
                              [self configureWithEmployee:self.employee];
                          }];
}

@end
