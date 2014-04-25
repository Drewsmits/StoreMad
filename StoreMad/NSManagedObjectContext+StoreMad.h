//
//  NSManagedObjectContext+StoreMad.h
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

/**
 
 !!!
 With any of these methods, you have to respect the NSManagedObjectContext internal queues. It's 
 recommended that you wrap a bunch of context work in a performBlock, or performBlockAndWait. Methods
 that provide their own blocks specifically say so in the method name. For example, `queueBlockSave`
 will queue a block save on the context.
 !!!
 
 */

@interface NSManagedObjectContext (StoreMad)

/**
 Creates a new managed object context based on the current contexts persistent store.
 When you save with the thread safe copy, it will merge the changes on the main 
 thread as long as the copy you created the thread safe copy from is still around.
 
 Note: You have to allocate the threadSafeCopy on the thread you want to use it with.
 */
- (NSManagedObjectContext *)threadSafeCopy;

/**
 Standard save, but handles any errors with some (hopefully) usefull logging for you
 */
- (void)save;

/**
 Adds performBlock wrapped save. Use this when you are outside of a performBlock to save right from
 the main thread.
 */
- (void)queueBlockSave;

/**
 Adds a performBlock wrapped save and waits for it to finish. Use this to block the calling thread
 until the save is finished.
 */
- (void)queueBlockSaveAndWait;

/**
 If a parent context is present, queue a performBlock wrapped save on the parent context. This is
 useful if you are calling save from a background thread onto the main context.
 */
- (void)queueBlockSaveOnParentContext;

/**
 Returns the NSManagedObject for the corresponding URI. If the object cannot be fetched, or does 
 not exist, or cannot be faulted, this will return nil.
 */
- (NSManagedObject *)objectForURI:(NSURL *)objectURI;

/**
 Deletes the object at the given URI.
 */
- (void)deleteObjectAtURI:(NSURL *)objectURI;

/**
 Deletes and array of NSManagedObjects
 */
- (void)deleteObjects:(NSArray *)objects;

/**
 Handy wrapper around executeFetchRequest that handles errors nicely.
 */
- (NSArray *)executeFetchRequest:(NSFetchRequest *)request;

/**
 Executes the fetch request and returns the first object of the result. Fetch limit is set to 1 for
 faster fetching.
 */
- (NSManagedObject *)executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request;

/**
 Handy wrapper around countForFetchRequest that handles errors nicely.
 */
- (NSUInteger)countForFetchRequest:(NSFetchRequest *)request;

/**
 Handy wrapper around countForFetchRequest
 */
- (NSUInteger)countForObjectClass:(Class)objectClass;

/**
 This will fetch a list of all properties of a given entity. For example, if you have a twitter app
 and you wanted all tweetId (Integer 64) property values on your Tweet object, you could use this method.
 
 NSFetchRequest *tweetFetch = [self findAllFetchRequestForObjectNamed:@"Tweet"];
 NSArray *result = [context allValuesForProperty:@"tweetId" withRequest:tweetFetch];
 
 <result = [1, 5, 25, 123, 82349, 29292, … ] >
 
 NOTE: Fetched properties will only include properties of objects that have been saved.
 */
- (NSArray *)allValuesForProperty:(NSString *)propertyName 
                      withRequest:(NSFetchRequest *)request;

/**
 Returns a fetch request for the object name. Returns nil if context has no object registered with
 the given name.
 */
- (NSFetchRequest *)fetchRequestForObjectNamed:(NSString *)objectName;

/**
 Returns a fetch request that will find all of the objects of the given name. Adds a predicate that
 always returns YES for all objects. Fast way of fetching all objects for the given objectName.
 
 NOTE: this includes a predicate with 1==1, which does nothing. However, NSFetchedResultsController
 requires a predicate for it's fetch request, so use this instead of fetchRequestForObjectNamed with
 no predicate.
 */
- (NSFetchRequest *)findAllFetchRequestForObjectNamed:(NSString *)objectName;

/**
 Returns a fetch request for the object matching the provided class name.
 */
- (NSFetchRequest *)fetchRequestForObjectClass:(Class)objectClass;

/**
 Returns a fetch request that will find all of the objects of the given name. Adds a predicate that
 always returns YES for all objects. Fast way of fetching all objects for the given objectName.
 
 NOTE: this includes a predicate with 1==1, which does nothing. However, NSFetchedResultsController
 requires a predicate for it's fetch request, so use this instead of fetchRequestForObjectNamed with
 no predicate.
 */
- (NSFetchRequest *)findAllFetchRequestForObjectClass:(Class)objectClass;

/**
 Inserts a new object for the entity name in the given context, returns said object if successful.
 */
- (NSManagedObject *)insertNewObjectForEntityNamed:(NSString *)entityName;

@end
