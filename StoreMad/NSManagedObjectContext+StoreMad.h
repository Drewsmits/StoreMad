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

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (StoreMad)

/**
 Creates a new managed object context based on the current contexts persistent store.
 When you save with the thread safe copy, it will merge the changes on the main 
 thread as long as the copy you created the thread safe copy from is still around.
 */
- (NSManagedObjectContext *)threadSafeCopy;

- (NSManagedObject *)objectForURI:(NSURL *)objectURI;
- (void)deleteObjectAtURI:(NSURL *)objectURI;

- (void)deleteObjects:(NSArray *)objects;

- (NSArray *)executeFetchRequest:(NSFetchRequest *)request;
- (NSManagedObject *)executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request;
- (NSUInteger)countForFetchRequest:(NSFetchRequest *)request;
- (NSArray *)allValuesForProperty:(NSString *)propertyName 
                      withRequest:(NSFetchRequest *)request;

- (NSFetchRequest *)fetchRequestForObjectNamed:(NSString *)objectName;
- (NSFetchRequest *)findAllFetchRequestForObjectNamed:(NSString *)objectName;

- (NSFetchRequest *)fetchRequestForObjectClass:(Class)objectClass;
- (NSFetchRequest *)findAllFetchRequestForObjectClass:(Class)objectClass;

- (NSFetchRequest *)fetchRequestForObject:(NSManagedObject *)object;
- (NSFetchRequest *)findAllFetchRequestForObject:(NSManagedObject *)object;

@end
