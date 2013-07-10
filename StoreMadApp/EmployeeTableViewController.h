//
//  EmployeeTableViewController.h
//  StoreMadApp
//
//  Created by Andrew Smith on 7/1/13.
//  Copyright (c) 2013 Burgess. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmployeeTableViewController : UITableViewController <SMTableViewController>

@property (nonatomic, strong) SMStoreController *storeController;
@property (nonatomic, strong) SMTableViewDataSource *storeMadDataSource;

@end
