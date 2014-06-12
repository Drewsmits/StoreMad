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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SMStoreController : NSObject

/**
 The URL of the sqlite store, as set when initialized.
 */
@property (nonatomic, copy, readonly) NSURL *storeURL;

/**
 The URL of the model URL, as set when initialized.
 */
@property (nonatomic, copy, readonly) NSURL *modelURL;

/**
 Initialized with NSMainQueueConcurrencyType.  Meant as the main thread store.
 */
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 Set this to YES if you want the internal managedObjectContext to save when the
 app moves to the background. Set to NO, if otherwise.
 */
@property (nonatomic, assign) BOOL saveOnAppStateChange;

+ (SMStoreController *)storeControllerWithStoreURL:(NSURL *)storeURL 
                                       andModelURL:(NSURL *)modelURL;

/**
 Delete's the local store and rebuilds it. This will nuke any data you have and
 give you a fresh sqlite store. So yeah, be careful.
 */
- (void)reset;

/**
 This will delete the sqlite store on file. So yeah, be careful.
 */
- (void)deleteStore;

@end
