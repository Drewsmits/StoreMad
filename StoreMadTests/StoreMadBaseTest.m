//
//  StoreMadBaseTest.m
//  StoreMad
//
//  Created by Andrew Smith on 8/15/12.
//  Copyright (c) 2012 Andrew B. Smith. All rights reserved.
//

#import "StoreMadBaseTest.h"

//extern void __gcov_flush(void);

@implementation StoreMadBaseTest

- (void)setUp
{
    NSURL *storeURL = [[[NSBundle bundleForClass:[self class]] bundleURL] URLByAppendingPathComponent:@"StoreMadTests.sqlite"];
    NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"StoreMadTests" withExtension:@"momd"];

    self.storeController = [SMStoreController storeControllerWithStoreURL:storeURL
                                                              andModelURL:modelURL];
}

- (void)tearDown
{
    [self.storeController reset];
    _storeController = nil;
//    __gcov_flush();
}

- (NSManagedObjectContext *)testContext
{
    return self.storeController.managedObjectContext;
}

@end
