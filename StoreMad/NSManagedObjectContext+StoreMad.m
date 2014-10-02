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

- (NSManagedObjectContext *)stm_threadSafeCopy
{    
    //
    // Create new context with default concurrency type
    //
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [newContext setParentContext:self];
    
    //
    // Optimization.  No undos in background thread.
    //
    [newContext setUndoManager:nil];
    
    return newContext;
}

#pragma mark - Save

- (void)stm_save
{
    NSError *error;
    [self save:&error];
    [self handleErrors:error];
}

- (void)stm_queueBlockSave
{
    [self performBlock:^{
        [self stm_save];
    }];
}

- (void)stm_queueBlockSaveAndWait
{
    [self performBlockAndWait:^{
        [self stm_save];
    }];
}

- (void)stm_queueBlockSaveOnParentContext
{
    [self.parentContext performBlock:^{
        [self.parentContext stm_save];
    }];
}

#pragma mark - URI Helpers

- (NSManagedObject *)stm_objectForURI:(NSURL *)objectURI
{
    NSManagedObjectID *objectID = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:objectURI];
    if (!objectID) return nil;
    
    // If the object cannot be fetched, or does not exist, or cannot be faulted, existingObjectWithID returns nil
    NSError *error;
    NSManagedObject *object = [self existingObjectWithID:objectID
                                                   error:&error];
    
    [self handleErrors:error];
    
    return object;
}

#pragma mark - Delete

- (void)stm_deleteObjects:(NSArray *)objects
{
    for (NSManagedObject *object in objects) {
        [self deleteObject:object];
    }
}

- (void)stm_deleteObjectAtURI:(NSURL *)objectURI
{
    NSManagedObject *object = [self stm_objectForURI:objectURI];
    if (!object) return;
    [self deleteObject:object];
}

#pragma mark - Fetching
     
- (NSArray *)stm_executeFetchRequest:(NSFetchRequest *)request
{    
    NSError *error;
    NSArray *results = [self executeFetchRequest:request error:&error];

    [self handleErrors:error];

    return results;
}

- (NSManagedObject *)stm_executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request
{
    [request setFetchLimit:1];
    NSArray *results = [self stm_executeFetchRequest:request];
    if (results.count < 1) return nil;
    return [results objectAtIndex:0];
}

- (NSUInteger)stm_countForFetchRequest:(NSFetchRequest *)request
{
    // Optimization?  I'd imagine it doesn't include these when counting, but
    // should test.
    request.includesPropertyValues = NO;
        
    NSError *error;
    NSUInteger count = [self countForFetchRequest:request error:&error];
    
    [self handleErrors:error];
    
    return count;
}

- (NSUInteger)stm_countForObjectClass:(Class)objectClass
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(objectClass)];
    return [self stm_countForFetchRequest:request];
}

- (NSArray *)stm_allValuesForProperty:(NSString *)propertyName
                          withRequest:(NSFetchRequest *)request
{
    // This could be really slow.  Use carefully.
    NSDictionary *properties = request.entity.propertiesByName;
    NSPropertyDescription *property = [properties objectForKey:propertyName];
    if (!property) return nil;
    
    [request setPropertiesToFetch:@[property]];
    [request setResultType:NSDictionaryResultType];
    NSArray *results = [self stm_executeFetchRequest:request];
    
    NSMutableArray *propertyValuesList = [NSMutableArray arrayWithCapacity:results.count];
    for (NSManagedObject *object in results) {
        [propertyValuesList addObject:[object valueForKey:propertyName]];
    }
    
    return propertyValuesList;
}

#pragma mark - Fetch Requests

- (NSFetchRequest *)stm_fetchRequestForObjectNamed:(NSString *)objectName
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:objectName 
                                                         inManagedObjectContext:self];
    
    // Fetch request must have an entity
    if (!entityDescription) return nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    return request;
}

- (NSFetchRequest *)stm_findAllFetchRequestForObjectNamed:(NSString *)objectName
{
    NSFetchRequest *request = [self stm_fetchRequestForObjectNamed:objectName];
    [request setPredicate:[NSPredicate predicateWithFormat:@"1 = 1"]];
    return request;  
}

- (NSFetchRequest *)stm_fetchRequestForObjectClass:(Class)objectClass;
{
    return [self stm_fetchRequestForObjectNamed:NSStringFromClass(objectClass)];
}

- (NSFetchRequest *)stm_findAllFetchRequestForObjectClass:(Class)objectClass
{
    return [self stm_findAllFetchRequestForObjectNamed:NSStringFromClass(objectClass)];
}

#pragma mark - Create

- (NSManagedObject *)stm_insertNewObjectForEntityNamed:(NSString *)entityName
{
    // If entity is nil, initWithEntity will cause a crash. So make sure to bail.
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:self];
    if (!entity) return nil;
    
    NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entity
                                       insertIntoManagedObjectContext:self];
    return object;
}

@end
