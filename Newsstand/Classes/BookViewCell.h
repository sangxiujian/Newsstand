//
//  BookViewCell.h
//  Newsstand
//
//  Created by HsiuJane Sang on 2/11/12.
//  Copyright (c) 2012 JiaYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BookView.h"

@interface BookViewCell : UIView {
    
	NSArray *itemsArray;
    BookEditMode editMode;
}
@property (nonatomic,retain)NSArray *itemsArray;
@property (nonatomic,assign)BookEditMode editMode;

-(void)setBookInfo:(NSDictionary*)aBookInfo atIndex:(NSUInteger)index;
@end