//
//  StoreMadBaseTest.m
//  StoreMad
//
//  Created by Andrew Smith on 8/15/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import "StoreMadBaseTest.h"

@implementation StoreMadBaseTest

- (void)setUp
{
    NSURL *storeURL = [[[NSBundle bundleForClass:[self class]] bundleURL] URLByAppendingPathComponent:@"StoreMadTests.sqlite"];
    NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"StoreMadTests" withExtension:@"momd"];

    storeController = [SMStoreController storeControllerWithStoreURL:storeURL
                                                         andModelURL:modelURL];
}

- (void)tearDown
{
    [storeController reset];
    storeController = nil;
}

@end
