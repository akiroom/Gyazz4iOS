//
//  GYArticleViewController.h
//  gyazz4iOS
//
//  Created by 博紀 秋山 on 12/05/01.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GYArticleViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSString *gyazzTitle;
@property (retain, nonatomic) NSString *gyazzUrl;
@end
