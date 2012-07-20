//
//  NSManagedObject+StoreMad.h
//  StoreMad
//
//  Created by Andrew Smith on 7/20/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (StoreMad)

@property (nonatomic, readonly) NSURL *objectURI;
@property (nonatomic, readonly) BOOL hasBeenDeleted;

@end
