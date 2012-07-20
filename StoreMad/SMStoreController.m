//
//  SMStoreController.m
//  StoreMad
//
//  Created by Andrew Smith on 7/20/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import "SMStoreController.h"

@interface SMStoreController ()

@end

@implementation SMStoreController

@synthesize storeURL,
            momdName,
            managedObjectContext,
            managedObjectModel,
            persistentStoreCoordinator;

+ (SMStoreController *)storeControllerWithStoreURL:(NSURL *)storeURL 
                                      andModelName:(NSString *)modelName
{
    SMStoreController *controller = [[self alloc] init];
    controller.storeURL = storeURL;
    controller.momdName = modelName;
    return controller;
}

#pragma mark

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

#pragma mark - CoreData Stack

- (NSManagedObjectContext *)threadSafeManagedObjectContext
{
    // Grab the main coordinator
    NSPersistentStoreCoordinator *coord = [self.managedObjectContext persistentStoreCoordinator];
    
    // Create new context with default concurrency type
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [newContext setPersistentStoreCoordinator:coord];
    
    // Optimization
    [newContext setUndoManager:nil];
    
    // Observer saves from this context
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(contextDidSave:) 
                                                 name:NSManagedObjectContextDidSaveNotification 
                                               object:newContext];
    
    return newContext;
}

- (NSManagedObjectContext *)managedObjectContext 
{
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.momdName withExtension:@"momd"];
    
    NSAssert(modelURL, @"ModelURL was nil!  Could not find resource named %@.momd", self.momdName);
    
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:nil error:&error])
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
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:options error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();  
        }
        
    }    
    
    return persistentStoreCoordinator;
}

- (void)contextDidSave:(NSNotification *)notification {
    SEL selector = @selector(mergeChangesFromContextDidSaveNotification:);
    
    NSManagedObjectContext *threadContext = (NSManagedObjectContext *)notification.object;
    
    [self.managedObjectContext performSelectorOnMainThread:selector 
                                                withObject:notification 
                                             waitUntilDone:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:NSManagedObjectContextDidSaveNotification 
                                                  object:threadContext];
}

#pragma mark - File Directories

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
