//
//  SMDataSource.h
//  StoreMad
//
//  Created by Andrew Smith on 7/1/13.
//  Copyright (c) 2012 Andrew B. Smith ( http://github.com/drewsmits ). All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol SMDataSourceDelegate;

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

- (void)configureCell:(id)cell
          atIndexPath:(NSIndexPath *)indexPath;

@optional

- (void)fetchResultsDidChange;

@end
