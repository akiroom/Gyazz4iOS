//
//  GYArticleListViewController.m
//  gyazz4iOS
//
//  Created by 博紀 秋山 on 12/05/01.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GYArticleListViewController.h"
#import <SBJson/SBJson.h>
#import "ASIHTTPRequest.h"
#import "EGORefreshTableHeaderView.h"
#import "GYArticleViewController.h"

@interface GYArticleListViewController()
@property (retain, nonatomic) EGORefreshTableHeaderView *refreshHeaderView;
@property (retain, nonatomic) NSDate *lastDate;
- (void)reload;
- (void)doneLoadingTableViewData;
@end

@implementation GYArticleListViewController {
	BOOL _reloading;
}

@synthesize list = _list;
@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize lastDate = _lastDate;

- (id)init {
	if (self = [super initWithStyle:UITableViewStylePlain]) {
		
	}
	return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
//*/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[_list release];
	[_lastDate release];
	[_refreshHeaderView release];
	[super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	if (_refreshHeaderView == nil) {
		
		self.refreshHeaderView = [[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height) arrowImageName:@"grayArrow" textColor:[UIColor darkGrayColor]] autorelease];
		[_refreshHeaderView setDelegate:self];
		[self.tableView addSubview:_refreshHeaderView];
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self reload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    // Configure the cell...
	NSArray *article = [_list objectAtIndex:indexPath.row];
	[cell.textLabel setText:[article objectAtIndex:0]];
	
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[article objectAtIndex:1] intValue]];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setLocale:[NSLocale currentLocale]];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	[cell.detailTextLabel setText:[dateFormatter stringFromDate:date]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *article = [_list objectAtIndex:indexPath.row];
	GYArticleViewController *articleViewCon = [[[GYArticleViewController alloc] initWithNibName:@"GYArticleViewController" bundle:nil] autorelease];
	[articleViewCon setGyazzTitle:self.title];
	[articleViewCon setTitle:[article objectAtIndex:0]];
	[articleViewCon setGyazzUrl:[article objectAtIndex:2]];
	[self.navigationController pushViewController:articleViewCon animated:YES];
}


#pragma mark - Network

- (void)reload {
	NSString *siteOption = @"__list";
	NSString *urlString = [NSString stringWithFormat:@"http://gyazz.com/%@/%@", [self.title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], siteOption];
	NSURL *url = [NSURL URLWithString:urlString];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setCompletionBlock:^{
		SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
		self.list = [parser objectWithString:[request responseString]];
		if ([_list count] > 0) {
			NSLog(@"%d",[[[_list objectAtIndex:0] objectAtIndex:1] intValue]);
			self.lastDate = [NSDate dateWithTimeIntervalSince1970:[[[_list objectAtIndex:0] objectAtIndex:1] intValue]];
		}
		[self.tableView reloadData];
		[self doneLoadingTableViewData];
	}];
	[request setFailedBlock:^{
		NSLog(@"%@",[[request error] debugDescription]);
		[self doneLoadingTableViewData];
	}];
	[request startAsynchronous];
	/*NSError *error = [request error];
	 if (!error) {
	 NSString *response = [request responseString];
	 }//*/
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
}

- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	[self reload];
//	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return _lastDate; // should return date data source was last changed
	
}

@end
