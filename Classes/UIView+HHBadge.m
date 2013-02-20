//
//  UIView+HHBadge.m
//  UIView-Badge
//
//  Created by hyukhur on 13. 2. 20..
//  Copyright (c) 2013년 hyukhur. All rights reserved.
//

#import "UIView+HHBadge.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>


static char aAssociatedBadgeViewObjectKey;

@implementation UIView (HHBadge)


- (void)setBadgeViewObject:(HHBadgeView *)associatedObject
{
    if (![self.badgeViewObject isEqual:associatedObject])
    {
        [self willChangeValueForKey:@"badgeViewObject"];
        objc_setAssociatedObject(self, &aAssociatedBadgeViewObjectKey, associatedObject, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"badgeViewObject"];
    }
}

- (HHBadgeView *)badgeViewObject
{
    return objc_getAssociatedObject(self, &aAssociatedBadgeViewObjectKey);
}


- (HHBadgeView *)badgeView
{
    if(!self.badgeViewObject)
    {
        HHBadgeView *sBadgeView = [[HHBadgeView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [sBadgeView setText:nil];
        [sBadgeView setUserInteractionEnabled:NO];
        [self addSubview:sBadgeView];
        [sBadgeView setContentMode:UIViewContentModeTopRight];
        [self setBadgeViewObject:sBadgeView];
    }
    return self.badgeViewObject;
}


@end


@implementation HHBadgeView

#pragma mark - private


- (void)setupLayers
{
    if (self.text.length)
    {
        CALayer *sShapeLayer = [CALayer layer];
        [sShapeLayer setFrame:[self bounds]];
        [sShapeLayer setCornerRadius:ceilf([self bounds].size.height / 2)];
        [sShapeLayer setBackgroundColor:[[UIColor redColor] CGColor]];
        [sShapeLayer setBorderColor:[[UIColor whiteColor] CGColor]];
        [sShapeLayer setBorderWidth:2.2];
        [sShapeLayer setMasksToBounds:YES];
        
        CAGradientLayer *sGradient = [CAGradientLayer layer];
        [sGradient setFrame:[self bounds]];
        [sGradient setStartPoint:CGPointMake(0.5, 0.0)];
        [sGradient setEndPoint:CGPointMake(0.5, 1.0)];
        [sGradient setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0],  nil]];
        [sGradient setColors:[NSArray arrayWithObjects:
                              (id)[[UIColor colorWithWhite:1.0 alpha:0.98] CGColor],
                              (id)[[UIColor clearColor] CGColor], nil]];
        [sShapeLayer addSublayer:sGradient];
        
        CATextLayer *sTextLayer = [CATextLayer layer];
        [sTextLayer setAlignmentMode:kCAAlignmentCenter];
        [sTextLayer setContentsScale:[[UIScreen mainScreen] scale]];
        [sTextLayer setForegroundColor:[[self textColor] CGColor]];
        CGFontRef sCGFont = CGFontCreateWithFontName((__bridge CFStringRef)[[self font] fontName]);
        [sTextLayer setFont:sCGFont];
        CGFontRelease(sCGFont);
        [sTextLayer setFontSize:[[self font] lineHeight]];
        CGRect sRect = CGRectMake(0, ceilf(([self bounds].size.height - [sTextLayer fontSize] ) / 2), [self bounds].size.width, [sTextLayer fontSize]);
        sRect.origin.y -= 2;    // 위치 보정
        [sTextLayer setFrame:sRect];
        [sTextLayer setString:[self text]];
        
        [[self layer] addSublayer:sShapeLayer];
        [[self layer] addSublayer:sTextLayer];
        
        [[self layer] setShadowOffset:CGSizeMake(0, 3)];
        [[self layer] setShadowColor:[[UIColor blackColor] CGColor]];
        [[self layer] setShadowOpacity:0.9];
    }
}


- (void)layoutSubviews
{
    CGRect sRect = [self frame];
    sRect.size = [[self text] sizeWithFont:[self font]];
    sRect.size.width = MAX(sRect.size.width + sRect.size.height, [self size].width);
    sRect.size.height = MAX(sRect.size.height, [self size].height);
    [self setFrame:sRect];
    [[[self layer] sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self setupLayers];
}


#pragma mark - life cycle


- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        [self setSize:aFrame.size];
        [self setFont:[UIFont boldSystemFontOfSize:10]];
        [self setText:nil];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setTextColor:[UIColor whiteColor]];
        [self setMaxValue:NSUIntegerMax];
        [self addObserver:self forKeyPath:@"value" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:(__bridge void *)[self class]];
        [self addObserver:self forKeyPath:@"text" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:(__bridge void *)[self class]];
        [self addObserver:self forKeyPath:@"size" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:(__bridge void *)[self class]];
        [self addObserver:self forKeyPath:@"font" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:(__bridge void *)[self class]];
        [self addObserver:self forKeyPath:@"contentMode" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:(__bridge void *)[self class]];
    }
    return self;
}


- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"value"];
    [self removeObserver:self forKeyPath:@"text"];
    [self removeObserver:self forKeyPath:@"size"];
    [self removeObserver:self forKeyPath:@"font"];
    [self removeObserver:self forKeyPath:@"contentMode"];
}


- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)aObject change:(NSDictionary *)aChange context:(void *)aContext
{
    if ([[self class] isSubclassOfClass:(__bridge id)aContext])
    {
        if ([aKeyPath isEqualToString:@"contentMode"])
        {
            CGPoint sPoint = CGPointZero;
            switch ([self contentMode])
            {
                case UIViewContentModeTopLeft:
                {
                    sPoint = CGPointMake(0, 0);
                    break;
                }
                case UIViewContentModeTop:
                {
                    sPoint = CGPointMake([[self superview] frame].size.width / 2, 0);
                    break;
                }
                case UIViewContentModeTopRight:
                {
                    sPoint = CGPointMake([[self superview] frame].size.width, 7);
                    break;
                }
                case UIViewContentModeCenter:
                {
                    sPoint = CGPointMake([[self superview] frame].size.width / 2, [[self superview] frame].size.height / 2);
                    break;
                }
                default:
                {
                    break;
                }
            }
            [self setCenter:sPoint];
        }
        else if ([@"value" isEqualToString:aKeyPath])
        {
            NSNumber *sValue = [aChange objectForKey:NSKeyValueChangeNewKey];
            if ([sValue unsignedIntegerValue] >= [self maxValue])
            {
                [self setText:[NSString stringWithFormat:@"%d+", [self maxValue]]];
            }
            else if ([sValue unsignedIntegerValue] > 0)
            {
                [self setText:[sValue stringValue]];
            }
            else
            {
                [self setText:@""];
            }
        }
        else if ([@"text" isEqualToString:aKeyPath])
        {
            NSString *sText = [aChange objectForKey:NSKeyValueChangeNewKey];
            [self setHidden:!(sText && ![sText isKindOfClass:[NSNull class]] && sText.length)];
        }
        
        [self setNeedsLayout];
    }
    else
    {
        [super observeValueForKeyPath:aKeyPath ofObject:aObject change:aChange context:aContext];
    }
}


@end
