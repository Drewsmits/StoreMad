//
//  StoreMadBaseTest.h
//  StoreMad
//
//  Created by Andrew Smith on 8/15/12.
//  Copyright (c) 2012 Andrew B. Smith. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SMStoreController.h"
#import "NSManagedObject+StoreMad.h"
#import "NSManagedObjectContext+StoreMad.h"

@interface StoreMadBaseTest : XCTestCase

@property (nonatomic, strong) SMStoreController *storeController;
@property (nonatomic, readonly) NSManagedObjectContext *testContext;

@end
