//
//  SMContextObserverController.h
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

#import <Foundation/Foundation.h>

@interface SMContextObserverController : NSObject

+ (instancetype)defaultController;

/**
 Returns an opaque class of SMContextObserver. The workBlock will be executed
 every time the context fires a notification of the notificationType. For instance, 
 you could set a predicate to observe a specific object change in a given context
 every time the context saves, firing a NSManagedObjectContextDidSaveNotification.
 
 Optionally, you can pass in an NSOperationQueue to run the workBlock on. This is
 useful if you have a long running task. If nil, the workBlock will be executed on
 whatever thread the context fires the NSNotifiation. Most likely this is the main thread.
 
 @param context The context to observe
 @param predicate The predicate used to filter
 @param notificationName The NSManagedObjectContext notifications. Valid values
 include NSManagedObjectContextDidSaveNotification, NSManagedObjectContextWillSaveNotification,
 and NSManagedObjectContextObjectsDidChangeNotification.
 @param queue The NSOperationQueue to run the workBlock on. If nil, the workBlock will
 be run on the main thread.
 @param workBlock The work block to run on the updated, inserted, and deleted objects
 involved in the notification.
 */
- (id)addContextObserverForContext:(NSManagedObjectContext *)context
                         predicate:(NSPredicate *)predicate
           contextNotificationType:(NSString *)notificationType
                             queue:(NSOperationQueue *)queue
                         workBlock:(void (^)(NSSet *updateObjects,
                                             NSSet *insertedOjects,
                                             NSSet *deletedObjects))workBlock;

/**
 Returns an opaque class of SMContextObserver. The workBlock will be executed
 every time the context fires a notification of type NSManagedObjectContextObjectsDidChangeNotification.
 
 @param context The context to observe
 @param workBlock The work block to run on the updated, inserted, and deleted objects
 involved in the notification.
 */
- (id)addContextObserverForChangesToObject:(NSManagedObject *)object
                                 workBlock:(void (^)(NSManagedObject *object))workBlock;

/**
 Returns an opaque class of SMContextObserver. The workBlock will be executed
 every time the context fires a notification of type NSManagedObjectContextObjectsDidChangeNotification.
 
 Optionally, you can pass in an NSOperationQueue to run the workBlock on. This is
 useful if you have a long running task. If nil, the workBlock will be executed on
 whatever thread the context fires the NSNotifiation. Most likely this is the main thread.
 
 @param context The context to observe
 @param queue Optional. The NSOperationQueue to run the workBlock on.
 @param workBlock The work block to run on the updated, inserted, and deleted objects
 involved in the notification.
 */
- (id)addContextObserverForChangesToObject:(NSManagedObject *)object
                                     queue:(NSOperationQueue *)queue
                                 workBlock:(void (^)(NSManagedObject *object))workBlock;

/**
 Removes the observer from recieving any further notifications.
 */
- (void)removeContextObserver:(id)observer;

@end
