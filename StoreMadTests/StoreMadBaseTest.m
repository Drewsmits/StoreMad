//
//  StoreMadBaseTest.m
//  StoreMad
//
//  Created by Andrew Smith on 8/15/12.
//  Copyright (c) 2012 Andrew B. Smith. All rights reserved.
//

#import "StoreMadBaseTest.h"

@interface StoreMadBaseTest ()

@property (nonatomic, strong) SMStoreController *storeController;

@end

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
}

- (NSManagedObjectContext *)testContext
{
    return self.storeController.managedObjectContext;
}

@end
