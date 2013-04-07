//
//  ReadingViewController.h
//  Newsstand
//
//  Created by HsiuJane Sang on 2/10/12.
//  Copyright (c) 2012 JiaYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadingViewController : UIViewController<UIWebViewDelegate>{
    
    IBOutlet UIWebView *readWebView;
    NSURL *urlOfReadingIssue;
    IBOutlet UIActivityIndicatorView *activityView;
}
@property (nonatomic,retain) IBOutlet UIWebView *readWebView;
@property (nonatomic,retain)NSURL *urlOfReadingIssue;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityView;

-(void)readBook:(NSURL*)bookName;
@end
