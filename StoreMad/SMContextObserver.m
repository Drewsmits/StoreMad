//
//  SMStoreChangeController.m
//  StoreMad
//
//  Created by Andrew Smith on 10/3/12.
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

#import "SMContextObserver.h"

@implementation SMContextObserver

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)performObserverBlock:(SMContextObserverBlock)block
             forNotification:(NSNotification *)notification
{
    NSSet *updatedObjects  = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
    NSSet *deletedObjects  = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    
    NSSet *updatedObjectsFiltered  = [updatedObjects filteredSetUsingPredicate:self.predicate];
    NSSet *insertedObjectsFiltered = [insertedObjects filteredSetUsingPredicate:self.predicate];
    NSSet *deletedObjectsFiltered  = [deletedObjects filteredSetUsingPredicate:self.predicate];

    if (updatedObjects.count == 0 && insertedObjects.count == 0 && deletedObjects.count == 0) return;
    
    block(updatedObjectsFiltered, insertedObjectsFiltered, deletedObjectsFiltered);
}

#pragma mark - Save

- (void)startObservingSaveNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.context];
}

- (void)contextDidSave:(NSNotification *)notification
{
    [self performObserverBlock:self.didSaveBlock forNotification:notification];
}

#pragma mark - Change

- (void)startObservingChangeNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidChange:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:self.context];
}


- (void)contextDidChange:(NSNotification *)notification
{
    [self performObserverBlock:self.didChangeBlock forNotification:notification];
}

@end
