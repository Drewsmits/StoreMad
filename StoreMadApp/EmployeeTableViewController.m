//
//  EmployeeTableViewController.m
//  StoreMadApp
//
//  Created by Andrew Smith on 7/1/13.
//  Copyright (c) 2013 Burgess. All rights reserved.
//

#import "EmployeeTableViewController.h"

#import "Employee.h"
#import "EmployeeController.h"
#import "EmployeeTableViewCell.h"
#import "EmployeeViewController.h"

@implementation EmployeeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.storeMadDataSource = [SMTableViewDataSource new];
    
    NSManagedObjectContext *context = self.storeController.managedObjectContext;
    NSFetchRequest *allEmployeesFetch = [EmployeeController allEmployeesSortedFetchRequestInContext:context];
    
    [self.storeMadDataSource setupWithTableViewController:self
                                             fetchRequest:allEmployeesFetch
                                                  context:context
                                       sectionNameKeyPath:nil
                                                cacheName:nil];
    
    [self.storeMadDataSource performFetch];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.storeMadDataSource.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.storeMadDataSource numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EmployeeTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - SMTableViewController

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    EmployeeTableViewCell *employeeCell = (EmployeeTableViewCell *)cell;
    
    Employee *employee = [self.storeMadDataSource objectAtIndexPath:indexPath];
    
    employeeCell.firstNameLabel.text = employee.firstName;
    employeeCell.lastNameLabel.text = employee.lastName;
    employeeCell.hireDateLabel.text = [employee.hireDate description];
    
    if (employee.isFired) {
        employeeCell.backgroundColor = [UIColor redColor];
    } else {
        employeeCell.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Employee *employee = [self.storeMadDataSource objectAtIndexPath:indexPath];
    
    EmployeeViewController *employeeVC = [EmployeeViewController newEmployeeViewControllerFromStorybaord];
    
    [self.navigationController pushViewController:employeeVC animated:YES];
    
    [employeeVC configureWithEmployee:employee];
    
}

@end
