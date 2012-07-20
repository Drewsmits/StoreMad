//
//  NSManagedObjectContext+StoreMad.h
//  StoreMad
//
//  Created by Andrew Smith on 7/20/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (StoreMad)

- (NSManagedObject *)objectForURI:(NSURL *)objectURI;
- (void)deleteObjectAtURI:(NSURL *)objectURI;

- (NSArray *)executeFetchRequest:(NSFetchRequest *)request;
- (NSManagedObject *)executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request;
- (NSUInteger)countForFetchRequest:(NSFetchRequest *)request;

- (NSFetchRequest *)fetchRequestForObject:(NSManagedObject *)object;
- (NSFetchRequest *)findAllFetchRequestForOject:(NSManagedObject *)object;

@end
