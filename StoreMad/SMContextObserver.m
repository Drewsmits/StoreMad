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

@interface SMContextObserver ()

@property (nonatomic, strong, readwrite) NSManagedObjectContext *context;
@property (nonatomic, strong, readwrite) NSPredicate *predicate;
@property (nonatomic, copy, readwrite) NSString *notificationName;
@property (nonatomic, copy, readwrite) SMContextObserverBlock workBlock;

@end

@implementation SMContextObserver

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)observerInContext:(NSManagedObjectContext *)context
                        predicate:(NSPredicate *)predicate
              contextNotification:(NSString *)notificationName
                        workBlock:(void (^)(NSSet *updateObjects,
                                            NSSet *insertedOjects,
                                            NSSet *deletedObjects))workBlock
{
    BOOL valid = [self isNotificationValid:notificationName];
    NSAssert(valid, @"Notification name must be a valide NSManagedObjectContext notification type.");
    if (!valid) return nil;

    //
    // Dissallow observing nil context
    //
    NSAssert(context, @"SMContextObserver requires a non-nil context");
    if (!context) return nil;

    SMContextObserver *observer = [SMContextObserver new];
    observer.context            = context;
    observer.notificationName   = notificationName;
    observer.predicate          = predicate;
    observer.workBlock          = workBlock;
    
    return observer;
}

+ (instancetype)observerInContext:(NSManagedObjectContext *)context
                  forObjectWithId:(NSManagedObjectID *)objectId
              contextNotification:(NSString *)notificationName
                        workBlock:(void (^)(NSManagedObject *object))workBlock
{
    // Search for the object we pushed in
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"objectID == %@", objectId];;
    
    SMContextObserverBlock newWorkBlock = ^(NSSet *updateObjects,
                                            NSSet *insertedOjects,
                                            NSSet *deletedObjects) {
        NSManagedObject *object;
        
        if (updateObjects.count > 0) {
            object = [updateObjects anyObject];
        } else if (insertedOjects.count > 0) {
            object = [insertedOjects anyObject];
        } else if (deletedObjects.count > 0) {
            object = [deletedObjects anyObject];
        }
        
        if (workBlock) {
            workBlock(object);
        }
    };
    
    id observer = [self observerInContext:context
                                predicate:predicate
                      contextNotification:notificationName
                                workBlock:newWorkBlock];

    return observer;
}

+ (instancetype)observerForChangesToObject:(NSManagedObject *)object
                                 workBlock:(void (^)(NSManagedObject *object))workBlock
{
    return [self observerInContext:object.managedObjectContext
                   forObjectWithId:object.objectID
               contextNotification:NSManagedObjectContextObjectsDidChangeNotification
                         workBlock:workBlock];
}

+ (BOOL)isNotificationValid:(NSString *)notificationName
{
    // Only allow observation of standard context notifications
    NSArray *validNotifications = @[NSManagedObjectContextWillSaveNotification,
                                    NSManagedObjectContextDidSaveNotification,
                                    NSManagedObjectContextObjectsDidChangeNotification];
    
    return [validNotifications containsObject:notificationName];
}

#pragma mark - API

- (void)startObservingNotifications
{
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
    if (updatedObjectsFiltered.count == 0
        && insertedObjectsFiltered.count == 0
        && deletedObjectsFiltered.count == 0) return;
    
    // Perform work
    self.workBlock(updatedObjectsFiltered, insertedObjectsFiltered, deletedObjectsFiltered);
}

@end
