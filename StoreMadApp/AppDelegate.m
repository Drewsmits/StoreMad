//
//  AppDelegate.m
//  StoreMadApp
//
//  Created by Andrew Smith on 6/29/13.
//  Copyright (c) 2013 Burgess. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

+ (AppDelegate *)sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[UIApplication sharedApplication] delegate];
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

#pragma mark - StoreMad

- (SMStoreController *)storeController
{
    if (_storeController) return _storeController;

    // sqlite
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationDocDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [applicationDocDirectory URLByAppendingPathComponent:@"StoreMadApp.sqlite"];

    // momd
    NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"StoreMadApp" withExtension:@"momd"];
    
    // controller
    SMStoreController *newStoreController = [SMStoreController storeControllerWithStoreURL:storeURL
                                                                               andModelURL:modelURL];
    
    //
    // Context saves when app changes state
    //
    [newStoreController shouldSaveOnAppStateChanges:YES];
  
    _storeController = newStoreController;
  
    return _storeController;
}

@end
