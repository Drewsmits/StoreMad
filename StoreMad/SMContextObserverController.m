//
//  SMContextObserverController.m
//  StoreMad
//
//  Created by Andrew Smith on 3/13/14.
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

#import "SMContextObserverController.h"

#import "NSManagedObject+StoreMad.h"

#pragma mark - SMContextObserver

typedef void (^SMContextObserverBlock)(NSSet *updateObjects, NSSet *insertedOjects, NSSet *deletedObjects);

@interface SMContextObserver : NSObject

@property (nonatomic, strong) NSManagedObjectContext *context;

@property (nonatomic, strong) NSPredicate *predicate;

@property (nonatomic, strong) NSString *notificationType;

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, copy) SMContextObserverBlock workBlock;

@end

@implementation SMContextObserver

- (void)dealloc
{
    [self stopObservingNotifications];
}

#pragma mark - Notifications

- (void)startObservingNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationDidFire:)
                                                 name:self.notificationType
                                               object:self.context];
}

- (void)stopObservingNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:self.notificationType
                                                  object:self.context];
}

- (void)notificationDidFire:(NSNotification *)notification
{
    if (_queue) {
        __weak SMContextObserver *weakSelf = self;
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            __strong SMContextObserver *strongSelf = weakSelf;
            [strongSelf processContextNotification:notification];
        }];
        [_queue addOperation:op];
    } else {
        [self processContextNotification:notification];
    }
}

- (void)processContextNotification:(NSNotification *)notification
{
    // Bail if no work block
    if (!self.workBlock) return;

    //
    // Grab objects from notification.  These are standard keys, as defined by docs
    //
    NSSet *updatedObjects  = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
    NSSet *deletedObjects  = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    
    //
    // Filter sets using predicate
    //
    if (!self.predicate) self.predicate = [NSPredicate predicateWithFormat:@"1 = 1"];
    NSSet *updatedObjectsFiltered  = [updatedObjects filteredSetUsingPredicate:self.predicate];
    NSSet *insertedObjectsFiltered = [insertedObjects filteredSetUsingPredicate:self.predicate];
    NSSet *deletedObjectsFiltered  = [deletedObjects filteredSetUsingPredicate:self.predicate];
    
    //
    // Bail if no changes
    //
    if (updatedObjectsFiltered.count == 0
        && insertedObjectsFiltered.count == 0
        && deletedObjectsFiltered.count == 0) return;
    
    //
    // Perform work
    //
    self.workBlock(updatedObjectsFiltered, insertedObjectsFiltered, deletedObjectsFiltered);
}

@end

#pragma mark - SMContextObserverController

@interface SMContextObserverController ()

@property (nonatomic, strong) NSMutableArray *observers;

@end

@implementation SMContextObserverController

- (id)init
{
    self = [super init];
    if (self) {
        _observers = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Singleton

+ (instancetype)defaultController
{
    static SMContextObserverController *_defaultController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultController = [[self alloc] init];
    });
    return _defaultController;
}

#pragma mark - API

- (id)addContextObserverForContext:(NSManagedObjectContext *)context
                         predicate:(NSPredicate *)predicate
           contextNotificationType:(NSString *)notificationType
                             queue:(NSOperationQueue *)queue
                         workBlock:(void (^)(NSSet *updateObjects,
                                             NSSet *insertedOjects,
                                             NSSet *deletedObjects))workBlock
{
    //
    // Validate context
    //
    NSAssert(context, @"Tried to add an observer to a nil NSManagedObjectContext!");
    if (!context) return nil;
    
    //
    // Validate notification type
    //
    NSArray *validNotifications = @[NSManagedObjectContextDidSaveNotification,
                                    NSManagedObjectContextWillSaveNotification,
                                    NSManagedObjectContextObjectsDidChangeNotification];
    BOOL valid = [validNotifications containsObject:notificationType];
    NSAssert(valid, @"Notification type must be one of the following: NSManagedObjectContextDidSaveNotification, NSManagedObjectContextWillSaveNotification, NSManagedObjectContextObjectsDidChangeNotification");
    if (!valid) return nil;
    
    //
    // Build observer
    //
    SMContextObserver *observer = [SMContextObserver new];
    observer.context = context;
    observer.predicate = predicate;
    observer.notificationType = notificationType;
    observer.queue = queue;
    observer.workBlock = workBlock;
    
    //
    // Turn on the observer
    //
    [observer startObservingNotifications];
    
    //
    // Keep track of observer
    //
    @synchronized (_observers) {
        [_observers addObject:observer];
    }
    
    return observer;
}

- (id)addContextObserverForChangesToObject:(NSManagedObject *)object
                                 workBlock:(void (^)(NSManagedObject *object))workBlock
{
    return [self addContextObserverForChangesToObject:object
                                                queue:nil
                                            workBlock:workBlock];
}

- (id)addContextObserverForChangesToObject:(NSManagedObject *)object
                                     queue:(NSOperationQueue *)queue
                                 workBlock:(void (^)(NSManagedObject *object))workBlock
{
    NSAssert(object.stm_hasBeenSaved, @"Object must be saved first to observe. Right now it only has a temporary objectID");
    
    //
    // Search for the object we pushed in
    //
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"objectID == %@", object.objectID];;
    
    //
    // Wrap the work block.
    //
    SMContextObserverBlock newWorkBlock = ^(NSSet *updateObjects,
                                            NSSet *insertedOjects,
                                            NSSet *deletedObjects) {
        NSManagedObject *fetchedObject;
        
        if (updateObjects.count > 0) {
            fetchedObject = [updateObjects anyObject];
        } else if (insertedOjects.count > 0) {
            fetchedObject = [insertedOjects anyObject];
        } else if (deletedObjects.count > 0) {
            fetchedObject = [deletedObjects anyObject];
        }
        
        if (workBlock) {
            workBlock(fetchedObject);
        }
    };
    
    //
    // Build the observer
    //
    id observer = [self addContextObserverForContext:object.managedObjectContext
                                           predicate:predicate
                             contextNotificationType:NSManagedObjectContextObjectsDidChangeNotification
                                               queue:queue
                                           workBlock:newWorkBlock];
    
    return observer;
}

- (void)removeContextObserver:(SMContextObserver *)observer
{
    [observer stopObservingNotifications];
    @synchronized (_observers) {
        [_observers removeObject:observer];
    }
}

@end
