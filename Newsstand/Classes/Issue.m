//
//  Issue.m
//  HowToMageAMagazine
//
//  Created by Carlo Vigiani on 4/Nov/11.
//  Copyright (c) 2011 viggiosoft. All rights reserved.
//

#import "Issue.h"


@implementation Issue

@synthesize title=_title;
@synthesize issueID=_issueID;
@synthesize releaseDate=_releaseDate;
@synthesize coverURL=_coverURL;
@synthesize downloadURL=_downloadURL;
@synthesize free=_free;
@synthesize downloadProgress=_downloadProgress;
@synthesize downloading=_downloading;

#pragma mark - Object lifecycle

-(id)init {
    self = [super init];
    if(self) {
        // you can set here all default inits
        _title=nil;
        _issueID=nil;
        _releaseDate=nil;
        _coverURL=nil;
        _downloadURL=nil;
        _downloading=NO;
    }
    return self;
}

-(void)dealloc {
    [_title release];
    [_issueID release];
    [_releaseDate release];
    [_coverURL release];
    [_downloadURL release];
    [super dealloc];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ : ID=%@ Title=%@ Released=%@ Free=%@",
            [super description],
            _issueID,
            _title,
            _releaseDate,
            _free?@"YES":@"NO"
            ];
}

#pragma mark - Public methods

/* contentURL returns the effective URL where we'll store the magazine content and data;
   if Newsstand is supported, we'll return the NKIssue URL, if not will provide a sub-directory
   of the Caches directory whose name is the issue ID
*/
-(NSURL *)contentURL {
    NSURL *theURL=[[self newsstandIssue] contentURL];
    //ELog(@"Content URL: %@",theURL);
    // creates it if not existing
    if([[NSFileManager defaultManager] fileExistsAtPath:[theURL path]]==NO) {
        //NSLog(@"Creating content directory: %@",[theURL path]);
        NSError *error=nil;
        if([[NSFileManager defaultManager] createDirectoryAtPath:[theURL path] withIntermediateDirectories:NO attributes:nil error:&error]==NO) {
            //NSLog(@"There was an error in creating the directory: %@",error); 
            ;
        }
        
    }
    // returns the url
    return theURL;
}

/* in our implementation the cover image is saved in the content URL with a file name called "cover.png" 
   if the image is found, nil will be returned
 */
-(UIImage *)coverImage {
    // get the image path
    NSString *imagePath = [[[self contentURL] URLByAppendingPathComponent:@"cover.png"] path];
    UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
    return theImage;
}

/* returns the NKIssue whose ID is the same as the issue ID */
-(NKIssue *)newsstandIssue {
    return [[NKLibrary sharedLibrary] issueWithName:_issueID];
}

/* "isIssueAvailableForRead" returns YES if the issue has been downloaded and installed and is available in the filesystem;
 the implementation is different according to the structure of the file; in our case we simply suppose the issue is made of
 a file called magazine.pdf */
-(BOOL)isIssueAvailableForRead {
    // get the magazine content path
    NSString *contentPath = [[[self contentURL] URLByAppendingPathComponent:@"magazine/content_heng_0.html"] path];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:contentPath];
    //ELog(@"Checking for path: %@ ==> %d",contentPath,fileExists);
    return(fileExists);
}


/* returns YES if the issue is currently in download */
-(BOOL)isDownloading {
    NKIssue *nkIssue = [self newsstandIssue];
    return(nkIssue.status==NKIssueContentStatusDownloading);
}

/* "addInNewsstand" adds the issue in Newsstand library (if not added yet); in iOS4 the implementation of this method does nothing */
-(void)addInNewsstand {
    if(![self newsstandIssue]) {
        //[[NKLibrary sharedLibrary] addIssueWithName:_issueID date:_releaseDate];
        [[NKLibrary sharedLibrary] addIssueWithName:_issueID date:[NSDate date]];
    }
}

-(void)deleteInNewsstand{
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    NKIssue *nkIssue =[self newsstandIssue]; 
    if (nkIssue) {
        [nkLib removeIssue:nkIssue ];
    }
}
@end
