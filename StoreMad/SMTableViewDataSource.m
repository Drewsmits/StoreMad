//
//  SMTableViewDataSource.m
//  StoreMad
//
//  Created by Andrew Smith on 10/4/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import "SMTableViewDataSource.h"

@implementation SMTableViewDataSource

- (void)setupWithTableView:(UITableView *)tableView
              fetchRequest:(NSFetchRequest *)fetchRequest
                   context:(NSManagedObjectContext *)context
        sectionNameKeyPath:(NSString *)sectionNameKeyPath
                 cacheName:(NSString *)cacheName
{
    BOOL tableViewConforms = [tableView conformsToProtocol:@protocol(SMTableView)];
    NSAssert(!tableViewConforms, @"Tableview must conform to SMTableView protocol!");
    if (!tableViewConforms) return;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:sectionNameKeyPath
                                                                                   cacheName:cacheName];
    self.fetchedResultsController.delegate = self;
}

- (void)performFetch
{
    [self.fetchedResultsController performFetch:nil];
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
    [self.tableView beginUpdates];
    
    // Update sections
    for (int i = self.tableView.numberOfSections; i < controller.sections.count; i++) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    //    NSLog(@"sections:%i", controller.sections.count);
    //    NSLog(@"section:%i row:%i", indexPath.section, indexPath.row);
    //    NSLog(@"new section:%i new row:%i", newIndexPath.section, newIndexPath.row);
    //    NSLog(@"table sections:%i", self.tableView.numberOfSections);
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [(id<SMTableView>)self.tableView configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
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
    [self.tableView endUpdates];
}


@end
