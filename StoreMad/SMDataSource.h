//
//  SMDataSource.h
//  StoreMad
//
//  Created by Andrew Smith on 7/1/13.
//  Copyright (c) 2013 eGraphs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SMDataSourceDelegate;

@protocol SMDataSourceViewController <NSObject>
- (void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath;
@optional
- (void)fetchResultsDidChange;
@end

@interface SMDataSource : NSObject <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) id <SMDataSourceDelegate> dataSourceDelegate;

- (void)setupWithFetchRequest:(NSFetchRequest *)fetchRequest
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

@protocol SMDataSourceDelegate <NSObject>
- (void)dataSource:(SMDataSource *)dataSource
           isEmpty:(BOOL)empty;
@end
