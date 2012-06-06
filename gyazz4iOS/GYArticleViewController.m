//
//  GYArticleViewController.m
//  gyazz4iOS
//
//  Created by 博紀 秋山 on 12/05/01.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GYArticleViewController.h"
#import "ASIHTTPRequest.h"

#import "GYArticleCell.h"

@interface GYArticleViewController ()
@property (retain, nonatomic) NSMutableArray *list;
@property (retain, nonatomic) NSMutableDictionary *heights;
- (void)reload;
@end

@implementation GYArticleViewController {
	int _loadingCounter;
}
@synthesize tableView = _tableView;
@synthesize gyazzTitle = _gyazzTitle;
@synthesize gyazzUrl = _gyazzUrl;
@synthesize list = _list;
@synthesize heights = _heights;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.heights = [NSMutableDictionary dictionary];
		_loadingCounter = 0;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	[self.tableView setRowHeight:0];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone]; 
}

- (void)viewDidUnload
{
	[self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self reload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	[_tableView release];
	[_gyazzTitle release];
	[_gyazzUrl release];
	
	[_list release];
	[_heights release];
	
	[super dealloc];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSNumber *height = [_heights objectForKey:[NSNumber numberWithInt:indexPath.row]];
	if (height) {
		NSLog(@"at %d, %f", indexPath.row, [height floatValue]);
		return [height floatValue];
	} else {
		return 0;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    GYArticleCell *cell = (GYArticleCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GYArticleCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		NSString *path = [[NSBundle mainBundle] pathForResource:@"gyazz" ofType:@"html"];
		[cell.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
		[cell.webView setDelegate:self];
    }
	
	[cell.webView setTag:indexPath.row];
	NSString *str = [_list objectAtIndex:indexPath.row];
	NSString *result = [cell.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setGyazzText('http://Gyazz.com','%@','%@');", _gyazzTitle, str]];
	NSLog(@"result:\n%@",result);
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}


- (void)reload {
	NSString *urlString = [NSString stringWithFormat:@"http://gyazz.com/%@/text", [self.gyazzUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSURL *url = [NSURL URLWithString:urlString];
	NSLog(@"%@",urlString);
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setCompletionBlock:^{
//		NSLog(@"%@",[request responseString]);
		self.list = [NSMutableArray arrayWithArray:[[request responseString] componentsSeparatedByString:@"\n"]];
//		NSLog(@"%@",[_list objectAtIndex:0]);
		[self.tableView reloadData];
	}];
	[request setFailedBlock:^{
		NSLog(@"%@",[[request error] debugDescription]);
	}];
	[request startAsynchronous];
}

#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *url = [[request URL] absoluteString];
	NSArray *componets = [url componentsSeparatedByString:@":"];
	if ([componets count] > 1) {
		NSString *protocol = [componets objectAtIndex:0];
		if ([protocol isEqualToString:@"file"]) {
			return YES;
		} else if (([protocol isEqualToString:@"gyazz4ios"])) {
			// gyazz4iOS用のコマンド
			if ([[componets objectAtIndex:1] isEqualToString:@"height"]) {
				int height = [[componets objectAtIndex:2] intValue];
				NSLog(@"height: %d",height);
				[_heights setObject:[NSNumber numberWithInt:height] forKey:[NSNumber numberWithInt:webView.tag]];
				[self.tableView reloadData];
			} else if ([[componets objectAtIndex:1] isEqualToString:@"console"]) {
				NSLog(@"console:\n%@",
					  [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
			} else {
				NSLog(@"command: %@", url);
			}
		} else if ([url rangeOfString:@"^http://gyazz.com/.*" options:NSRegularExpressionSearch].location != NSNotFound) {
			// gyazz内部のURL
			NSLog(@"gyazz: %@", url);
		} else {
			// 普通のURL
			NSLog(@"url: %@", url);
		}
	}
	return NO;
}

//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//	[self.tableView reloadData];
//}

@end
