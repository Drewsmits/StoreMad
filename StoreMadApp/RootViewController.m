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

@end
