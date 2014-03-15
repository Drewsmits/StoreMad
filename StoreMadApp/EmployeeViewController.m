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

#import <StoreMad/SMContextObserverController.h>

@interface EmployeeViewController ()

@property (nonatomic, weak) IBOutlet UILabel *firstNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *hireDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *fireDateLabel;

@property (nonatomic, weak) IBOutlet UILabel *longRunningLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activity;

@property (nonatomic, strong) id observer;
@property (nonatomic, strong) id longObserver;

@property (nonatomic, strong) NSOperationQueue *asyncQueue;

@end

@implementation EmployeeViewController

- (void)dealloc
{
    [[SMContextObserverController defaultController] removeContextObserver:self.observer];
    [[SMContextObserverController defaultController] removeContextObserver:self.longObserver];
}

+ (EmployeeViewController *)newEmployeeViewControllerFromStorybaord
{
    UIStoryboard *employeeStoryboard = [UIStoryboard storyboardWithName:[self description]
                                                                 bundle:nil];
    
    EmployeeViewController *employeeVC = [employeeStoryboard instantiateViewControllerWithIdentifier:[self description]];
    
    return employeeVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureWithEmployee:_employee];
    self.longRunningLabel.hidden = YES;
    [self.activity stopAnimating];
    
    //
    // Long running job observer
    //
    _asyncQueue = [[NSOperationQueue alloc] init];
    __weak EmployeeViewController *weakSelf = self;
    self.longObserver = [[SMContextObserverController defaultController] addContextObserverForChangesToObject:_employee
                                                                                                        queue:_asyncQueue
                                                                                                   workBlock:^(NSManagedObject *object) {
                                                                                                       [weakSelf startLongRunningTask];
                                                                                                   }];
}

- (void)configureWithEmployee:(Employee *)employee
{
    self.firstNameLabel.text = employee.firstName;
    self.lastNameLabel.text = employee.lastName;
    self.hireDateLabel.text = employee.hireDate.description;
    _fireDateLabel.hidden = !employee.isFired;

    [self performSelectorInBackground:@selector(createObserver) withObject:nil];

    self.employee = employee;
}

- (void)createObserver
{
    if (!_observer) {
        __weak EmployeeViewController *weakSelf = self;
        self.observer = [[SMContextObserverController defaultController] addContextObserverForChangesToObject:_employee
                                                                                                    workBlock:^(NSManagedObject *object) {
                                                                                                        [weakSelf configureWithEmployee:weakSelf.employee];
                                                                                                    }];
    }
}

#pragma mark - IBAction

- (IBAction)fireEmployee:(id)sender
{
    [EmployeeController fireEmployee:self.employee
                          completion:^{
                              NSLog(@"FIRED!");
                          }];
}

- (IBAction)hireEmployee:(id)sender
{
    [EmployeeController hireEmployee:self.employee
                          completion:^{
                              NSLog(@"Hired!");
                          }];
}

#pragma mark -

- (void)startLongRunningTask
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.longRunningLabel.hidden = NO;
        [self.activity startAnimating];
    });
    
    //
    // Sleep the current thread to demo passing in NSOperationQueue to observer
    //
    sleep(3);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.longRunningLabel.hidden = YES;
        [self.activity stopAnimating];
    });
}

@end
