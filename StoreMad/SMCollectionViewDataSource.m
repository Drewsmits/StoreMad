//
//  SMCollectionViewDataSource.m
//  StoreMad
//
//  Created by Andrew Smith on 2/23/13.
//  Copyright (c) 2013 eGraphs. All rights reserved.
//

#import "SMCollectionViewDataSource.h"

@interface SMCollectionViewDataSource ()

@property (nonatomic, strong) NSMutableArray *objectChanges;
@property (nonatomic, strong) NSMutableArray *sectionChanges;

@end

@implementation SMCollectionViewDataSource

- (void)setupWithCollectionView:(UICollectionView *)collectionView
                   fetchRequest:(NSFetchRequest *)fetchRequest
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
    
    // Hold onto this to work with when changes happen
    self.collectionView = collectionView;
    
    self.objectChanges  = [NSMutableArray array];
    self.sectionChanges = [NSMutableArray array];
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
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        [self.delegate dataSource:self isEmpty:YES];
    } else {
        [self.delegate dataSource:self isEmpty:NO];
    }
    
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

#pragma mark - Change

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    
    [self.sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    
    [self.objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{    
    if ([self.sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in self.sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([self.objectChanges count] > 0 && [self.sectionChanges count] == 0)
    {
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue]) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self.collectionView reloadData];
            
        } else {
            
            [self.collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in _objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
        
        [self.sectionChanges removeAllObjects];
        [self.objectChanges removeAllObjects];
    }
    
//    //
//    // Report empty
//    //
//    if (self.fetchedResultsController.fetchedObjects.count == 0) {
//        [self.delegate dataSourceIsEmpty:self];
//    }
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue
{
    return NO;
    
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in self.objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    
    return shouldReload;
}

@end
