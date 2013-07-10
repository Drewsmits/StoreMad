//
//  Employee.h
//  StoreMadApp
//
//  Created by Andrew Smith on 7/1/13.
//  Copyright (c) 2013 Burgess. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Employee : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSDate * hireDate;
@property (nonatomic, retain) NSDate * fireDate;

@property (nonatomic, readonly) BOOL isFired;

@end
