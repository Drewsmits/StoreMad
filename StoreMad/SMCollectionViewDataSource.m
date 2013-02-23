//
//  SMCollectionViewDataSource.m
//  StoreMad
//
//  Created by Andrew Smith on 2/23/13.
//  Copyright (c) 2013 eGraphs. All rights reserved.
//

#import "SMCollectionViewDataSource.h"

@implementation SMCollectionViewDataSource

- (void)setupWithCollectionViewController:(UIViewController *)collectionViewController
                             fetchRequest:(NSFetchRequest *)fetchRequest
                                  context:(NSManagedObjectContext *)context
                       sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                cacheName:(NSString *)cacheName
{
    BOOL conforms = [collectionViewController conformsToProtocol:@protocol(SMCollectionViewControllerProtocol)];
    NSAssert(conforms, @"CollectionViewController must conform to SMCollectionViewControllerProtocol!");
    if (!conforms) return;
    
    // Build controller
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:sectionNameKeyPath
                                                                                   cacheName:cacheName];
    
    // Respond to changes here
    self.fetchedResultsController.delegate = self;
    
    // Hold onto this to work with when changes happen
    self.collectionViewController = collectionViewController;
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
