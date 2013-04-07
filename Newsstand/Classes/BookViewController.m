//
//  BookViewController.m
//  Newsstand
//
//  Created by HsiuJane Sang on 2/11/12.
//  Copyright (c) 2012 JiaYuan. All rights reserved.
//

#import "BookViewController.h"
#import "BookViewCell.h"

#define kBookWidth          248.0
#define kBookHeight         266.0

#define kBookLeftMargin     102.0
#define kBookTopMargin      20.0
#define kBookShelfHeight    318.0

@interface BookViewController()
    -(void)readIssue:(NSURL *)dirInfo;
    -(void)deleteIssue:(NSString*)issueID;
@end

@implementation BookViewController
@synthesize list,dicInfo,editMode;
@synthesize readViewController;
@synthesize editBtn;

-(NSURL *)fileURLOfCachedLocalFile {
    return [NSURL fileURLWithPathComponents:[NSArray arrayWithObjects:DocumentsDirectory, @"local.plist",nil]];
}

-(void)loadLocalList{

    self.dicInfo = [NSMutableDictionary dictionaryWithContentsOfURL:[self fileURLOfCachedLocalFile]];
    self.list = [dicInfo allKeys];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        showCount = 2;
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

-(void)dealloc{

    [editBtn release];
    [readViewController release];
    [list release];
    [dicInfo release];
    [super dealloc];
}

-(void)gotoShelfView{

    [self.parentViewController dismissModalViewControllerAnimated:YES];
}
-(void)toggleEdit:(UIButton*)sender{
    
	sender.tag = (BookEditModeNormal==sender.tag)?BookEditModeDelete:BookEditModeNormal;
	[sender setImage:(BookEditModeNormal==sender.tag)?[UIImage imageNamed:@"mypbook_btn_edit"]:[UIImage imageNamed:@"mybook_btn_done.png"] forState:UIControlStateNormal];
    self.editMode = sender.tag;
    [self.tableView reloadData];
	
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:@"mybook_btn_upload"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 78, 33);
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem= barBtnItem;
    [barBtnItem release];
    [btn addTarget:self action:@selector(gotoShelfView) forControlEvents:UIControlEventTouchUpInside];
    
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:@"mypbook_btn_edit"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 78, 33);
    UIBarButtonItem *barBtnItem2 = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem= barBtnItem2;
    [barBtnItem2 release];
    self.editBtn = btn;
    [btn addTarget:self action:@selector(toggleEdit:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = BookEditModeNormal;
    
    self.editMode = BookEditModeNormal;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(issueDidEndDownload:) name:ISSUE_END_OF_DOWNLOAD_NOTIFICATION object:nil];
    
    ReadingViewController *readViewCtr = [[ReadingViewController alloc] initWithNibName:@"ReadingViewController" bundle:nil];
    self.readViewController = readViewCtr;
    [readViewCtr release];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self loadLocalList];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ISSUE_END_OF_DOWNLOAD_NOTIFICATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (oldInterfaceOrientation != self.interfaceOrientation) {
		[self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0.0];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    oldInterfaceOrientation = toInterfaceOrientation;
	if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
		showCount = 2;
		width = 768.0;
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home_bg-Portrait~ipad"]];
	}
	else {
		showCount = 3;
		width = 1024.0;
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home_bg-Landscape~ipad"]];
    }
	[self.tableView reloadData];
}


#pragma mark - TableView


/*
 * make a magazine cell on the shell
 */
-(NSArray*)makeGridCellItems:(NSUInteger)itemsCount atRow:(NSUInteger)row WithWidth:(CGFloat)btnWidth andHeight:(CGFloat)btnHeight 
{
	CGFloat middleMargin =(width - kBookLeftMargin*2 - btnWidth*itemsCount)/(itemsCount-1);
	CGRect rectSize = CGRectMake(kBookLeftMargin, kBookTopMargin, btnWidth, btnHeight);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:itemsCount];	
	for (int i = 0; i < itemsCount; i++) {
        BookView *cover = [[[BookView alloc] initWithFrame:rectSize] autorelease];
        cover.tag = row*itemsCount+i;
		//[cover.button setTag:row*itemsCount+i];
        //		[cover.button addTarget:self action:@selector(magazineClicked:)  forControlEvents:UIControlEventTouchUpInside];
        cover.delegate=self;
		[array addObject:cover];
        
        rectSize = CGRectOffset(rectSize, btnWidth+middleMargin, 0.0);
	}
	return array;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [list count];
	NSInteger rowshows = 0; 
	if (count == 0) {
		rowshows =  0;
	}else {
		rowshows = (count-1)/showCount +1;
	}
    
    return (rowshows<3?3:rowshows);
}


// Customize the appearance of table view cells.
- (UITableViewCell *)setGridStyleCellItem:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	NSUInteger row = [indexPath row];
	static NSString *GridStyleCell2Identifier = @"GridStyleViewCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GridStyleCell2Identifier];
	BookViewCell *bookInfoView;
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:GridStyleCell2Identifier] autorelease];
		CGRect bivFrame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, kBookHeight);
		bookInfoView = [[BookViewCell alloc] initWithFrame:bivFrame];
		bookInfoView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		bookInfoView.tag = 20;
		[cell.contentView addSubview:bookInfoView];
		[bookInfoView release];
	}
	else {
		bookInfoView = (BookViewCell*)[cell.contentView viewWithTag:20];
	}
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	bookInfoView.itemsArray = [self makeGridCellItems:showCount atRow:row WithWidth:kBookWidth andHeight:kBookHeight];
	
	NSUInteger count = [list count];
    NSUInteger index = row*showCount;
	for (int i = 0; i < showCount; i++) {
		if (index+i < count) {
            NSString *issueID = [list objectAtIndex:index+i];
            [bookInfoView setBookInfo:[dicInfo objectForKey:issueID] atIndex:i];
		}
		else{
			[bookInfoView setBookInfo:nil atIndex:i];
		}
	}
    bookInfoView.editMode = self.editMode;
    
    NSString *imageName;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        imageName = @"mybook_cell_bg-Portrait~ipad";
    }
    else {
        imageName = @"mybook_cell_bg-Landscape~ipad";
    }
    UIImageView *imageview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
    cell.backgroundView = imageview;
    [imageview release];
    
	return cell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger numberOfRows = [list count]/showCount+([list count]%showCount>0?1:0);
  	if (indexPath.row >= numberOfRows)
	{
		static NSString *CellIdentifier = @"Cell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *imageName;
		if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
			imageName = @"mybook_cell_bg-Portrait~ipad";
		}
		else {
			imageName = @"mybook_cell_bg-Landscape~ipad";
		}
		UIImageView *imageview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
		cell.backgroundView = imageview;
		[imageview release];
		return cell;
		
	}
	return [self setGridStyleCellItem:tableView cellForRowAtIndexPath:indexPath];
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kBookShelfHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}



#pragma mark - BookViewDelegate implementation 
-(void)bookSelected:(BookView *)cover {
    NSUInteger tag = cover.tag;
    if (tag <[list count]) {
        NSString *issueID = [list objectAtIndex:tag];
        NSString *path = [[dicInfo objectForKey:issueID] objectForKey:@"content"];
        NSURL *urlPath = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [self readIssue:urlPath];
    }
}

-(void)bookActionClicked:(BookView *)cover {
    NSUInteger tag = cover.tag;
    if (tag <[list count]) {
        NSString *issueID = [list objectAtIndex:tag];
        [self deleteIssue:issueID];
        [self.tableView reloadData];
    }
}

-(void)bookEnterEditMode{
    if (editBtn.tag ==BookEditModeDelete ) {
        return;
    }
    [self toggleEdit:editBtn];
}

#pragma mark - Actions

-(void)readIssue:(NSURL *)dirInfo {
    //    QLPreviewController *preview = [[QLPreviewController alloc] initWithNibName:nil bundle:nil];
    //    preview.delegate=self;
    //    preview.dataSource=self;
    NSString *addinfo = @"content_heng_0.html";
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
        addinfo = @"content_shu_0.html";
    }
    NSURL *urlOfReadingIssue=[dirInfo URLByAppendingPathComponent:addinfo];
    //need by sxj
    //NSLog(@"read:%@",[dirInfo path]);
    [readViewController readBook:urlOfReadingIssue];
    [self presentModalViewController:readViewController animated:YES];
}

-(void)deleteIssue:(NSString*)issueID{
    
    NSString *path = [[dicInfo objectForKey:issueID] objectForKey:@"content"];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator* en = [fm enumeratorAtPath:path];    
    NSError* err = nil;
    BOOL res;
    
    NSString* file;
    while (file = [en nextObject]) {
        res = [fm removeItemAtPath:[path stringByAppendingPathComponent:file] error:&err];
        if (!res && err) {
            NSLog(@"oops: %@", err);
        }
    }

    [dicInfo removeObjectForKey:issueID];
    [dicInfo writeToURL:[self fileURLOfCachedLocalFile] atomically:YES];
    
    NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:issueID, @"issueID",nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ISSUE_END_OF_DELETE_NOTIFICATION object:self userInfo:userinfo];

    
}

-(void)issueDidEndDownload:(NSNotification *)notification {
       
    [self loadLocalList];
    [self.tableView reloadData];
}

@end
