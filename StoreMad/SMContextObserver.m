//
//  SMStoreChangeController.m
//  StoreMad
//
//  Created by Andrew Smith on 10/3/12.
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

#import "SMContextObserver.h"

@implementation SMContextObserver

@synthesize notificationName = _notificationName;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startObservingNotifications
{
    // Bail if no notifaction name
    NSAssert(self.notificationName, @"SMContextObserver requires a non-nil notification name");
    if (!self.notificationName) return;
    
    // Bail if no context
    NSAssert(self.context, @"SMContextObserver requires a non-nil context");
    if (!self.context) return;
    
    // Standard notification center
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processContextNotification:)
                                                 name:self.notificationName
                                               object:self.context];
}

- (void)stopObservingNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)processContextNotification:(NSNotification *)notification
{
    // Bail if no work block
    if (!self.workBlock) return;
    
    // Grab objects from notification.  These are standard keys, as defined by docs
    NSSet *updatedObjects  = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
    NSSet *deletedObjects  = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    
    // Filter sets using predicate
    if (!self.predicate) self.predicate = [NSPredicate predicateWithFormat:@"1 = 1"];
    
    NSSet *updatedObjectsFiltered  = [updatedObjects filteredSetUsingPredicate:self.predicate];
    NSSet *insertedObjectsFiltered = [insertedObjects filteredSetUsingPredicate:self.predicate];
    NSSet *deletedObjectsFiltered  = [deletedObjects filteredSetUsingPredicate:self.predicate];
    
    // If there is nothing, bail.  Might want to pull this out.  Might be a situation where we want
    // to know if there are no objects.
    if (updatedObjectsFiltered.count == 0 && insertedObjectsFiltered.count == 0 && deletedObjectsFiltered.count == 0) return;
    
    // Perform work
    self.workBlock(updatedObjectsFiltered, insertedObjectsFiltered, deletedObjectsFiltered);
}

- (void)setNotificationName:(NSString *)notificationName
{
    // Only allow observation of standard context notifications
    NSArray *validNotifications = @[NSManagedObjectContextWillSaveNotification,
                                    NSManagedObjectContextDidSaveNotification,
                                    NSManagedObjectContextObjectsDidChangeNotification];
    
    BOOL valid = [validNotifications containsObject:notificationName];
    NSAssert(valid, @"Notification name must be a valide NSManagedObjectContext notification type.");
    if (!valid) return;
    _notificationName = [notificationName copy];
}

- (NSString *)notificationName
{
    return _notificationName;
}

@end
