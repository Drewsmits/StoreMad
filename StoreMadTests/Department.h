//
//  Department.h
//  StoreMad
//
//  Created by Andrew Smith on 6/29/13.
//  Copyright (c) 2013 eGraphs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Department : NSManagedObject

@property (nonatomic, retain) NSNumber * departmentId;
@property (nonatomic, retain) NSString * name;

@end
