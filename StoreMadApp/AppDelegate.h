//
//  AppDelegate.h
//  StoreMadApp
//
//  Created by Andrew Smith on 6/29/13.
//  Copyright (c) 2013 Burgess. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonMacros.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) SMStoreController *storeController;

+ (AppDelegate *)sharedInstance;

@end
