//
//  NSManagedObject+StoreMad.h
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
// FAD = "From Apple Docs"

@interface NSManagedObject (StoreMad)

/**
 Shortcut to the objects URI.
 
 FAD: "An NSURL object containing a URI that provides an archiveable reference to the
 object which the receiver represents."
 */
@property (nonatomic, readonly) NSURL *objectURI;

/**
 Sometimes CoreData will fault a particular instance, while there is still
 the same object in the store.  Check to see if there is a clone.
 
 FAD: "The method (isDeleted) returns YES if Core Data will ask the persistent store to delete
 the object during the next save operation. It may return NO at other times,
 particularly after the object has been deleted. The immediacy with which
 it will stop returning YES depends on where the object is in the process of being deleted."
 */
@property (nonatomic, readonly) BOOL hasBeenDeleted;

/**
 Checks the objectID to see if it is permanent.
 
 FAD: "New objects inserted into a managed object context are assigned a temporary ID
 which is replaced with a permanent one once the object gets saved to a persistent store."
 */
@property (nonatomic, readonly) BOOL hasBeenSaved;

/**
 Queues and waits on an object insertion block for the objects class.
 */
+ (id)createInContext:(NSManagedObjectContext *)context;

/**
 Queues and waits a block to delete the object in it's current context
 */
- (void)deleteObject;

@end
