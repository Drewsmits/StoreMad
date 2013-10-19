//
//  SMStoreChangeController.h
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

typedef void (^SMContextObserverBlock)(NSSet *updateObjects, NSSet *insertedOjects, NSSet *deletedObjects);

@interface SMContextObserver : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *context;
@property (nonatomic, strong, readonly) NSPredicate *predicate;
@property (nonatomic, copy, readonly) NSString *notificationName;
@property (nonatomic, copy, readonly) SMContextObserverBlock workBlock;

/**
 Creates a SMContextObserver. This observer will execute the workBlock every time
 the contextNotification is fired by the given context. For instance, you could 
 set a predicate to observe a specific object change in a given context every time
 the context saves, firing a NSManagedObjectContextDidSaveNotification.
 
 @param context The context to observe
 @param predicate The predicate used to filter
 @param notificationName The NSManagedObjectContext notifications. Valid values
 include NSManagedObjectContextDidSaveNotification, NSManagedObjectContextDidSaveNotification,
 and NSManagedObjectContextObjectsDidChangeNotification.
 @param workBlock The work block to run on the updated, inserted, and deleted objects
 involved in the notification.
 */
+ (instancetype)observerInContext:(NSManagedObjectContext *)context
                        predicate:(NSPredicate *)predicate
              contextNotification:(NSString *)notificationName
                        workBlock:(void (^)(NSSet *updateObjects,
                                            NSSet *insertedOjects,
                                            NSSet *deletedObjects))workBlock;

+ (instancetype)observerForChangesToObject:(NSManagedObject *)object
                                 workBlock:(void (^)(NSManagedObject *object))workBlock;

- (void)startObservingNotifications;

- (void)stopObservingNotifications;

@end
