//
//  NSManagedObject+StoreMad.m
//  StoreMad
//
//  Created by Andrew Smith on 7/20/12.
//  Copyright (c) 2012 Andrew B. Smith ( http://github.com/drewsmits ). All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
// of the Software, and to permit persons to whom the Software is furnished to do so, 
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "NSManagedObject+StoreMad.h"
#import "NSManagedObjectContext+StoreMad.h"

@implementation NSManagedObject (StoreMad)

- (NSURL *)objectURI
{
    return self.objectID.URIRepresentation;
}

- (BOOL)hasBeenDeleted 
{
    NSManagedObjectID *objectID           = [self objectID];
    NSManagedObject   *managedObjectClone = [[self managedObjectContext] existingObjectWithID:objectID
                                                                                        error:NULL];
    
    if (!managedObjectClone || [self isDeleted]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasBeenSaved
{
    return !self.objectID.isTemporaryID;
}

+ (id)createInContext:(NSManagedObjectContext *)context
{
    return [context insertNewObjectForEntityNamed:[self description]];
}

@end
