//
//  GYArticleCell.m
//  gyazz4iOS
//
//  Created by 博紀 秋山 on 12/05/01.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GYArticleCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation GYArticleCell

@synthesize webView = _webView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		// Initialization code
		_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		[_webView.scrollView setBounces:NO];
		[_webView.scrollView setScrollEnabled:NO];
		[self.contentView addSubview:_webView];
	}
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[_webView setFrame:self.bounds];
//	[self.textLabel setFrame:CGRectMake(0, 0, 80, 80)];
//	[self.textLabel.layer setBorderColor:[UIColor redColor].CGColor];
//	[self.textLabel.layer setBorderWidth:2.0f];
}

- (void)dealloc {
	[_webView release];
	[super dealloc];
}
@end
