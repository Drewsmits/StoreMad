//
//  SMCollectionViewDataSource.h
//  StoreMad
//
//  Created by Andrew Smith on 2/23/13.
//  Copyright (c) 2013 eGraphs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMDataSource.h"

@protocol SMCollectionViewDataSourceDelegate;

@interface SMCollectionViewDataSource : SMDataSource

@property (nonatomic, weak) UICollectionView *collectionView;

- (void)setupWithCollectionView:(UICollectionView *)collectionView
                   fetchRequest:(NSFetchRequest *)fetchRequest
                        context:(NSManagedObjectContext *)context
             sectionNameKeyPath:(NSString *)sectionNameKeyPath
                      cacheName:(NSString *)cacheName;

@end
