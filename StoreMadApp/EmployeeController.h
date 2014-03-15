//
//  EmployeeController.h
//  StoreMadApp
//
//  Created by Andrew Smith on 7/1/13.
//  Copyright (c) 2013 Burgess. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Employee;

@interface EmployeeController : NSObject

+ (NSFetchRequest *)allEmployeesSortedFetchRequestInContext:(NSManagedObjectContext *)context;

+ (void)fireEmployee:(Employee *)employee
          completion:(void (^)(void))completion;

+ (void)hireEmployee:(Employee *)employee
          completion:(void (^)(void))completion;
@end
