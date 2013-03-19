//
//  SMCollectionViewDataSource.h
//  StoreMad
//
//  Created by Andrew Smith on 2/23/13.
//  Copyright (c) 2013 eGraphs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMCollectionViewControllerProtocol <NSObject>
- (void)configureCollectionCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@optional
- (void)fetchResultsDidChange;
@end

@protocol SMCollectionViewDataSourceDelegate;

@interface SMCollectionViewDataSource : NSObject <NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) id <SMCollectionViewDataSourceDelegate> delegate;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) UICollectionView *collectionView;

- (void)setupWithCollectionView:(UICollectionView *)collectionView
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

@protocol SMCollectionViewDataSourceDelegate <NSObject>
- (void)dataSource:(SMCollectionViewDataSource *)dataSource isEmpty:(BOOL)empty;
@end
