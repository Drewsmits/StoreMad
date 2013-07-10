//
//  EmployeeFireOperation.h
//  StoreMadApp
//
//  Created by Andrew Smith on 7/8/13.
//  Copyright (c) 2013 Burgess. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmployeeFireOperation : NSOperation

+ (EmployeeFireOperation *)fireOperationForEmplyeeWithID:(NSManagedObjectID *)employeeObjectId
                                               inContext:(NSManagedObjectContext *)context;

@end
