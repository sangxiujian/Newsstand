//
//  BookViewCell.m
//  Newsstand
//
//  Created by HsiuJane Sang on 2/11/12.
//  Copyright (c) 2012 JiaYuan. All rights reserved.
//

#import "BookViewCell.h"

@implementation BookViewCell


@synthesize itemsArray;
@synthesize editMode;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

-(void)resetSubViews
{
	for (UIView *ctrView in self.subviews) {
		if ([ctrView isKindOfClass:[BookView class]]) {
			[ctrView removeFromSuperview];
		}
	}
	for (BookView *itemView in itemsArray) {
		[self addSubview:itemView];
	}
}
-(void)setItemsArray:(NSArray *)newArray{
	if (itemsArray!=newArray) {
		[itemsArray release];
		itemsArray = [newArray retain];
		[self resetSubViews];
	}
}
-(void)setBookInfo:(NSDictionary*)aBookInfo atIndex:(NSUInteger)index{

    if (index>=[itemsArray count]) {
		return;
	}
    BookView *book = [itemsArray objectAtIndex:index];
    if (aBookInfo) {
        book.bookInfo = aBookInfo;
        book.hidden = NO;
    }else{
        book.hidden = YES;
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code.
 }
 */


-(void)setEditMode:(BookEditMode)anEditMode{
    editMode = anEditMode;
    for (BookView *itemView in itemsArray) {
        itemView.editMode = anEditMode;
    }
    
//    if (editMode != anEditMode) {
//        editMode = anEditMode;
//        for (BookView *itemView in itemsArray) {
//            itemView.editMode = anEditMode;
//        }
//    }
}
- (void)dealloc {
	[itemsArray release];
    [super dealloc];
}


@end
