//
//  SMStoreController.m
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

#import "SMStoreController.h"

#import <UIKit/UIApplication.h>
#import "NSManagedObjectContext+StoreMad.h"
#import "SMContextObserver.h"

@interface SMStoreController ()

@property (nonatomic, copy) NSURL *storeURL;
@property (nonatomic, copy) NSURL *modelURL;

@property (nonatomic, strong, readwrite) NSMutableSet *contextObservers;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readwrite) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation SMStoreController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (SMStoreController *)storeControllerWithStoreURL:(NSURL *)storeURL 
                                       andModelURL:(NSURL *)modelURL
{
    SMStoreController *controller = [self new];
    controller.storeURL = storeURL;
    controller.modelURL = modelURL;
    return controller;
}

- (id)init
{
    self = [super init];
    if (self) {
        _contextObservers = [NSMutableSet new];
    }
    return self;
}

#pragma mark

- (void)reset
{
    @synchronized(self) {
        // Delete SQlite
        [self deleteStore];
        
        // Nil local variables
        _managedObjectContext = nil;
        _managedObjectModel = nil;
        _persistentStoreCoordinator = nil;
        
        // Rebuild
        [self managedObjectContext];
        
        // Observers
        _contextObservers = nil;
        _contextObservers = [NSMutableSet new];
    }
}

- (void)deleteStore 
{	
    @synchronized(self) {
        // Ensure we are on the main thread
        NSAssert([[NSThread currentThread] isEqual:[NSThread mainThread]], @"Delete operation must occur on the main thread");
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (self.storeURL) {
            [fileManager removeItemAtURL:self.storeURL error:NULL];
        }
    }
}

- (void)saveContext
{
    [self.managedObjectContext queueBlockSaveAndWait];
}

- (void)shouldSaveOnAppStateChanges:(BOOL)shouldSave
{
    if (!shouldSave) {
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:UIApplicationDidEnterBackgroundNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:UIApplicationWillTerminateNotification
                                                      object:nil];
        
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveContext)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(saveContext) 
                                                 name:UIApplicationWillTerminateNotification 
                                               object:nil];
}

#pragma mark - Observer

- (void)addContextObserver:(SMContextObserver *)contextObserver
{
    if (!contextObserver) return;
    contextObserver.context = self.managedObjectContext;
    [contextObserver startObservingNotifications];
    [self.contextObservers addObject:contextObserver];
}

- (void)removeContextObserver:(SMContextObserver *)contextObserver
{
    if (!contextObserver) return;
    [contextObserver stopObservingNotifications];
    [self.contextObservers removeObject:contextObserver];
}

- (SMContextObserver *)addContextDidSaveObserverWithWorkBlock:(SMContextObserverBlock)workBlock
{
    SMContextObserver *observer = [SMContextObserver new];
    observer.notificationName = NSManagedObjectContextDidSaveNotification;
    observer.predicate = [NSPredicate predicateWithFormat:@"1 == 1"];
    observer.workBlock = workBlock;
    [self addContextObserver:observer];
    return observer;
}

- (void)stopAllContextObservers
{
    [self.contextObservers enumerateObjectsUsingBlock:^(SMContextObserver *obj, BOOL *stop) {
        [obj stopObservingNotifications];
    }];
}

- (void)startAllContextObservers
{
    [self.contextObservers enumerateObjectsUsingBlock:^(SMContextObserver *obj, BOOL *stop) {
        [obj startObservingNotifications];
    }];
}

#pragma mark - CoreData Stack

- (NSManagedObjectContext *)threadSafeManagedObjectContext
{    
    // Create new context with default concurrency type
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [newContext setParentContext:self.managedObjectContext];
    
    // Optimization
    [newContext setUndoManager:nil];
    
    return newContext;
}

- (NSManagedObjectContext *)managedObjectContext 
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    NSAssert(_modelURL, @"ModelURL was nil!  Could not find resource");
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        
        NSLog(@"The model used to open the store is incompatable with the one used to create the store! Performing lightweight migration.");
        
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @(YES),
                                  NSInferMappingModelAutomaticallyOption       : @(YES)};
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:options error:&error]) {
            
            // probably shouldn't do this??!
            //[[NSFileManager defaultManager] removeItemAtURL:self.storeURL error:nil];

            if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:options error:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - File Directories

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
