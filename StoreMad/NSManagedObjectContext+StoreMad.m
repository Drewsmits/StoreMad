//
//  NSManagedObjectContext+StoreMad.m
//  StoreMad
//
//  Created by Andrew Smith on 7/20/12.
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

#import "NSManagedObjectContext+StoreMad.h"
#import "StoreMad.h"

@implementation NSManagedObjectContext (StoreMad)

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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

#pragma mark - Thread

- (NSManagedObjectContext *)threadSafeCopy
{
    // Grab the main coordinator
    NSPersistentStoreCoordinator *coord = [self persistentStoreCoordinator];
    
    // Create new context with default concurrency type
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [newContext setPersistentStoreCoordinator:coord];
    
    // Optimization.  No undos in background thread.
    [newContext setUndoManager:nil];
    
    // Observer saves from this context.  The context this was called from needs
    // to live long enough to get these merge changes.
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(threadSafeCopyDidSave:) 
                                                 name:NSManagedObjectContextDidSaveNotification 
                                               object:newContext];
    
    return newContext;
}

- (void)threadSafeCopyDidSave:(NSNotification *)notification {
    SEL selector = @selector(mergeChangesFromContextDidSaveNotification:);
    
    NSManagedObjectContext *threadContext = (NSManagedObjectContext *)notification.object;
    
    [self performSelectorOnMainThread:selector 
                           withObject:notification 
                        waitUntilDone:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:NSManagedObjectContextDidSaveNotification 
                                                  object:threadContext];
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
    // Optimization?  I'd imagine it doesn't include these when counting, but
    // should test.
    request.includesPropertyValues = NO;
    
    NSError *error = nil;
    NSUInteger count = [self countForFetchRequest:request error:&error];
    [self handleErrors:error];
    return count;
}

- (NSArray *)allValuesForProperty:(NSString *)propertyName 
                      withRequest:(NSFetchRequest *)request
{
    // This could be really slow.  Use carefully.
    [request setPropertiesToFetch:[NSArray arrayWithObject:propertyName]];
    NSArray *results = [self executeFetchRequest:request];
    
    NSMutableArray *propertyValuesList = [NSMutableArray arrayWithCapacity:results.count];
    for (NSManagedObject *object in results) {
        [propertyValuesList addObject:[object valueForKey:propertyName]];
    }
    
    return propertyValuesList;
}

#pragma mark - Fetch Requests

- (NSFetchRequest *)fetchRequestForObjectNamed:(NSString *)objectName
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:objectName 
                                                         inManagedObjectContext:self];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    return request;
}

- (NSFetchRequest *)findAllFetchRequestForObjectNamed:(NSString *)objectName
{
    NSFetchRequest *request = [self fetchRequestForObjectNamed:objectName];
    [request setPredicate:[NSPredicate predicateWithFormat:@"1 = 1"]];
    return request;  
}

- (NSFetchRequest *)fetchRequestForObjectClass:(Class)objectClass;
{
    return [self fetchRequestForObjectNamed:NSStringFromClass(objectClass)];
}

- (NSFetchRequest *)findAllFetchRequestForObjectClass:(Class)objectClass 
{
    return [self findAllFetchRequestForObjectNamed:NSStringFromClass(objectClass)];
}

- (NSFetchRequest *)fetchRequestForObject:(NSManagedObject *)object
{
    return [self fetchRequestForObjectNamed:object.description];
}

- (NSFetchRequest *)findAllFetchRequestForObject:(NSManagedObject *)object
{
    return [self findAllFetchRequestForObjectNamed:object.description];
}

@end
