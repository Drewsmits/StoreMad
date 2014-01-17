//
//  SMDataSource.m
//  StoreMad
//
//  Created by Andrew Smith on 7/1/13.
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

#import "SMDataSource.h"

@implementation SMDataSource

- (void)setupWithFetchRequest:(NSFetchRequest *)fetchRequest
                      context:(NSManagedObjectContext *)context
           sectionNameKeyPath:(NSString *)sectionNameKeyPath
                    cacheName:(NSString *)cacheName
{
    // Build controller
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:sectionNameKeyPath
                                                                                   cacheName:cacheName];
    
    // Respond to changes here
    self.fetchedResultsController.delegate = self;
}

#pragma mark - Fetching

- (void)performFetch
{
    [self.fetchedResultsController performFetch:nil];
}

- (void)performFetchWithNewFetchRequest:(NSFetchRequest *)fetchRequest
{
    [NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.fetchedResultsController.managedObjectContext
                                                                          sectionNameKeyPath:self.fetchedResultsController.sectionNameKeyPath
                                                                                   cacheName:self.fetchedResultsController.cacheName];
    [self performFetch];
}

#pragma mark - Helper

- (id)objectAtIndexPath:(NSIndexPath *)index
{
    return [self.fetchedResultsController objectAtIndexPath:index];
}

#pragma mark - UICollectionView data source helpers

- (NSInteger)numberOfSections
{
    //
    // Report if empty
    //
    BOOL empty = (self.fetchedResultsController.fetchedObjects.count == 0);
    [self.dataSourceDelegate dataSource:self isEmpty:empty];
    
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitles
{
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (BOOL)isEmpty
{
    return (self.fetchedResultsController.fetchedObjects.count < 1);
}

@end
