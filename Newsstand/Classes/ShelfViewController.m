//
//  ShelfViewController.m
//  Newsstand
//
//  Created by HsiuJane Sang on 2/7/12.
//  Copyright (c) 2012 JiaYuan. All rights reserved.
//

#import "ShelfViewController.h"

#import "Store.h"
#import "CoverView.h"
#import "Issue.h"
#import "ShelfViewCell.h"

#import "ZipArchive.h"
#import "BookViewController.h"


#define kMagazineLeftMargin     10.0
#define kMagazineTopMargin      10.0

#define kMagazineWidth          248.0
#define kMagazineHeight         266.0

#define kShelfHeight            (kMagazineTopMargin+kMagazineHeight)
#define kTopLogoHeight          186.0

@interface ShelfViewController (Private)

-(void)startup;
-(void)showShelf;
-(void)updateShelf;
-(void)readIssue:(Issue *)issue;
-(void)downloadIssue:(Issue *)issue updateCover:(CoverView *)cover;
-(void)pauseIssue:(Issue *)issue updateCover:(CoverView *)cover;

-(void)downloadIssueAtIndex:(NSUInteger)index;
@end

@implementation ShelfViewController

@synthesize containerView=containerView_;
@synthesize store=_store;
@synthesize readViewController = _readViewController;
@synthesize actionBtn = _actionBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        showCount = 3;
		width = 768;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)gotoBookView{

    BookViewController *bookViewController = [[BookViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:bookViewController];
    [bookViewController release];
    [self presentModalViewController:nav animated:YES];
    
    [nav release];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home_bg-Portrait~ipad"]];
    CGRect containFrame = CGRectMake(0.0, kTopLogoHeight, self.view.bounds.size.width, self.view.bounds.size.height-kTopLogoHeight);
    UITableView *tableView = [[UITableView alloc]initWithFrame:containFrame style:UITableViewStylePlain];
	tableView.delegate = self;
	tableView.dataSource = self;
	tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = nil;
	[self.view addSubview:tableView];
    self.containerView = tableView;
    [tableView release];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(gotoBookView) forControlEvents:UIControlEventTouchUpInside];
    //btn.frame = CGRectMake(840, 120, 146, 44);
    btn.frame = CGRectMake(614, 120, 146, 44);
    [btn setBackgroundImage:[UIImage imageNamed:@"home_book"] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    self.actionBtn = btn;
    
    ReadingViewController *readViewCtr = [[ReadingViewController alloc] initWithNibName:@"ReadingViewController" bundle:nil];
    self.readViewController = readViewCtr;
    [readViewCtr release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(storeDidChangeStatusNotification:) 
                                                 name:STORE_CHANGED_STATUS_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(issueDidEndDownload:) name:ISSUE_END_OF_DOWNLOAD_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(issueDidFailDownload:) name:ISSUE_FAILED_DOWNLOAD_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(issueDidDelete:) name:ISSUE_END_OF_DELETE_NOTIFICATION object:nil];
    //[self updateShelf];
    //[self startup];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([_store isStoreReady]) {
        containerView_.alpha=1.0;
    } else {
        containerView_.alpha=0.0;
    }
    if (oldInterfaceOrientation != self.interfaceOrientation) {
		[self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0.0];
	}
}

- (void)viewDidUnload
{
    [self setContainerView:nil];
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:STORE_CHANGED_STATUS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ISSUE_END_OF_DOWNLOAD_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ISSUE_FAILED_DOWNLOAD_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ISSUE_END_OF_DELETE_NOTIFICATION object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    // Return YES for supported orientations
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    oldInterfaceOrientation = toInterfaceOrientation;
	if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
		showCount = 3;
		width = 768.0;
		 self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home_bg-Portrait~ipad"]];
        self.actionBtn.frame = CGRectMake(614, 120, 146, 44);
	}
	else {
		showCount = 4;
		width = 1024.0;
        self.actionBtn.frame = CGRectMake(840, 120, 146, 44);
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home_bg-Landscape~ipad"]];
    }
	[self.containerView reloadData];
}

- (void)dealloc {
    [containerView_ release];
    [_store release];
    [super dealloc];
}

#pragma mark - View display

-(void)storeDidChangeStatusNotification:(NSNotification *)not {
    //ELog(@"Store changed status to %d",_store.status);
    [self showShelf];
}
-(void)showShelf {
    if([_store isStoreReady]) {
        containerView_.alpha=1.0;
    } else {
        containerView_.alpha=0.0;
    }
    [containerView_ reloadData];
}

#pragma mark - TableView


/*
 * make a magazine cell on the shell
 */
-(NSArray*)makeGridCellItems:(NSUInteger)itemsCount atRow:(NSUInteger)row WithWidth:(CGFloat)btnWidth andHeight:(CGFloat)btnHeight 
{
	CGFloat middleMargin =(width - kMagazineLeftMargin*2 - btnWidth*itemsCount)/(itemsCount-1);
	CGRect rectSize = CGRectMake(kMagazineLeftMargin, kMagazineTopMargin, btnWidth, btnHeight);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:itemsCount];	
	for (int i = 0; i < itemsCount; i++) {
        CoverView *cover = [[[CoverView alloc] initWithFrame:rectSize] autorelease];
        cover.tag = row*itemsCount+i;
		//[cover.button setTag:row*itemsCount+i];
        //		[cover.button addTarget:self action:@selector(magazineClicked:)  forControlEvents:UIControlEventTouchUpInside];
        cover.delegate=self;
		[array addObject:cover];
        
        rectSize = CGRectOffset(rectSize, btnWidth+middleMargin, 0.0);
	}
	return array;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger count = [_store numberOfStoreIssues];
	NSInteger rowshows = 0; 
	if (count == 0) {
		rowshows =  0;
	}else {
		rowshows = (count-1)/showCount +1;
	}
    return rowshows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)setGridStyleCellItem:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	NSUInteger row = [indexPath row];
	static NSString *GridStyleCell2Identifier = @"GridStyleViewCell2";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GridStyleCell2Identifier];
	ShelfViewCell *bookInfoView;
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GridStyleCell2Identifier] autorelease];
		CGRect bivFrame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, kShelfHeight);
		bookInfoView = [[ShelfViewCell alloc] initWithFrame:bivFrame];
		bookInfoView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		bookInfoView.tag = 20;
		[cell.contentView addSubview:bookInfoView];
		[bookInfoView release];
	}
	else {
		bookInfoView = (ShelfViewCell*)[cell.contentView viewWithTag:20];
	}
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	bookInfoView.itemsArray = [self makeGridCellItems:showCount atRow:row WithWidth:kMagazineWidth andHeight:kMagazineHeight];
	
	NSUInteger count = [_store numberOfStoreIssues];
    NSUInteger index = row*showCount;
	for (int i = 0; i < showCount; i++) {
		if (index+i < count) {
            Issue *anIssue = [_store issueAtIndex:index+i];
            [bookInfoView setCoverInfo:anIssue atIndex:i];
            
            [_store setCoverOfIssueAtIndex:index+i completionBlock:^(UIImage *img) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    NSIndexPath *indexPathInTableView = [NSIndexPath indexPathForRow:(index+i)/showCount inSection:0];
                    UITableViewCell *cell = [self.containerView cellForRowAtIndexPath:indexPathInTableView];
                    
                    ShelfViewCell *bookInfoView = (ShelfViewCell*)[cell.contentView viewWithTag:20];
                    [bookInfoView setCoverImage:img atIndex:((index+i)%showCount)];
                    
                });
            }];

		}
		else{
			[bookInfoView setCoverInfo:nil atIndex:i];
		}
	}
	return cell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger numberOfRows = [_store numberOfStoreIssues]/showCount+([_store numberOfStoreIssues]%showCount>0?1:0);
  	if (indexPath.row >= numberOfRows)
	{
		static NSString *CellIdentifier = @"Cell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		return cell;
		
	}
	return [self setGridStyleCellItem:tableView cellForRowAtIndexPath:indexPath];
}


#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kShelfHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
	[tableView  deselectRowAtIndexPath:indexPath animated:NO];
}

//
//#pragma mark QuickLook
//
//-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
//    return 1;
//}
//
//-(id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
//    return urlOfReadingIssue;
//}
//
//-(void)previewControllerDidDismiss:(QLPreviewController *)controller {
//    [controller autorelease];
//}



#pragma mark - CoverViewDelegate implementation 
-(void)coverSelected:(CoverView *)cover {
    NSString *selectedIssueID = cover.issueID;
    Issue *selectedIssue = [_store issueWithID:selectedIssueID];
    if(!selectedIssue) return;
    if([selectedIssue isIssueAvailableForRead]) {
        [self readIssue:selectedIssue];
    } 
//    else{
//        [self downloadIssue:selectedIssue updateCover:cover];
//    }
}

-(void)coverActionClicked:(CoverView *)cover {
    NSUInteger tag = cover.tag;
    if (tag <[_store numberOfStoreIssues]) {
        Issue *selectedIssue = [_store issueAtIndex:tag];
        if(!selectedIssue) return;
        if([selectedIssue isIssueAvailableForRead]) {
            [self readIssue:selectedIssue];
        } else{
            if (![selectedIssue isDownloading]) {
                [self downloadIssueAtIndex:tag];
            }
        }
    }
}


#pragma mark - Actions

-(void)readIssue:(Issue *)issue {
//    QLPreviewController *preview = [[QLPreviewController alloc] initWithNibName:nil bundle:nil];
//    preview.delegate=self;
//    preview.dataSource=self;
    NSString *addinfo = @"magazine/content_heng_0.html";
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
        addinfo = @"magazine/content_shu_0.html";
    }
    urlOfReadingIssue=[[issue contentURL] URLByAppendingPathComponent:addinfo];
    //need by sxj
    
    [_readViewController readBook:urlOfReadingIssue];
    [self presentModalViewController:_readViewController animated:YES];
    //[self presentModalViewController:preview animated:YES];
}

-(void)downloadIssueAtIndex:(NSUInteger)index{
    
//    NSIndexPath *indexPathInTableView = [NSIndexPath indexPathForRow:index/showCount inSection:0];
//    UITableViewCell *cell = [self.containerView cellForRowAtIndexPath:indexPathInTableView];
//    ShelfViewCell *bookInfoView = (ShelfViewCell*)[cell.contentView viewWithTag:20];    
//    CoverView *cover = [bookInfoView coverViewAtIndex:index%showCount];
//    cover.progress.alpha=1.0;
//    cover.button.alpha=0.0;
//    Issue *issue = [_store issueAtIndex:index];
//    issue.delegate=self;
//    [_store scheduleDownloadOfIssue:issue];
    
    Issue *issueToDownload = [_store issueAtIndex:index];
    NSString *downloadURL = [issueToDownload downloadURL];
    if(!downloadURL) {
        return;
    }
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadURL]];
    NKIssue *nkIssue = [issueToDownload newsstandIssue];
    NKAssetDownload *assetDownload = [nkIssue addAssetWithRequest:downloadRequest];
    [assetDownload downloadWithDelegate:self];
    [assetDownload setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                issueToDownload.issueID,@"issueID",
                                nil]];
    
    NSIndexPath *indexPathInTableView = [NSIndexPath indexPathForRow:index/showCount inSection:0];
    UITableViewCell *cell = [self.containerView cellForRowAtIndexPath:indexPathInTableView];
    ShelfViewCell *bookInfoView = (ShelfViewCell*)[cell.contentView viewWithTag:20];  
    //[bookInfoView setCoverInfo:selectedIssue atIndex:tag%showCount];
    [bookInfoView setProcessInfo:.0f atIndex:index%showCount];
    
}

-(void)issueDidEndDownload:(NSNotification *)notification {
    Issue *issue = (Issue *)[notification object];
    NSUInteger tag = [_store indexOfIssue:issue];
    if (tag == NSNotFound) {
        return;
    }
    
    NSIndexPath *indexPathInTableView = [NSIndexPath indexPathForRow:tag/showCount inSection:0];
    UITableViewCell *cell = [self.containerView cellForRowAtIndexPath:indexPathInTableView];
    
    ShelfViewCell *bookInfoView = (ShelfViewCell*)[cell.contentView viewWithTag:20];    
    CoverView *cover = [bookInfoView coverViewAtIndex:tag%showCount];
    if (cover) {
        cover.progress.alpha=0.0;
        [cover.button setTitle:@"阅读" forState:UIControlStateNormal];
        cover.button.alpha=1.0;
    }    
   
}



-(void)issueDidDelete:(NSNotification *)notification{

    [containerView_ reloadData];
}

-(void)issueDidFailDownload:(NSNotification *)notification {
    Issue *issue = (Issue *)[notification object];
    NSUInteger tag = [_store indexOfIssue:issue];
    if (tag == NSNotFound) {
        return;
    }
    NSIndexPath *indexPathInTableView = [NSIndexPath indexPathForRow:tag/showCount inSection:0];
    UITableViewCell *cell = [self.containerView cellForRowAtIndexPath:indexPathInTableView];
    
    ShelfViewCell *bookInfoView = (ShelfViewCell*)[cell.contentView viewWithTag:20];    
    CoverView *cover = [bookInfoView coverViewAtIndex:tag%showCount];
    if (cover) {
        cover.progress.alpha=0.0;
        [cover.button setTitle:@"阅读" forState:UIControlStateNormal];
        cover.button.alpha=1.0;
    }
    
}

#pragma mark - NSURLConnectionDelegate/NSURLConnectionDownloadDelegate (only for Newsstand)

-(void)updateProgressOfConnection:(NSURLConnection *)connection withTotalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    // get asset
    NKAssetDownload *dnl = connection.newsstandAssetDownload;
    NSString *issueID = [dnl.userInfo objectForKey:@"issueID"];
    NSUInteger index = [_store indexOfIssueWithID:issueID];
    if (index!=NSNotFound) {
        
        NSIndexPath *indexPathInTableView = [NSIndexPath indexPathForRow:index/showCount inSection:0];
        UITableViewCell *cell = [self.containerView cellForRowAtIndexPath:indexPathInTableView];
        ShelfViewCell *bookInfoView = (ShelfViewCell*)[cell.contentView viewWithTag:20];    
        [bookInfoView setProcessInfo:1.f*totalBytesWritten/expectedTotalBytes atIndex:index%showCount];
    }   
}

// this message allows us to update the download progress
-(void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    [self updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}

-(void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    [self updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}

-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    // copy the file to the destination directory
    NKAssetDownload *dnl = connection.newsstandAssetDownload;
    NKIssue *nkIssue = dnl.issue;
    NSString *issueID = [dnl.userInfo objectForKey:@"issueID"];
    
    NSURL *finalURL = [[nkIssue contentURL] URLByAppendingPathComponent:@"magazine.zip"];
    NSURL *bookURL = [[nkIssue contentURL] URLByAppendingPathComponent:@"magazine"];
    //NSURL *finalURL = [nkIssue contentURL];
    //ELog(@"Copying item from %@ to %@",destinationURL,finalURL);
    [[NSFileManager defaultManager] copyItemAtURL:destinationURL toURL:finalURL error:NULL];
    [[NSFileManager defaultManager] removeItemAtURL:destinationURL error:NULL];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        BOOL result = NO;
        ZipArchive *za = [[ZipArchive alloc] init];
        
        if ([za UnzipOpenFile:[finalURL relativePath]]) {
            result = [za UnzipFileTo:[bookURL relativePath] overWrite:YES];
            [za UnzipCloseFile];
        }
        [za release];
        if (result) {
            [[NSFileManager defaultManager] removeItemAtURL:finalURL error:NULL];
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfURL:[_store fileURLOfCachedLocalFile]];
            if (!dic) {
                dic = [NSMutableDictionary dictionaryWithCapacity:1];
            }
            
            Issue *issue = [_store issueWithID:issueID];
            NSString *path = [[nkIssue contentURL] path];
            NSDictionary *bookDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"第%@期",issueID],@"title",
                                     issue.title ,@"subtitle",
                                     [NSString stringWithFormat:@"%@/cover.png",path],@"cover",
                                     [NSString stringWithFormat:@"%@/magazine",path],@"content", nil];
            [dic setObject:bookDic forKey:issueID];
           
            [dic writeToURL:[_store fileURLOfCachedLocalFile] atomically:YES];
            
            // post notification
            
            NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:issueID, @"issueID",nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ISSUE_END_OF_DOWNLOAD_NOTIFICATION object:self userInfo:userinfo];
            
            [containerView_ reloadData];
        }
        
    });
    
    
    Issue *anIssue = [_store issueWithID:issueID];
    UIImage *coverImage = nil;
    if (anIssue) {
        coverImage = [anIssue coverImage];
    }
    if (coverImage) {
         // update Newsstand icon
        [[UIApplication sharedApplication] setNewsstandIconImage:[anIssue coverImage]];
    }
   
    
   
    
     [containerView_ reloadData];
}


@end
