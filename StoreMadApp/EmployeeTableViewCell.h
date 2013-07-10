//
//  EmployeeTableViewCell.h
//  StoreMadApp
//
//  Created by Andrew Smith on 7/8/13.
//  Copyright (c) 2013 Burgess. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmployeeTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *firstNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *hireDateLabel;

@end
