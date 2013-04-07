//
//  BookViewController.h
//  Newsstand
//
//  Created by HsiuJane Sang on 2/11/12.
//  Copyright (c) 2012 JiaYuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookView.h"
#import "ReadingViewController.h"

@interface BookViewController : UITableViewController<BookViewDelegate>{

    NSArray *list;
    NSMutableDictionary *dicInfo;
    BookEditMode editMode;
    
    NSUInteger showCount;
	CGFloat width;
    UIInterfaceOrientation oldInterfaceOrientation;
    ReadingViewController *readViewController;
    
    UIButton *editBtn;
}

@property (retain, nonatomic) ReadingViewController *readViewController;
@property (nonatomic ,retain) UIButton *editBtn;
@property (nonatomic,retain) NSArray *list;
@property (nonatomic,retain) NSMutableDictionary *dicInfo;
@property (nonatomic,assign) BookEditMode editMode;

@end
