//
//  MyViewController.m
//  StoreMadApp
//
//  Created by Andrew Smith on 3/14/14.
//  Copyright (c) 2014 Burgess. All rights reserved.
//

#import "MyViewController.h"

#import <StoreMad/StoreMad.h>

#import "Employee.h"

@interface MyViewController ()

@property (nonatomic, strong) id observer;

@property (nonatomic, weak) IBOutlet UILabel *employmentStatusLabel;

@end

@implementation MyViewController

- (void)dealloc
{
	[[SMContextObserverController defaultController] removeContextObserver:self.observer];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)configureWithEmployee:(Employee *)employee
{
    _employmentStatusLabel.text = employee.isFired ? @"Fired" : @"Hired";
}

@end
