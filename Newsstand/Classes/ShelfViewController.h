//
//  ShelfViewController.h
//  Newsstand
//
//  Created by HsiuJane Sang on 2/7/12.
//  Copyright (c) 2012 JiaYuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NewsstandKit/NewsstandKit.h>
#import "CoverView.h"
#import "Store.h"
#import "ReadingViewController.h"

@interface ShelfViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NSURLConnectionDownloadDelegate,CoverViewDelegate> {
    
    NSURL *urlOfReadingIssue;
    UIInterfaceOrientation oldInterfaceOrientation;
    
    
    NSUInteger showCount;
	CGFloat width;
    
}

@property (retain, nonatomic) UITableView*containerView;
@property (retain, nonatomic) Store *store;

@property (retain, nonatomic) ReadingViewController *readViewController;

@property (retain, nonatomic)UIButton *actionBtn;
 
@end
