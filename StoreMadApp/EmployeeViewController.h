//
//  EmployeeViewController.h
//  StoreMadApp
//
//  Created by Andrew Smith on 7/8/13.
//  Copyright (c) 2013 Burgess. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Employee;

@interface EmployeeViewController : UIViewController

@property (nonatomic, strong) Employee *employee;

+ (EmployeeViewController *)newEmployeeViewControllerFromStorybaord;

- (void)configureWithEmployee:(Employee *)employee;

@end
