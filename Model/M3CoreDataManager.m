//
//  AppDelegate+CDStuff.m
//  Minim
//
//  Created by Martin Pilkington on 15/07/2009.
//  Copyright 2009 M Cubed Software. All rights reserved.
//

#import "M3CoreDataManager.h"

@implementation M3CoreDataManager

@synthesize delegate;

- (id)initWithInitialType:(NSString *)type appSupportName:(NSString *)supName modelName:(NSString *)mName dataStoreName:(NSString *)storeName {
	if (self = [super init]) {
		initialType = type;
		if (!type) {
			initialType = NSSQLiteStoreType;
		}
		appSupportName = supName;
		modelName = mName;
		dataStoreName = storeName;
	}
	return self;
}


/**
 Returns the support folder for the application, used to store the Core Data
 store file.  This code uses a folder named "Minim" for
 the content, either in the NSApplicationSupportDirectory location or (if the
 former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder
{	
	#ifdef TARGET_OS_IPHONE
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	#else
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
	return [basePath stringByAppendingPathComponent:appSupportName];
	#endif
}

/**
 Creates, retains, and returns the managed object model for the application 
 by merging all of the models found in the application bundle.
 */

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
	
	
	
	
#warning This code is hard coded for RunQuest atm
	NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"RunQuest" ofType:@"momd"];
	NSLog(@"modelPath is %@", modelPath);
    NSURL *modelUrl = [NSURL fileURLWithPath:modelPath];
//	NSURL *modelUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], modelName]];
	NSLog(@"modelUrl is %@", modelUrl);
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.  This 
 implementation will create and return a coordinator, having added the 
 store for the application to it.  (The folder for the store is created, 
 if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSFileManager *fileManager;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    
	#ifdef TARGET_OS_IPHONE
	url = [NSURL fileURLWithPath:[[self applicationSupportFolder] stringByAppendingPathComponent:dataStoreName]];
	#else
	NSString *applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: dataStoreName]];
	#endif
	
	
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    if (![persistentStoreCoordinator addPersistentStoreWithType:initialType configuration:nil URL:url options:options error:&error]){
		if ([error code] == 134100) {
			//If we failed with an incorrect data model error then pass the version identifiers of the store to the delegate to decide what to do next
			if ([[self delegate] respondsToSelector:@selector(coreDataManager:encounteredIncorrectModelWithVersionIdentifiers:)]) {
				persistentStoreCoordinator = nil;
				NSDictionary *metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:initialType URL:url error:&error];
				[[self delegate] coreDataManager:self encounteredIncorrectModelWithVersionIdentifiers:[metadata objectForKey:NSStoreModelVersionIdentifiersKey]];
			}
		} else {
			#ifdef TARGET_OS_IPHONE
			// TODO: Add iPhone implementation
			#else
			[[NSApplication sharedApplication] presentError:error];
			#endif
			
		}
    }    
	
    return persistentStoreCoordinator;
}


/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.) 
 */

- (NSManagedObjectContext *) managedObjectContext {
    if (!managedObjectContext) {
		NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
		if (coordinator != nil) {
			managedObjectContext = [[NSManagedObjectContext alloc] init];
			[managedObjectContext setPersistentStoreCoordinator: coordinator];
		}
	}
    
    return managedObjectContext;
}

#warning Need to fix this to work on both platforms, not working atm not sure why.
#ifdef TARGET_OS_IPHONE

- (void)save
{
	NSError *error = nil;
	//NSInteger reply = NSTerminateNow;
	NSManagedObjectContext *moc = [self managedObjectContext];
	if (moc != nil) {
		if (YES) {
			if ([moc hasChanges] && ![moc save:&error]) {
				// TODO: Replace with something iPhone specific
//				BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
//				
//				if (errorResult == YES) {
//					reply = NSTerminateCancel;
//				} else {
//					NSInteger alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
//					if (alertReturn == NSAlertAlternateReturn) {
//						reply = NSTerminateCancel;	
//					}
//				}
			}
		} else {
			//reply = NSTerminateCancel;
		}
	}
	return;
}

#else

- (NSApplicationTerminateReply)save {
	NSError *error = nil;
	NSInteger reply = NSTerminateNow;
	NSManagedObjectContext *moc = [self managedObjectContext];
	if (moc != nil) {
		if ([moc commitEditing]) {
			if ([moc hasChanges] && ![moc save:&error]) {
				BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
				if (errorResult == YES) {
					reply = NSTerminateCancel;
				} else {
					NSInteger alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
					if (alertReturn == NSAlertAlternateReturn) {
						reply = NSTerminateCancel;	
					}
				}
			}
		} else {
			reply = NSTerminateCancel;
		}
	}
	return reply;
}

#endif




@end
