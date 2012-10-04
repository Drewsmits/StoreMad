//
//  Employee.h
//  StoreMad
//
//  Created by Andrew Smith on 9/28/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Employee : NSManagedObject

@property (nonatomic, retain) NSNumber * employeeId;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;

@end
