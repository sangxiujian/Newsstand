//
//  ReadingViewController.m
//  Newsstand
//
//  Created by HsiuJane Sang on 2/10/12.
//  Copyright (c) 2012 JiaYuan. All rights reserved.
//

#import "ReadingViewController.h"

@implementation ReadingViewController
@synthesize readWebView;
@synthesize urlOfReadingIssue;
@synthesize activityView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    [activityView release];
    [urlOfReadingIssue release];
    [readWebView release];
    [super dealloc];
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [readWebView loadRequest:[NSURLRequest requestWithURL:urlOfReadingIssue]];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
#pragma mark - 

-(void)readBook:(NSURL*)bookName{
    self.urlOfReadingIssue = bookName;
    [readWebView loadRequest:[NSURLRequest requestWithURL:urlOfReadingIssue]];
}

#pragma mark - Rotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    NSString * url = [self.readWebView.request.URL description];
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        url = [url stringByReplacingOccurrencesOfString:@"heng" withString:@"shu"];
    }else{
        url = [url stringByReplacingOccurrencesOfString:@"shu" withString:@"heng"];
    }
    
    [readWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    
}

#pragma mark - WebView Delegate

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)aRequest navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString * aReqeststr = [[aRequest URL] absoluteString];
   
    if ([aReqeststr  rangeOfString:@"home_list.html"].location!=NSNotFound) {
        [readWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML='';"];
        [self dismissModalViewControllerAnimated:YES];
        return NO;
    }
    return YES;
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
	
	[activityView setHidden:NO];
	[activityView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	
	[activityView setHidden:YES];
	[activityView stopAnimating];    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	
	[activityView setHidden:YES];
	[activityView stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
     [self dismissModalViewControllerAnimated:YES];
}
@end
