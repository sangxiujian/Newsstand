//
//  Store.m
//  HowToMageAMagazine
//
//  Created by Carlo Vigiani on 4/Nov/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#import "Store.h"


@interface Store (Private)

-(void)downloadStoreIssues;
-(void)loadInstalledIssues;
-(void)retrieveStorePrices;

-(NSURL *)fileURLOfCachedStoreFile;

@end

@implementation Store

@synthesize status=_status;

#pragma mark - Object lifecycle

-(id)init {
    self = [super init];
    if(self) {
        storeIssues=[[NSMutableArray alloc] init];
        userIssues=[[NSMutableDictionary alloc] init];
        _status=StoreStatusNotInizialized;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            DOWNLOAD_GCD_QUEUE = dispatch_queue_create("com.jiayuan.newsstand.magazine", DISPATCH_QUEUE_SERIAL);            
        });

    }
    return self;
}

-(void)dealloc {
    [storeIssues release];
    [userIssues release];
    [super dealloc];
}

#pragma mark - Get/Set override

/* we override the setter because we send a notification with the new status */
-(void)setStatus:(StoreStatusType)newStatus {
    if(_status==newStatus) return;
    _status=newStatus;
    dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:STORE_CHANGED_STATUS_NOTIFICATION object:[NSNumber numberWithInt:newStatus]];
    });
}

#pragma mark - Public

/* the startup phase consists of two steps:
   1. downloading the issues from the store and then setup the list of store issues
   2. loading the list of issues already purchased and installed by the user
*/
-(void)startup {
    //ELog(@"");
    [self downloadStoreIssues];
}

-(BOOL)isStoreReady {
    return(_status==StoreStatusReady);
}

#pragma mark - Startup (private)

/* download all issues info from the publisher server and builds the storeIssues status; at the end sends a notification */
-(void)downloadStoreIssues {
    //ELog(@"");
    self.status=StoreStatusDownloading;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
//        NSArray *_list = [[NSArray alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.viggiosoft.com/media/data/iosblog/magazine/store.plist"]];
 
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://api.miuu.cn/client_read/cr_jytk.php?size=10&handle=up&client_type=1&screen_size=1&state=1"]];
        NSArray *_list = nil;
        if (data) {
            NSError *jsonParsingError = nil;
            NSArray *retJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            _list = [[NSArray alloc] initWithArray:retJSON];
        }
        
        if(!_list) {
            // let's try to retrieve it locally
            _list = [[NSArray alloc] initWithContentsOfURL:[self fileURLOfCachedStoreFile]];
        }
        if(_list) {
            // now creating all issues and storing in the storeIssues array
            [_list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary *issueDictionary = (NSDictionary *)obj;
                Issue *anIssue = [[Issue alloc] init];
                anIssue.issueID=[issueDictionary objectForKey:@"qihao_id"];
                anIssue.title=[issueDictionary objectForKey:@"qihao_title"];
                anIssue.releaseDate=[issueDictionary objectForKey:@"Release date"];
                anIssue.coverURL=[issueDictionary objectForKey:@"icon"];
                anIssue.downloadURL=[issueDictionary objectForKey:@"url"];
                anIssue.free=[(NSNumber *)[issueDictionary objectForKey:@"Free"] boolValue];
                [anIssue addInNewsstand];
                [storeIssues addObject:anIssue];
                [anIssue release];
                // dispatch cover loading
                /*
                if(![anIssue coverImage]) {
                    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:anIssue.coverURL]];
                        if(imgData) {
                            [imgData writeToURL:[anIssue.contentURL URLByAppendingPathComponent:@"cover.png"] atomically:YES];
                        }
                    });
                }*/
            }];
            // let's save the file locally
            [_list writeToURL:[self fileURLOfCachedStoreFile] atomically:YES];
            [_list release];
            self.status=StoreStatusReady;
            //ELog(@"Store download success.\nIssues: %@",storeIssues);
            // now we can load installed issues
            [self loadInstalledIssues];
            // with StoreKit, we also load all prices
            [self retrieveStorePrices];

        } else {
            //ELog(@"Store download failed.");
            storeIssues = nil;
            self.status=StoreStatusError;
        }
    });
}

-(void)setCoverOfIssueAtIndex:(NSInteger)index  completionBlock:(void(^)(UIImage *img))block {
   
    Issue *anIssue = [storeIssues objectAtIndex:index];
    UIImage *image = [anIssue coverImage];
    if(image) {
        block(image);
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                       ^{
                           NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:anIssue.coverURL]];
                           UIImage *image = [UIImage imageWithData:imgData];
                           if(imgData) {
                               [imgData writeToURL:[anIssue.contentURL URLByAppendingPathComponent:@"cover.png"] atomically:YES];
                               block(image);
                           }
                       });
    }
}
/* 
 this method checks which issues are available for reading; note that this approach may depend on the type of magazine.
 in this example we suppose that the store contains all published magazines and then simply check which of the store magazines
 have been installed; but there are cases (e.g. newspapers) where not all issues are available in the store, in such case we'll need
 to keep track of local issues
 */
-(void)loadInstalledIssues {
    //ELog(@"");
    [userIssues removeAllObjects];
    for(Issue *anIssue in storeIssues) {
        if([anIssue isIssueAvailableForRead]) {
            [userIssues setObject:anIssue forKey:anIssue.issueID];
        }
    }

}

-(void)retrieveStorePrices {
    //ELog(@"");
}

#pragma mark - Issue retrieval

/* "numberOfIssues" is used to retrieve the number of issues in the store */
-(NSInteger)numberOfStoreIssues {
    return [storeIssues count];
}

/* "issueAtIndex:" retrieves the issue at the given index */
-(Issue *)issueAtIndex:(NSInteger)index {
    return [storeIssues objectAtIndex:index];
}

/* "issueWithID:" retrieves the issue with the given ID */
-(Issue *)issueWithID:(NSString *)issueID {
    for(Issue *anIssue in storeIssues) {
        if([anIssue.issueID isEqualToString:issueID]) {
            return anIssue;
        }
    }
    return nil;
}

-(NSUInteger)indexOfIssue:(Issue*)anIssue{
    return [storeIssues indexOfObject:anIssue];
}

-(NSUInteger)indexOfIssueWithID:(NSString*)issueID{

    for (int index=0; index<[storeIssues count]; index++) {
        Issue *anIssue = [storeIssues objectAtIndex:index];
        if([anIssue.issueID isEqualToString:issueID]) {
            return index;
        }
    }
    return NSNotFound;
}
#pragma mark - Private

-(NSURL *)fileURLOfCachedStoreFile {
    return [NSURL fileURLWithPathComponents:[NSArray arrayWithObjects:DocumentsDirectory, @"store.plist",nil]];
}
-(NSURL *)fileURLOfCachedLocalFile {
    return [NSURL fileURLWithPathComponents:[NSArray arrayWithObjects:DocumentsDirectory, @"local.plist",nil]];
}
@end
