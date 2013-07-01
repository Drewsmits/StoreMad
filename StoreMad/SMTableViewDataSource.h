//
//  SMTableViewDataSource.h
//  StoreMad
//
//  Created by Andrew Smith on 10/4/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMDataSource.h"

@protocol SMTableViewController <NSObject>
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@optional
- (void)fetchResultsDidChange;
@end

@interface SMTableViewDataSource : SMDataSource

- (void)setupWithTableViewController:(UIViewController *)tableViewController
                        fetchRequest:(NSFetchRequest *)fetchRequest
                             context:(NSManagedObjectContext *)context
                  sectionNameKeyPath:(NSString *)sectionNameKeyPath
                           cacheName:(NSString *)cacheName;

@end
