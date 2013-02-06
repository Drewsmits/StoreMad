//
//  SMStoreController.h
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

#import "SMContextObserver.h"

@interface SMStoreController : NSObject

@property (copy) NSURL *storeURL;
@property (copy) NSURL *modelURL;
@property (nonatomic, readonly) NSMutableSet *contextObservers;

/**
 Initialized with NSMainQueueConcurrencyType.  Meant as the main thread store.
 */
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (SMStoreController *)storeControllerWithStoreURL:(NSURL *)storeURL 
                                       andModelURL:(NSURL *)modelURL;

- (void)reset;
- (void)deleteStore;
- (void)saveContext;
- (void)shouldSaveOnAppStateChanges:(BOOL)shouldSave;

- (void)addContextObserver:(SMContextObserver *)contextObserver;
- (void)removeContextObserver:(SMContextObserver *)contextObserver;
- (SMContextObserver *)addContextDidSaveObserverWithWorkBlock:(SMContextObserverBlock)workBlock;

- (void)stopAllContextObservers;
- (void)startAllContextObservers;

/**
 Returns a new NSManagedObjectContext with a concurrency type of NSPrivateQueueConcurrencyType
 and the parent context set as the main managedObjectContext.
 */
- (NSManagedObjectContext *)threadSafeManagedObjectContext;

- (NSURL *)applicationDocumentsDirectory;

@end
