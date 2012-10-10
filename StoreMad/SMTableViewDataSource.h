//
//  SMTableViewDataSource.h
//  StoreMad
//
//  Created by Andrew Smith on 10/4/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SMTableView <NSObject>
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@interface SMTableViewDataSource : NSObject <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UITableView *tableView;

- (void)setupWithTableView:(UITableView *)tableView
              fetchRequest:(NSFetchRequest *)fetchRequest
                   context:(NSManagedObjectContext *)context
        sectionNameKeyPath:(NSString *)sectionNameKeyPath
                 cacheName:(NSString *)cacheName;

- (void)performFetch;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (NSArray *)sectionIndexTitles;
- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;

@end
