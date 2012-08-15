//
//  StoreMadBaseTest.h
//  StoreMad
//
//  Created by Andrew Smith on 8/15/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "SMStoreController.h"
#import "NSManagedObject+StoreMad.h"
#import "NSManagedObjectContext+StoreMad.h"

@interface StoreMadBaseTest : SenTestCase
{
    SMStoreController *storeController;
}

@end
