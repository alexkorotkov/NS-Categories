//
//  NSObject+NSObject_File.m
//  Extends
//
//  Created by bigmac on 25/09/12.
//  Copyright (c) 2012 Jean Alexandre Iragne. All rights reserved.
//

#import "NSObject+NSObject_File.h"

@implementation NSObject (NSObject_File)

static NSString *NSObject_File_application_cache_folder_path = nil;
static NSString *NSObject_File_application_temp_folder_path = nil;
static NSString *NSObject_File_application_document_folder_path = nil;


/**
 *  GET FOLDER PATHS (Document, Document/tmp, Cache)
 *
 */

#pragma mark - Folder paths access
+(NSString *)getApplicationDocumentPath
{
    if (NSObject_File_application_document_folder_path == nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSObject_File_application_document_folder_path = paths[0];
    }
    return NSObject_File_application_document_folder_path;
}

+(NSString *)getApplicationCachePath
{
    if (NSObject_File_application_cache_folder_path == nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSObject_File_application_cache_folder_path = paths[0];
    }
    return NSObject_File_application_cache_folder_path;
}

+(NSString *)getApplicationTempPath
{
    if (NSObject_File_application_temp_folder_path == nil)
    {
        NSString *tmpDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        tmpDir = [[tmpDir stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"tmp"];
        NSObject_File_application_temp_folder_path = tmpDir;
    }
    return NSObject_File_application_temp_folder_path;
}

/**
 *  FILES PATH CREATION (Document, Document/tmp, Cache)
 *
 */

#pragma mark - File paths access

#pragma mark Document/
+(NSString *)getApplicationDocumentPathForFile:(NSString *)fileName
{
    return [[NSObject getApplicationDocumentPath] stringByAppendingPathComponent:fileName];
}

#pragma mark Cache/
+(NSString *)getApplicationCachePathForFile:(NSString *)fileName
{
    return [[NSObject getApplicationCachePath] stringByAppendingPathComponent:fileName];}

#pragma mark Temp/
+(NSString *)getApplicationTempPath:(NSString *)fileName
{
    return [[NSObject getApplicationDocumentPath] stringByAppendingPathComponent:fileName];
}

+(BOOL)isFileExistingAtPath:(NSString *)filePath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

/**
 *  OBJECT CREATION FROM FILE
 *
 */

#pragma mark - Get objects from files

+(id) getObjectFromFileAtPath:(NSString *)filePath withTTL:(NSUInteger)ttl
{
    if (filePath && [filePath length]> 0)
    {
        [NSObject dateModifiedSort:filePath withTTL:ttl];
        id storedObject = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath] ;
        return storedObject;
    }
    else
        return nil;
}

#pragma mark Document/
+(id) getObjectFromDocumentFile:(NSString *)fileName withTTL:(NSUInteger)ttl
{
    return [NSObject getObjectFromFileAtPath:[NSObject getApplicationDocumentPathForFile:fileName] withTTL:ttl];
}

#pragma mark Cache/
+(id) getObjectFromCacheFile:(NSString *)fileName withTTL:(NSUInteger)ttl
{
    return [NSObject getObjectFromFileAtPath:[NSObject getApplicationCachePathForFile:fileName] withTTL:ttl];
}


#pragma mark Temp/
+(id) getObjectFromTempFile:(NSString *)fileName withTTL:(NSUInteger)ttl
{
    return [NSObject getObjectFromFileAtPath:[NSObject getApplicationTempPathForFile:fileName] withTTL:ttl];
}

/**
 *  OBJECT SAVING IN FILE
 *
 */

#pragma mark - Save objects in files

-(void)saveObjectInFileAtPath:(NSString *)filePath
{
    [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

#pragma mark Document/
-(void)saveObjectInDocumentFile:(NSString *)fileName
{
    [self saveObjectInFileAtPath:[NSObject getApplicationDocumentPathForFile:fileName]];
}

#pragma mark Cache/
-(void)saveObjectInCacheFile:(NSString*)fileName
{
    [self saveObjectInFileAtPath:[NSObject getApplicationCachePathForFile:fileName]];
}

#pragma mark Temp/
-(void)saveObjectInTempFile:(NSString*)fileName
{
    [self saveObjectInFileAtPath:[NSObject getApplicationTempPathForFile:fileName]];
}


/**
 *  FILE CLEANING
 *
 */

#pragma mark - File cleaning

+(void)emptyContentOfFilePath:(NSString *)filePath
{
    [NSKeyedArchiver archiveRootObject:nil toFile:filePath];
}

#pragma mark Document/
+(void)emptyContentOfDocumentFile:(NSString *)fileName
{
    [self emptyContentOfFilePath:[NSObject getApplicationDocumentPathForFile:fileName]];
}

#pragma mark Cache/
+(void)emptyContentOfCacheFile:(NSString *)fileName
{
    [self emptyContentOfFilePath:[NSObject getApplicationCachePathForFile:fileName]];
}

#pragma mark Temp/
+(void)emptyContentOfTempFile:(NSString *)fileName
{
    [self emptyContentOfFilePath:[NSObject getApplicationTempPathForFile:fileName]];
}

/**
 *  FILE REMOVING
 *
 */

#pragma mark - File removing

+(void)removeFileAtPath:(NSString *)filePath
{
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

#pragma mark Document/
+(void)removeDocumentFile:(NSString *)fileName
{
    [NSObject removeFileAtPath:[NSObject getApplicationDocumentPathForFile:fileName]];
}

#pragma mark Cache/
+(void)removeCacheFile:(NSString *)fileName
{
    [NSObject removeFileAtPath:[NSObject getApplicationDocumentPathForFile:fileName]];
}

+(void)removeCacheFiles
{
    NSError *error;
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSObject getApplicationCachePath] error:&error];
    if (!error)
    {
        for (NSString *file in tmpDirectory)
            [NSObject removeCacheFile:file];
    }
    else
    {
        DLog(@"[%@] Error accessing temporary directory: %@", NSStringFromClass([self class]), [error description]);
    }
}

#pragma mark Temp/
+(void)removeTempFile:(NSString *)fileName
{
    [NSObject removeFileAtPath:[NSObject getApplicationDocumentPathForFile:fileName]];
}


/**
 *  TTL CHECKING
 *
 */

#pragma mark - TTL Checking
+(NSInteger)dateModifiedSort:(NSString *)fileName withTTL:(NSUInteger)ttl
{
    NSDictionary *attributesForFile = [[NSFileManager defaultManager]
                                       attributesOfItemAtPath:fileName
                                       error:nil];
    
	NSDate *modificationDate = attributesForFile[NSFileModificationDate];
	NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:-(ttl)];
	if ([modificationDate compare:currentDate] == NSOrderedDescending || modificationDate == nil)
		return 0;
	[[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
	return 1;
}


@end
