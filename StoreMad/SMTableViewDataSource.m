//
//  SMTableViewDataSource.m
//  StoreMad
//
//  Created by Andrew Smith on 10/4/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import "SMTableViewDataSource.h"

@interface  SMTableViewDataSource ()

@property (nonatomic, weak) UIViewController *tableViewController;
@property (nonatomic, readonly) UITableView *tableView;

@end

@implementation SMTableViewDataSource

- (void)setupWithTableViewController:(UIViewController *)tableViewController
                        fetchRequest:(NSFetchRequest *)fetchRequest
                             context:(NSManagedObjectContext *)context
                  sectionNameKeyPath:(NSString *)sectionNameKeyPath
                           cacheName:(NSString *)cacheName
{
    BOOL tableViewConforms = [tableViewController conformsToProtocol:@protocol(SMDataSourceViewController)];
    NSAssert(tableViewConforms, @"TableViewController must conform to SMTableViewController protocol!");
    if (!tableViewConforms) return;
    
    BOOL hasTableView = [tableViewController respondsToSelector:@selector(tableView)];
    NSAssert(hasTableView, @"TableViewController must be a sublcass of UITableViewController!");
    if (!hasTableView) return;
    
    // Hold on to tableviewcontroller to respond to changes later
    self.tableViewController = tableViewController;
    
    // Normal setup
    [self setupWithFetchRequest:fetchRequest
                        context:context
             sectionNameKeyPath:sectionNameKeyPath
                      cacheName:cacheName];
}

- (UITableView *)tableView
{
    if (![self.tableViewController respondsToSelector:@selector(tableView)]) {
        return nil;
    } else {
        return (UITableView *)[self.tableViewController valueForKey:@"tableView"];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
    
    // Update sections
    for (int i = self.tableView.numberOfSections; i < controller.sections.count; i++) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:i]
                      withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [(id<SMDataSourceViewController>)self.tableViewController configureCell:[self.tableView cellForRowAtIndexPath:indexPath]
                                                                        atIndexPath:indexPath];
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
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    
    if ([self.tableViewController respondsToSelector:@selector(fetchResultsDidChange)]) {
        [self.tableViewController performSelector:@selector(fetchResultsDidChange)];
    }
}

@end
