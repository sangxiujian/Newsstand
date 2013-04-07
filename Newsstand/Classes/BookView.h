//
//  BookView.h
//  Newsstand
//
//  Created by HsiuJane Sang on 2/11/12.
//  Copyright (c) 2012 JiaYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SECOND_FONT_SIZE    15.0

typedef enum {
    BookEditModeNormal          = 0,
    BookEditModeDelete        = 1
} BookEditMode;

@class BookView;
@protocol BookViewDelegate

-(void)bookSelected:(BookView *)bookView;
-(void)bookActionClicked:(BookView*)bookView;
-(void)bookEnterEditMode;

@end

@interface BookView : UIView{
    NSDictionary *bookInfo;
    BookEditMode editMode;
}


@property (nonatomic,assign) NSObject <BookViewDelegate> *delegate;
@property (nonatomic,copy) NSString *issueID;

@property (nonatomic,retain) UIImageView *cover;
@property (nonatomic,retain) UIButton *button;
@property (nonatomic,retain) UILabel *title;
@property (nonatomic,retain) UILabel *subtitle;

@property (nonatomic,assign)BookEditMode editMode;
@property (nonatomic,retain)NSDictionary *bookInfo;

@end
