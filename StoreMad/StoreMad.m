//
//  StoreMad.m
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

#import "StoreMad.h"

@implementation StoreMad

static NSMutableDictionary *storeControllers = nil;

+ (void) initialize
{
    if (!storeControllers) {
        storeControllers = [[NSMutableDictionary alloc] init];
    }
}

+ (SMStoreController *)newStoreControllerWithName:(NSString *)storeName
                                         storeURL:(NSURL *)storeURL
                                         modelURL:(NSURL *)modelURL
{
    SMStoreController *storeController = [SMStoreController storeControllerWithStoreURL:storeURL andModelURL:modelURL];
    [storeControllers setValue:storeController forKey:storeName];
    return storeController;
}

+ (SMStoreController *)storeControllerNamed:(NSString *)storeName
{
    return (SMStoreController *)[storeControllers valueForKey:storeName]  ;
}

+ (NSManagedObjectContext *)contextForStoreControllerNamed:(NSString *)storeName
{
    SMStoreController *controller = [self storeControllerNamed:storeName];
    return controller.managedObjectContext;
}

@end
