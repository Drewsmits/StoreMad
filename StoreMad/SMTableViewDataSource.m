//
//  SMTableViewDataSource.m
//  StoreMad
//
//  Created by Andrew Smith on 10/4/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import "SMTableViewDataSource.h"

@implementation SMTableViewDataSource

- (void)setupWithTableViewController:(UIViewController *)tableViewController
                        fetchRequest:(NSFetchRequest *)fetchRequest
                             context:(NSManagedObjectContext *)context
                  sectionNameKeyPath:(NSString *)sectionNameKeyPath
                           cacheName:(NSString *)cacheName
{
    BOOL tableViewConforms = [tableViewController conformsToProtocol:@protocol(SMTableViewController)];
    NSAssert(tableViewConforms, @"TableViewController must conform to SMTableViewController protocol!");
    if (!tableViewConforms) return;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:sectionNameKeyPath
                                                                                   cacheName:cacheName];
    self.fetchedResultsController.delegate = self;
    
    self.tableViewController = tableViewController;
}

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

- (id)objectAtIndexPath:(NSIndexPath *)index
{
    return [self.fetchedResultsController objectAtIndexPath:index];
}

#pragma mark - Table view data source helpers

- (NSInteger)numberOfSections
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
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

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (![self.tableViewController respondsToSelector:@selector(tableView)]) return;
    UITableView *tableView = (UITableView *)[self.tableViewController valueForKey:@"tableView"];

    [tableView beginUpdates];
    
    // Update sections
    for (int i = tableView.numberOfSections; i < controller.sections.count; i++) {
        [tableView insertSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (![self.tableViewController respondsToSelector:@selector(tableView)]) return;
    UITableView *tableView = (UITableView *)[self.tableViewController valueForKey:@"tableView"];
    
    //    NSLog(@"sections:%i", controller.sections.count);
    //    NSLog(@"section:%i row:%i", indexPath.section, indexPath.row);
    //    NSLog(@"new section:%i new row:%i", newIndexPath.section, newIndexPath.row);
    //    NSLog(@"table sections:%i", self.tableView.numberOfSections);
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [(id<SMTableViewController>)self.tableViewController configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![self.tableViewController respondsToSelector:@selector(tableView)]) return;
    UITableView *tableView = (UITableView *)[self.tableViewController valueForKey:@"tableView"];

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![self.tableViewController respondsToSelector:@selector(tableView)]) return;
    UITableView *tableView = (UITableView *)[self.tableViewController valueForKey:@"tableView"];
    [tableView endUpdates];
    if ([self isEmpty]) {
        if ([self.tableViewController respondsToSelector:@selector(showEmptyTableView)]) {
            [self.tableViewController performSelector:@selector(showEmptyTableView)];
        }
    }
}

- (BOOL)isEmpty
{
    return (self.fetchedResultsController.fetchedObjects.count < 1);
}
        
@end
