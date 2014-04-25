//
//  SMContextObserverController.m
//  StoreMad
//
//  Created by Andrew Smith on 3/13/14.
//  Copyright (c) 2014 eGraphs. All rights reserved.
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
    NSAssert(object.hasBeenSaved, @"Object must be saved first to observe. Right now it only has a temporary objectID");
    
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
        NSManagedObject *updatedObject;
        
        if (updateObjects.count > 0) {
            updatedObject = [updateObjects anyObject];
        } else if (insertedOjects.count > 0) {
            updatedObject = [insertedOjects anyObject];
        } else if (deletedObjects.count > 0) {
            updatedObject = [deletedObjects anyObject];
        }
        
        if (workBlock) {
            workBlock(updatedObject);
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
