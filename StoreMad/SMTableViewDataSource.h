//
//  SMTableViewDataSource.h
//  StoreMad
//
//  Created by Andrew Smith on 10/4/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SMTableViewController <NSObject>
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@optional
- (void)showEmptyTableView;
@end

@interface SMTableViewDataSource : NSObject <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) UIViewController *tableViewController;

- (void)setupWithTableViewController:(UIViewController *)tableViewController
                        fetchRequest:(NSFetchRequest *)fetchRequest
                             context:(NSManagedObjectContext *)context
                  sectionNameKeyPath:(NSString *)sectionNameKeyPath
                           cacheName:(NSString *)cacheName;

- (void)performFetch;
- (void)performFetchWithNewFetchRequest:(NSFetchRequest *)fetchRequest;

- (id)objectAtIndexPath:(NSIndexPath *)index;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (NSArray *)sectionIndexTitles;
- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;

- (BOOL)isEmpty;

@end
