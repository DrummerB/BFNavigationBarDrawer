//
//  BFNavigationBarDrawer.m
//  BFNavigationBarDrawer
//
//  Created by Balázs Faludi on 04.03.14.
//  Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import "BFNavigationBarDrawer.h"

#define kAnimationDuration 0.3

@implementation BFNavigationBarDrawer {
	UINavigationBar *parentBar;
	NSLayoutConstraint *verticalDrawerConstraint;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self setup];
    }
    return self;
}

- (id)init
{
    self = [self initWithFrame:CGRectMake(0, 0, 320, 44)];
    return self;
}

- (void)setup {
	// BFNavigationBarDrawbar is a UIToolbar subclass to have the same design as regular bars and to simply
	// be able to add UIBarButtonItems (a navigation bar is designed to have a title in the middle and more
	// difficult to use as a drawer). UIToolbars don't have a border on the bottom side, so we have to add one.
	UIView *lineView = [[UIView alloc] init];
	lineView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
	lineView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:lineView];
	
	NSDictionary *views = @{@"line" : lineView};
	NSDictionary *metrics = @{@"width" : @(1.0 / [UIScreen mainScreen].scale)}; // 1 physical pixel border high on any screen.
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[line]|" options:0 metrics:metrics views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[line(width)]|" options:0 metrics:metrics views:views]];
	
	self.translatesAutoresizingMaskIntoConstraints = NO;
	
	_visible = NO;
}

- (void)setScrollView:(UIScrollView *)scrollView {
	if (_scrollView != scrollView) {
		_scrollView = scrollView;

	}
}

- (CGRect)finalFrameForNavigationBar:(UINavigationBar *)bar {
	CGRect rect = CGRectMake(bar.frame.origin.x,
							 bar.frame.origin.y + bar.frame.size.height,
							 bar.frame.size.width,
							 self.frame.size.height);
	return rect;
}

- (CGRect)initialFrameForNavigationBar:(UINavigationBar *)bar {
	CGRect rect = [self finalFrameForNavigationBar:bar];
	rect.origin.y -= rect.size.height;
	return rect;
}

- (void)setupConstraintsWithNavigationBar:(UINavigationBar *)bar {
	
	NSLayoutConstraint *constraint;
	constraint = [NSLayoutConstraint constraintWithItem:self
											  attribute:NSLayoutAttributeLeft
											  relatedBy:NSLayoutRelationEqual
												 toItem:bar
											  attribute:NSLayoutAttributeLeft
											 multiplier:1
											   constant:0];
	[self.superview addConstraint:constraint];
	
	constraint = [NSLayoutConstraint constraintWithItem:self
											  attribute:NSLayoutAttributeRight
											  relatedBy:NSLayoutRelationEqual
												 toItem:bar
											  attribute:NSLayoutAttributeRight
											 multiplier:1
											   constant:0];
	[self.superview addConstraint:constraint];
	
	constraint = [NSLayoutConstraint constraintWithItem:self
											  attribute:NSLayoutAttributeHeight
											  relatedBy:NSLayoutRelationEqual
												 toItem:nil
											  attribute:NSLayoutAttributeNotAnAttribute
											 multiplier:1
											   constant:44];
	[self addConstraint:constraint];
}

- (void)constrainBehindNavigationBar:(UINavigationBar *)bar {
	[self.superview removeConstraint:verticalDrawerConstraint];
	verticalDrawerConstraint = [NSLayoutConstraint constraintWithItem:self
															attribute:NSLayoutAttributeBottom
															relatedBy:NSLayoutRelationEqual
															   toItem:bar
															attribute:NSLayoutAttributeBottom
														   multiplier:1
															 constant:0];
	[self.superview addConstraint:verticalDrawerConstraint];
}


- (void)constrainBelowNavigationBar:(UINavigationBar *)bar {
	[self.superview removeConstraint:verticalDrawerConstraint];
	verticalDrawerConstraint = [NSLayoutConstraint constraintWithItem:self
															attribute:NSLayoutAttributeTop
															relatedBy:NSLayoutRelationEqual
															   toItem:bar
															attribute:NSLayoutAttributeBottom
														   multiplier:1
															 constant:0];
	[self.superview addConstraint:verticalDrawerConstraint];
}

- (void)showFromNavigationBar:(UINavigationBar *)bar animated:(BOOL)animated {
	
	parentBar = bar;
	if (!parentBar) {
		NSLog(@"Cannot display navigation bar from nil.");
		return;
	}
	
	[bar.superview insertSubview:self belowSubview:bar];
	[self setupConstraintsWithNavigationBar:bar];
	
	// Place the drawer behind the navigation bar at the beginning of the animation.
	if (animated) {
		[self constrainBehindNavigationBar:bar];
	}
	[self.superview layoutIfNeeded];
	
	// This is a bit messy. Because navigation and toolbars are now translucent, we can't just resize the afftected scroll view
	// to make place for the drawer. Instead we have to change the contentInset property of the scroll view. Increasing the
	// contentInset.top value will make sure, that the drawer doesn't cover the first cell in a table view, but the scroll view
	// can still scroll under the drawer. Changing the contentInset however can't be animated unfortunately (or it can, by putting
	// it in an animation block, but that might break). To fix this, we have to animate the contentOffset property instead. First,
	// the contentOffset is changed in the opposite direction with no animation, basically negating the contentInset change. Then,
	// it is changed a second time, this time animated. Calculating the correct offsets is a bit tricky, because it depends on
	// whether or not the content size is bigger than the scroll view's height and whether the content is scrolled all the way to
	// the top, or the bottom. This calculation could probably be simplified, but this seems to be correct for now.
	CGFloat height = self.frame.size.height;
	CGFloat visible = _scrollView.bounds.size.height - _scrollView.contentInset.top - _scrollView.contentInset.bottom;
	CGFloat diff = visible - _scrollView.contentSize.height;
	CGFloat fix = MAX(0.0, MIN(height, diff));
	
	// Increase the top inset of the affected scroll view, so the first cell is not covered by the drawer.
	UIEdgeInsets insets = _scrollView.contentInset;
	insets.top += height;
	_scrollView.contentInset = insets;
	_scrollView.scrollIndicatorInsets = insets;
	_scrollView.contentOffset = CGPointMake(_scrollView.contentOffset.x, _scrollView.contentOffset.y + fix);
	
	[self constrainBelowNavigationBar:bar];
	void (^animations)() = ^void() {
		[self.superview layoutIfNeeded];
		_scrollView.contentOffset = CGPointMake(_scrollView.contentOffset.x, _scrollView.contentOffset.y - height);
	};
	
	void (^completion)(BOOL) = ^void(BOOL finished) {
		_visible = YES;
	};
	
	if (animated) {
		[UIView animateWithDuration:kAnimationDuration animations:animations completion:completion];
	} else {
		animations();
		completion(YES);
	}
	
}

- (void)hideAnimated:(BOOL)animated {
	if (!parentBar) {
		NSLog(@"Navigation bar should not be released while drawer is visible.");
		return;
	}
	
	// See that big comment block above.
	CGFloat height = self.frame.size.height;
	CGFloat visible = _scrollView.bounds.size.height - _scrollView.contentInset.top - _scrollView.contentInset.bottom;
	CGFloat fix = height;
	if (visible <= _scrollView.contentSize.height - height) {
		CGFloat bottom = -_scrollView.contentOffset.y + _scrollView.contentSize.height;
		CGFloat diff = bottom - _scrollView.bounds.size.height + _scrollView.contentInset.bottom;
		fix = MAX(0.0, MIN(height, diff));
	}
	CGFloat offset = height - (_scrollView.contentOffset.y + _scrollView.contentInset.top);
	CGFloat topFix = MAX(0.0, MIN(height, offset));
	
	// Reverse the change to the inset of the affected scroll view.
	UIEdgeInsets insets = _scrollView.contentInset;
	insets.top -= height;
	_scrollView.contentInset = insets;
	_scrollView.scrollIndicatorInsets = insets;
	_scrollView.contentOffset = CGPointMake(_scrollView.contentOffset.x, _scrollView.contentOffset.y - topFix);
	
	[self constrainBehindNavigationBar:parentBar];
	void (^animations)() = ^void() {
		[self.superview layoutIfNeeded];
		_scrollView.contentOffset = CGPointMake(_scrollView.contentOffset.x, _scrollView.contentOffset.y + fix);
		
	};
	
	void (^completion)(BOOL) = ^void(BOOL finished) {
		_visible = NO;
		[self removeFromSuperview];
	};
	
	if (animated) {
		[UIView animateWithDuration:kAnimationDuration animations:animations completion:completion];
	} else {
		animations();
		completion(YES);
	}
}

@end
