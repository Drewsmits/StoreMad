//
//  SMCollectionViewDataSource.h
//  StoreMad
//
//  Created by Andrew Smith on 2/23/13.
//  Copyright (c) 2013 eGraphs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMCollectionViewControllerProtocol <NSObject>
- (void)configureCollectionCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@optional
- (void)fetchResultsDidChange;
- (void)showEmptyTableView;
@end

@interface SMCollectionViewDataSource : NSObject <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) UIViewController *collectionViewController;

- (void)setupWithCollectionViewController:(UIViewController *)collectionViewController
                             fetchRequest:(NSFetchRequest *)fetchRequest
                                  context:(NSManagedObjectContext *)context
                       sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                cacheName:(NSString *)cacheName;

- (void)performFetch;
- (void)performFetchWithNewFetchRequest:(NSFetchRequest *)fetchRequest;

- (id)objectAtIndexPath:(NSIndexPath *)index;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (NSArray *)sectionIndexTitles;
- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;

- (BOOL)isEmpty;

@end
