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

@interface EmployeeTableViewController () <SMDataSourceDelegate>

@end

@implementation EmployeeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    
    [self buildDataSource];
}

#pragma mark - IBAction

- (IBAction)createEmployees:(id)sender
{
    NSManagedObjectContext *context = self.storeController.managedObjectContext;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSArray *firstNames = @[@"Poison", @"Clark", @"Bruce", @"Peter", @"Wonder"];
        NSArray *lastNames = @[@"Ivy", @"Kent", @"Wayne", @"Parker", @"Woman"];
        
        [context performBlock:^{
            // Create a lot of employees
            [firstNames enumerateObjectsUsingBlock:^(NSString *firstName, NSUInteger idx, BOOL *stop) {
                Employee *employee = (Employee *)[context insertNewObjectForEntityNamed:NSStringFromClass([Employee class])];
                employee.hireDate  = [NSDate date];
                employee.firstName = firstName;
                employee.lastName  = [lastNames objectAtIndex:idx];
            }];
            
            // save
            [context save];
        }];
    });
}

- (IBAction)reset:(id)sender
{
    [self.storeController reset];
    [self buildDataSource];
    [self.tableView reloadData];
}

#pragma mark - Store Mad

- (void)buildDataSource
{
    self.storeMadDataSource = [SMTableViewDataSource new];
    
    NSManagedObjectContext *context = self.storeController.managedObjectContext;
    NSFetchRequest *allEmployeesFetch = [EmployeeController allEmployeesSortedFetchRequestInContext:context];
    
    [self.storeMadDataSource setupWithTableView:self.tableView
                                   fetchRequest:allEmployeesFetch
                                        context:context
                             sectionNameKeyPath:nil
                                      cacheName:nil];
    
    self.storeMadDataSource.dataSourceDelegate = self;

    
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

- (void)dataSource:(SMDataSource *)dataSource
           isEmpty:(BOOL)empty
{
    NSLog(@"empty!");
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Employee *employee = [self.storeMadDataSource objectAtIndexPath:indexPath];
    
    EmployeeViewController *employeeVC = [EmployeeViewController newEmployeeViewControllerFromStorybaord];
    employeeVC.employee = employee;
    
    [self.navigationController pushViewController:employeeVC animated:YES];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did end editing");
}

//- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
//       toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
//{
//    
//}

@end
