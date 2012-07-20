//
//  NSManagedObject+StoreMad.m
//  StoreMad
//
//  Created by Andrew Smith on 7/20/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import "NSManagedObject+StoreMad.h"

@implementation NSManagedObject (StoreMad)

- (NSURL *)objectURI
{
    return self.objectID.URIRepresentation;
}

- (BOOL)hasBeenDeleted 
{    
    /**
     Sometimes CoreData will fault a particular instance, while there is still
     the same object in the store.  Check to see if there is a clone.
     */
    NSManagedObjectID   *objectID           = [self objectID];
    NSManagedObject     *managedObjectClone = [[self managedObjectContext] existingObjectWithID:objectID 
                                                                                          error:NULL];
    
    if (!managedObjectClone || [self isDeleted]) {
        return YES;
    } else {
        return NO;
    }
}

@end
