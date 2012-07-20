//
//  NSManagedObjectContext+StoreMad.m
//  StoreMad
//
//  Created by Andrew Smith on 7/20/12.
//  Copyright (c) 2012 eGraphs. All rights reserved.
//

#import "NSManagedObjectContext+StoreMad.h"
#import "StoreMad.h"

@implementation NSManagedObjectContext (StoreMad)

- (void)handleErrors:(NSError *)error
{
    // Forget where I snagged this from
    if (error) {
        NSDictionary *userInfo = [error userInfo];
        for (NSArray *detailedError in [userInfo allValues]) {
            if ([detailedError isKindOfClass:[NSArray class]]) {
                for (NSError *e in detailedError) {
                    if ([e respondsToSelector:@selector(userInfo)]) {
                        NSLog(@"Error Details: %@", [e userInfo]);
                    }
                    else {
                        NSLog(@"Error Details: %@", e);
                    }
                }
            }
            else {
                NSLog(@"Error: %@", detailedError);
            }
        }
        NSLog(@"Error Domain: %@", [error domain]);
        NSLog(@"Recovery Suggestion: %@", [error localizedRecoverySuggestion]);
    }
}

#pragma mark - URI Helpers

- (NSManagedObject *)objectForURI:(NSURL *)objectURI
{
    NSManagedObjectID *objectID = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:objectURI];
    if (!objectID) return nil;
    
    NSManagedObject *objectForID = [self objectWithID:objectID];
    if (![objectForID isFault]) return objectForID;
    
    NSFetchRequest *request = [self fetchRequestForObject:objectForID];
    
    // Predicate for fetching self.  Code is faster than string predicate equivalent of 
    // [NSPredicate predicateWithFormat:@"SELF = %@", objectForID];
    NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForEvaluatedObject] 
                                                                rightExpression:[NSExpression expressionForConstantValue:objectForID]
                                                                       modifier:NSDirectPredicateModifier
                                                                           type:NSEqualToPredicateOperatorType
                                                                        options:0];
    [request setPredicate:predicate];
    return [self executeFetchRequestAndReturnFirstObject:request];
}

- (void)deleteObjectAtURI:(NSURL *)objectURI 
{
    NSManagedObject *object = [self objectForURI:objectURI];
    [self deleteObject:object];
}

#pragma mark - Fetching
     
- (NSArray *)executeFetchRequest:(NSFetchRequest *)request
{
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:request error:&error];
    [self handleErrors:error];
    return results;
}

- (NSManagedObject *)executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request
{
    [request setFetchLimit:1];
    NSArray *results = [self executeFetchRequest:request];
    if (results.count < 1) return nil;
    return [results objectAtIndex:0];
}

- (NSUInteger)countForFetchRequest:(NSFetchRequest *)request
{
    NSError *error = nil;
    NSUInteger count = [self countForFetchRequest:request error:&error];
    [self handleErrors:error];
    return count;
}

#pragma mark - Fetch Requests

- (NSFetchRequest *)fetchRequestForObject:(NSManagedObject *)object
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:object.description 
                                                         inManagedObjectContext:self];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    return request;
}

- (NSFetchRequest *)findAllFetchRequestForOject:(NSManagedObject *)object
{
    NSFetchRequest *request = [self fetchRequestForObject:object];
    [request setPredicate:[NSPredicate predicateWithFormat:@"1 = 1"]];
    return request;
}

@end
