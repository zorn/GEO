/*****************************************************************
 M3SimpleCoreData.m
 M3Extensions
 
 Created by Martin Pilkington on 10/10/2008.
 
 Copyright (c) 2006-2009 M Cubed Software
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 *****************************************************************/

#import "M3SimpleCoreData.h"


@implementation M3SimpleCoreData

@synthesize managedObjectModel;
@synthesize managedObjectContext;

- (NSArray *)objectsInEntityWithName:(NSString *)name predicate:(NSPredicate *)pred sortedWithDescriptors:(NSArray *)descriptors {
	//Check the required variables are set
	if (!managedObjectModel || !managedObjectContext || !name) {
		return nil;
	}
	
	NSEntityDescription *entity = [[managedObjectModel entitiesByName] objectForKey:name];
	
	//If our entity doesn't exist return nil
	if (!entity) {
		NSLog(@"entity doesn't exist in entities:%@", [managedObjectModel entitiesByName]);
		return nil;
	}
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	[request setEntity:entity];
	[request setPredicate:pred];
	[request setSortDescriptors:descriptors];
	
	NSError *error = nil;
	NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
	[request release];
	
	//If there was an error then return nothing
	if (error) {
		NSLog(@"error:%@", error);
		return nil;
	}
	
	return results;
}
	
- (NSManagedObject *)newObjectInEntityWithName:(NSString *)name values:(NSDictionary *)values {
	//Check the required variables are set
	if (!managedObjectModel || !managedObjectContext || !name) {
		return nil;
	}
	
	NSEntityDescription *entity = [[managedObjectModel entitiesByName] objectForKey:name];
	
	//If our entity doesn't exist return nil
	if (!entity) {
		return nil;
	}
	
	NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
	
	if (!object) {
		return nil;
	}
	
	for (NSString *key in [values allKeys]) {
		[object setValue:[values objectForKey:key] forKey:key];
	}
	return object;
}

@end
