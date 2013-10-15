//
//  EndPageMoreAppsViewController.m
//  Angelina-New-Teacher-Universal
//
//  Created by Martin Kamara on 2011-11-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EndPageMoreAppsViewController.h"
#import "Angelina_AppDelegate.h"
#import "MAZeroingWeakRef.h"
#import "cdaXSellService.h"
#import "cdaXSellApp.h"
#import "cdaXSellAppSection.h"
#import "cdaXSellAppLink.h"
#import "cdaXSellEndTableCell.h"
#import "cdaAnalytics.h"
#import "NetworkUtils.h"
#import "MoreAppsSectionLabel.h"
#import "MoreAppsAppView.h"
#import "cdaGlobalFunctions.h"

#define SCROLLVIEW_APP_PADDING 98

@implementation EndPageMoreAppsViewController
@synthesize noConnectionImage;
@synthesize xSellActivityIndicator;
@synthesize xSellApps = _xSellApps;
@synthesize willOpenUrl = _willOpenUrl;
@synthesize fadeView;
@synthesize xSellTableView;
@synthesize xSellScrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

    //set gradient fade on fade view
    fadeView.layer.mask = [cdaGlobalFunctions createGradientFadeLayerMask:CGRectMake(0, 0, fadeView.frame.size.width, fadeView.frame.size.height) withTopFade:20 withBottomFade:45];

    [self reloadXSell];

    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setNoConnectionImage:nil];
    [self setXSellActivityIndicator:nil];
    [self setXSellTableView:nil];
    [self setXSellScrollView:nil];
    [self setFadeView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void) resetScroll {
    [xSellScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [xSellTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

-(void)reloadXSell {
    noConnectionImage.hidden = YES;

    [xSellActivityIndicator setHidden:NO];
    [xSellActivityIndicator startAnimating];
    // Blocks retain objects used inside, and if 'self' is used then it is a cricular dependency. 
    // Problem and solution discussed here; http://stackoverflow.com/questions/5525567/ios-4-blocks-and-retain-counts
    // Setup weak references for use in block below.
    MAZeroingWeakRef *blockSelf = [MAZeroingWeakRef refWithTarget:self];
    MAZeroingWeakRef *blockNoConnectionImage = [MAZeroingWeakRef refWithTarget:noConnectionImage];
    [[cdaXSellService sharedInstance] xsellAppsForAppWithKey:@"3af1946a-354d-4305-8f7b-096a9ee4c12b" filterByPlatform:cdaXSellDeviceTypeAll onSuccess:^(NSArray *xsellApps) {
        [blockSelf.target setXSellApps:xsellApps];
        [blockSelf.target xSellDidReload];
    } onError:^(NSError *error) {
        [blockNoConnectionImage.target setHidden:NO];
        [blockSelf.target xSellDidReload];
    }];
}

-(void) xSellDidReload {
    [xSellActivityIndicator stopAnimating];
    [xSellActivityIndicator setHidden:YES];
    
    if (self.xSellScrollView != nil) {
        [self setScrollView];
    }
}

- (IBAction)backButtonAction:(id)sender {
    [[[Angelina_AppDelegate get] currentRootViewController] hideMoreApps];
}

- (IBAction)giftButtonAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"Gift This App" inCategory:@"End Page: More Apps" withLabel:@"tap" andValue:-1];
    
    self.willOpenUrl = [NSURL URLWithString:@"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/giftSongsWizard?gift=1&salableAdamId=441834607&productType=C&pricingParameter=STDQ"];
    
    [self showLeavingAppAlert];
}

//leaving app or no network dialogue
- (void)showLeavingAppAlert
{
    CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
    alert.delegate = self;
    
    if (![NetworkUtils connectedToNetwork]) {
        [alert show:[self.view superview] alertType:CAVCNoNetwork];
    }
    else {
        [alert show:[self.view superview] alertType:CAVCLeaveAppAppStore];
    }
    
    [alert release];
}

- (void) CustomAlertViewController:(CustomAlertViewController *)alert wasDismissedWithValue:(NSInteger)dismissedValue {
    
    if(dismissedValue == CAVCButtonTagOk) {
        [[cdaAnalytics sharedInstance] trackEvent:@"Yes" inCategory:@"Leaving App Dialogue" withLabel:@"tap" andValue:-1];
        [self openUrl:self.willOpenUrl];
    }
    else {
        [[cdaAnalytics sharedInstance] trackEvent:@"No" inCategory:@"Leaving App Dialogue" withLabel:@"tap" andValue:-1];
    }
    
    self.willOpenUrl = nil;
}

- (void)openUrl:(NSURL *)url {
    //goto the url
    [[UIApplication sharedApplication] openURL:url];
}

-(void)setScrollView {
    //rearrage the apps in two columns for the scrollview
    /*
    for (cdaXSellAppSection* section in self.xSellApps) {
        NSMutableArray *column1 = [[NSMutableArray alloc] init];
        NSMutableArray *column2 = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [section.apps count]; i++) {
            if (i % 2 == 0) {
                [column1 addObject:[section.apps objectAtIndex:i]];
            }
            else {
                [column2 addObject:[section.apps objectAtIndex:i]];
            }
        }
        //divide array into columns
        [column1 addObjectsFromArray:column2];
        section.apps = column1;
        
        [column1 release];
        [column2 release];
    }*/
    
    float xStartPosition = 0;
    
    float xPosition;
    float yPosition = 0;
    for (cdaXSellAppSection* section in self.xSellApps) {
        xPosition = xStartPosition;
        float maxAppHeight; // keep track of app heights
        
        //add section header
        /*float sectionLabelHeight = 30;
        MoreAppsSectionLabel *sectionLabel = [[MoreAppsSectionLabel alloc]initWithFrame:CGRectMake(xPosition, yPosition, self.xSellScrollView.frame.size.width, sectionLabelHeight)];
        sectionLabel.text = [section.name uppercaseString];
        sectionLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:19];
        sectionLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:157.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
        [self.xSellScrollView addSubview:sectionLabel];
        yPosition += sectionLabelHeight+40; //height plus margin
        [sectionLabel release];*/
        
        for (int i = 0; i < [section.apps count]; i++) {
            cdaXSellApp* app = [section.apps objectAtIndex:i];
            
            MoreAppsAppView *appView = [[[MoreAppsAppView alloc] initWithFrame:CGRectMake(xPosition, yPosition, 373, 200)] autorelease];
            appView.sectionName = section.name;
            [appView setAppValues:app];
            //XXX-mk change this. Create button here
            appView.containerView = self;
            [self.xSellScrollView addSubview:appView];
            
            float height = [appView sizeContentToFit];
            if (height > maxAppHeight) {
                maxAppHeight = height;
            }
            
            xPosition += appView.bounds.size.width+SCROLLVIEW_APP_PADDING;
            
            // when new row of no more apps in the section
            if (i == ([section.apps count]-1)) {
                xPosition = xStartPosition;
                yPosition = yPosition+maxAppHeight+23;
            }
            else if (i % 2 != 0) {
                xPosition = xStartPosition;
                yPosition = yPosition+maxAppHeight+40;
            }
            
        }
    }
    [self.xSellScrollView setContentSize:CGSizeMake(xSellScrollView.frame.size.width, yPosition)];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.xSellApps count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    cdaXSellAppSection* appSection = [self.xSellApps objectAtIndex:section];
    return [appSection.apps count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    cdaXSellAppSection* appSection = [self.xSellApps objectAtIndex:section];
    return appSection.name;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    //XXX-mk temp return to not show header for section view
    return [[[UIView alloc]init]autorelease];
    
    cdaXSellAppSection* appSection = [self.xSellApps objectAtIndex:section];
    float sectionLabelHeight = 30;
    float sectionMarginTop = 15;
    
    //add it to a holder view for margin on the section label
    UIView *holder = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, sectionLabelHeight+sectionMarginTop)] autorelease];
    holder.backgroundColor = [UIColor whiteColor];
    
    //add section header
    MoreAppsSectionLabel *sectionLabel = [[MoreAppsSectionLabel alloc]initWithFrame:CGRectMake(0, sectionMarginTop, holder.frame.size.width, sectionLabelHeight)];
    sectionLabel.text = [appSection.name uppercaseString];
    sectionLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:17];
    sectionLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:157.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
    
    [holder addSubview:sectionLabel];
    [sectionLabel release];
    
    return holder;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //XXX-mk temp return to not show header for section view
    return 16;
    
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    cdaXSellEndTableCell *cell = [[[cdaXSellEndTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    
    cdaXSellAppSection* section = [self.xSellApps objectAtIndex:indexPath.section];
    cdaXSellApp* app = (cdaXSellApp*)[section.apps objectAtIndex:indexPath.row];
    
    [cell setAppValues:app forTable:tableView];
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    cdaXSellEndTableCell *cell = (cdaXSellEndTableCell *) [tableView cellForRowAtIndexPath:indexPath];
    
    //Flurry    
    [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"X Sell Object tap: %@", cell.headerLabel.text] inCategory:@"End Page: More Apps" withLabel:@"title" andValue:-1];
    
    self.willOpenUrl = cell.appURL;
    
    [self showLeavingAppAlert];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //pretty overkill way of getting
    cdaXSellEndTableCell *cell = [[[cdaXSellEndTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    
    cdaXSellAppSection* section = [self.xSellApps objectAtIndex:indexPath.section];
    cdaXSellApp* app = (cdaXSellApp*)[section.apps objectAtIndex:indexPath.row];
    
    [cell setAppValues:app forTable:tableView];
    
    CGFloat size = [cell sizeContentToFit];
    
    return size;
}


- (void)dealloc {
    [noConnectionImage release];
    [xSellActivityIndicator release];
    
    self.xSellApps = nil;
    self.willOpenUrl = nil;
    
    [xSellTableView release];
    [xSellScrollView release];
    [fadeView release];
    [super dealloc];
}
@end
