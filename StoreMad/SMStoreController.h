//
//  SMStoreController.h
//  StoreMad
//
//  Created by Andrew Smith on 7/20/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMStoreController : NSObject

@property (nonatomic, copy) NSURL *storeURL;
@property (nonatomic, copy) NSString *momdName;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (SMStoreController *)storeControllerWithStoreURL:(NSURL *)storeURL 
                                      andModelName:(NSString *)modelName;

- (NSManagedObjectContext *)threadSafeManagedObjectContext;
- (NSURL *)applicationDocumentsDirectory;

@end
