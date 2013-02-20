//
//  UIView+HHBadge.h
//  UIView-Badge
//
//  Created by hyukhur on 13. 2. 20..
//  Copyright (c) 2013년 hyukhur. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HHBadgeView : UIView
@property(nonatomic, strong) UIFont       *font;
@property(nonatomic, assign) NSUInteger    value;
@property(nonatomic, assign) NSUInteger    maxValue;
@property(nonatomic, strong) NSString     *text;
@property(nonatomic, strong) UIColor      *textColor;
@property(nonatomic, assign) CGSize        size;
@end

@interface UIView (HHBadge)
@property(nonatomic, assign, readonly) HHBadgeView *badgeView;
@end
