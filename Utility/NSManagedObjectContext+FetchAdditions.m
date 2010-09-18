//
//  NSManagedObjectContext+FetchAdditions.m
//

#import "NSManagedObjectContext+FetchAdditions.h"


@implementation NSManagedObjectContext (FetchAdditions)

// Convenience method to fetch the array of objects for a given Entity
// name in the context, optionally limiting by a predicate or by a predicate
// made from a format NSString and variable arguments.
// From http://cocoawithlove.com/2008/03/core-data-one-line-fetch.html

- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
{
    return [self fetchObjectsForEntityName:newEntityName withPredicate:nil];
}

- (id)fetchObjectForEntityName:(NSString *)newEntityName
{
    return [self fetchObjectForEntityName:newEntityName withPredicate:nil];
}

- (id)fetchObjectForEntityName:(NSString *)entityName
				 withPredicate:(NSPredicate *)predicate
{
	NSEntityDescription *entity = [NSEntityDescription
								   entityForName:entityName inManagedObjectContext:self];
	
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
	[request setEntity:entity];
	[request setIncludesSubentities:YES];
	[request setPredicate:predicate];
	[request setFetchLimit:1];
	
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:request error:&error];
    if (error != nil)
    {
        [NSException raise:NSGenericException format:[error description]];
    }
    
    if ( [results count] )
		return [results objectAtIndex:0];
	else 
		return nil;
}

- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
				   withPredicateFormat:(NSString *)predicateFormat, ...
{
	NSPredicate *predicate;
    if (predicateFormat)
    {
		va_list variadicArguments;
		va_start(variadicArguments, predicateFormat);
		predicate = [NSPredicate predicateWithFormat:predicateFormat
										   arguments:variadicArguments];
		va_end(variadicArguments);
    } 
	else 
	{
		predicate = [NSPredicate predicateWithValue:YES];
	}
	
	return [self fetchObjectsForEntityName:newEntityName withPredicate:predicate];
}


- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
						 withPredicate:(NSPredicate *)predicate
{
    NSEntityDescription *entity = [NSEntityDescription
								   entityForName:newEntityName inManagedObjectContext:self];
	
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
	[request setEntity:entity];
	[request setIncludesSubentities:YES];
	[request setPredicate:predicate];
	
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:request error:&error];
    if (error != nil)
    {
        [NSException raise:NSGenericException format:[error description]];
    }
    
    return results;
}

- (id)fetchObjectForEntityName:(NSString *)newEntityName
		   withPredicateFormat:(NSString *)predicateFormat, ...
{
	NSPredicate *predicate;
    if (predicateFormat)
    {
		va_list variadicArguments;
		va_start(variadicArguments, predicateFormat);
		predicate = [NSPredicate predicateWithFormat:predicateFormat
										   arguments:variadicArguments];
		va_end(variadicArguments);
    } 
	else 
	{
		predicate = [NSPredicate predicateWithValue:YES];
	}
	
	return [self fetchObjectForEntityName:newEntityName withPredicate:predicate];
}

- (NSUInteger)countOfObjectsForEntityName:(NSString *)newEntityName
							withPredicate:(NSPredicate *)predicate
{
	NSEntityDescription *entity = [NSEntityDescription
								   entityForName:newEntityName inManagedObjectContext:self];
	
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
	[request setPredicate:predicate];
	[request setIncludesSubentities:YES];
    NSError *error = nil;
    NSUInteger count  = [self countForFetchRequest:request error:&error];
    if (error != nil)
    {
        [NSException raise:NSGenericException format:[error description]];
    }
    
    return count;
	
}

//from http://cocoawithlove.com/2008/08/safely-fetching-nsmanagedobject-by-uri.html

- (NSManagedObject *)objectWithURI:(NSURL *)uri
{
    NSManagedObjectID *objectID =
	[[self persistentStoreCoordinator]
	 managedObjectIDForURIRepresentation:uri];
    
    if (!objectID)
    {
        return nil;
    }
    
    NSManagedObject *objectForID = [self objectWithID:objectID];
    if (![objectForID isFault])
    {
        return objectForID;
    }
	
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[objectID entity]];
    
    // Equivalent to
    // predicate = [NSPredicate predicateWithFormat:@"SELF = %@", objectForID];
    NSPredicate *predicate =
	[NSComparisonPredicate
	 predicateWithLeftExpression:
	 [NSExpression expressionForEvaluatedObject]
	 rightExpression:
	 [NSExpression expressionForConstantValue:objectForID]
	 modifier:NSDirectPredicateModifier
	 type:NSEqualToPredicateOperatorType
	 options:0];
    [request setPredicate:predicate];
	
    NSArray *results = [self executeFetchRequest:request error:nil];
    if ([results count] > 0 )
    {
        return [results objectAtIndex:0];
    }
	
    return nil;
}

@end
