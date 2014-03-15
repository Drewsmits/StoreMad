//
//  Employee.m
//  StoreMadApp
//
//  Created by Andrew Smith on 7/1/13.
//  Copyright (c) 2013 Burgess. All rights reserved.
//

#import "Employee.h"


@implementation Employee

@dynamic firstName;
@dynamic lastName;
@dynamic hireDate;
@dynamic fireDate;

- (BOOL)isFired
{
    return (self.fireDate != nil);
}

@end
