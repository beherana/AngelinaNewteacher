//
//  LandingPageTabsViewController.m
//  Misty-Island-Rescue-Universal
//
//  Created by Karl Söderström on 2011-08-04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BubblePopLandingPageTabsViewController.h"
#import "NetworkUtils.h"
#import "cdaXSellService.h"
#import "cdaXSellApp.h"
#import "cdaXSellAppSection.h"
#import "cdaXSellAppLink.h"
#import "cdaXSellMyUITableViewCell.h"
#import "cdaAnalytics.h"

@implementation BubblePopLandingPageTabsViewController

@synthesize willOpenUrl = _willOpenUrl;
@synthesize delegate, xSellApps, xSellActivityIndicator;
@synthesize mailComposerController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

//append the current version numnber to infoScrollView
-(void) addVersionLabelToFollowView {
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    UILabel *versionLabel = [[UILabel alloc] init];
	versionLabel.text = [NSString stringWithFormat:@"Angelina Ballerina's Bubble Pop! Version %@", [bundleInfo objectForKey:@"CFBundleVersion"]];
    [versionLabel setFont:[UIFont fontWithName:@"MuseoSlab-500" size:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 14 : 16)]];
    [versionLabel setTextColor:[UIColor colorWithRed:0.345 green:0.227 blue:0 alpha:1]];
    CGSize versionLabelSize = [versionLabel.text sizeWithFont:versionLabel.font constrainedToSize:infoScrollView.frame.size lineBreakMode:versionLabel.lineBreakMode];
    versionLabel.contentMode = UIViewContentModeBottomLeft;
    
    //append label to scrollview
    versionLabel.frame = CGRectMake(((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 1 : 3), infoScrollView.contentSize.height+12, versionLabelSize.width, versionLabelSize.height);    
    //get current scroll view size and extend it
    CGSize scrollViewSize = infoScrollView.contentSize;
    //extend content size for scroll view
    scrollViewSize.height += versionLabel.frame.size.height+12;
    infoScrollView.contentSize = scrollViewSize;
    
    [infoScrollView addSubview:versionLabel];
    
    [versionLabel release];
}

- (void)resetTabs {
    
    if (tabShown == BubblePopLandingPage_TabShown_MoreApps) {
        [[cdaAnalytics sharedInstance] trackEvent:@"close" inCategory:flurryEventPrefix(@"Landing Page: More Apps Drawer") withLabel:@"tap" andValue:-1];
    }
    else if (tabShown == BubblePopLandingPage_TabShown_Info) {
        [[cdaAnalytics sharedInstance] trackEvent:@"close" inCategory:flurryEventPrefix(@"Landing Page: Info Drawer") withLabel:@"tap" andValue:-1];
    }
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         overlay.alpha = 0.0;
                         CGRect frame = infoTab.frame;
                         frame.origin.x = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 451 : 981;
                         infoTab.frame = frame;
                         frame = moreAppsTab.frame;
                         frame.origin.x = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 451 : 980;
                         moreAppsTab.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         overlay.hidden = YES;
                         
                         [[self delegate] tabDismissed];
                         [self.view removeFromSuperview];
                     }];
    
    tabShown = BubblePopLandingPage_TabShown_None;
    
}

- (IBAction)btnInfoTabAction:(id)sender {
    if (tabShown == BubblePopLandingPage_TabShown_None) {
        overlay.alpha = 0.0;
        overlay.hidden = NO;

        [UIView animateWithDuration:0.3
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             overlay.alpha = 0.4;
                             //put the pressed tab on to of the other
                             [self.view bringSubviewToFront:infoTab];
                             CGRect frame = infoTab.frame;
                             frame.origin.x = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? -34 : 528;
                             infoTab.frame = frame;
                         }
                         completion:nil];
        tabShown = BubblePopLandingPage_TabShown_Info;
    } else {
        [self resetTabs];
    }
}

- (IBAction)btnMoreAppsTabAction:(id)sender {
    if (tabShown == BubblePopLandingPage_TabShown_None) {

        //populate cross sell

        overlay.alpha = 0.0;
        overlay.hidden = NO;

        [UIView animateWithDuration:0.3
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             overlay.alpha = 0.4;
                             //put the pressed tab on to of the other
                             [self.view bringSubviewToFront:moreAppsTab];
                             CGRect frame = moreAppsTab.frame;
                             frame.origin.x = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? -35 : 397;
                             moreAppsTab.frame = frame;
                         }
                         completion:nil];
        tabShown = BubblePopLandingPage_TabShown_MoreApps;
    } else {
        [self resetTabs];
    }
}

//leaving app or no network dialogue
- (void)showLeavingAppAlert
{
    BubblePopCustomAlertViewController *alert = [[BubblePopCustomAlertViewController alloc]init];
    alert.delegate = self;

    if (![NetworkUtils connectedToNetwork]) {
        [alert show:[self.view superview] alertType:BubblePopCAVCNoNetwork];
    }
    else {
        [alert show:[self.view superview] alertType:BubblePopCAVCLeaveApp];
    }

    [alert release];
}

- (void) CustomAlertViewController:(BubblePopCustomAlertViewController *)alert wasDismissedWithValue:(NSInteger)dismissedValue {
    
    if(dismissedValue == BubblePopCAVCButtonTagOk) {
        [[cdaAnalytics sharedInstance] trackEvent:@"Yes" inCategory:flurryEventPrefix(@"Leaving App Dialogue") withLabel:@"tap" andValue:-1];
        [self openUrl:self.willOpenUrl];
    }
    else {
        [[cdaAnalytics sharedInstance] trackEvent:@"No" inCategory:flurryEventPrefix(@"Leaving App Dialogue") withLabel:@"tap" andValue:-1];
    }
    
    self.willOpenUrl = nil;
}

- (void)openUrl:(NSURL *)url {
    //reset state before continuing
    [self resetTabs];
    
    //goto the url
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)btnFacebookAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"Facebook" inCategory:flurryEventPrefix(@"Landing Page: Info Drawer") withLabel:@"tap" andValue:-1];
    
    self.willOpenUrl = [NSURL URLWithString:@"http://www.facebook.com/angelinaballerina"];
    
    [self showLeavingAppAlert];
}

- (IBAction)btnTwitterAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"Twitter" inCategory:flurryEventPrefix(@"Landing Page: Info Drawer") withLabel:@"tap" andValue:-1];

    self.willOpenUrl = [NSURL URLWithString:@"http://twitter.com/#!/callawaydigital"];
    
    [self showLeavingAppAlert];
}

- (IBAction)btnCallawayAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"Callaway Logo" inCategory:flurryEventPrefix(@"Landing Page: Info Drawer") withLabel:@"tap" andValue:-1];
    
    self.willOpenUrl = [NSURL URLWithString:@"http://www.callaway.com"];
    
    [self showLeavingAppAlert];
}

- (IBAction)btnHITAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"HIT Logo" inCategory:flurryEventPrefix(@"Landing Page: Info Drawer") withLabel:@"tap" andValue:-1];
    
    self.willOpenUrl = [NSURL URLWithString:@"http://www.hitentertainment.com"];
    
    [self showLeavingAppAlert];
}

- (IBAction)btnGiftAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"Gift This App" inCategory:flurryEventPrefix(@"Landing Page: More Apps Drawer") withLabel:@"tap" andValue:-1];
    
    self.willOpenUrl = [NSURL URLWithString:@"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/giftSongsWizard?gift=1&salableAdamId=447339169&productType=C&pricingParameter=STDQ"];
    
    [self showLeavingAppAlert];
}

- (IBAction)btnAngelinaOfficialSiteAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"Angelina Official Website" inCategory:flurryEventPrefix(@"Landing Page: More Apps Drawer") withLabel:@"tap" andValue:-1];
    
    self.willOpenUrl = [NSURL URLWithString:@"http://www.angelinaballerina.com"];
    
    [self showLeavingAppAlert];
}

-(IBAction)btnEmailSupport:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"support@callaway.com" inCategory:flurryEventPrefix(@"Landing Page: Info Drawer") withLabel:@"tap" andValue:-1];
    
    //temp disable email support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) return;
    
	if ([MFMailComposeViewController canSendMail]) {
		[self displayComposerSheet];
	} else {
		NSString *title = @"Sorry!";
		NSString *message = @"You need to have an email account set up on your device in order to send an email from it.";
		[self showAlert:title message:message];
	}
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

/* Add titles when we have the design
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    cdaXSellAppSection* appSection = [self.xSellApps objectAtIndex:section];
    return appSection.name;
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    cdaXSellMyUITableViewCell *cell = [[[cdaXSellMyUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    
    cdaXSellAppSection* section = [self.xSellApps objectAtIndex:indexPath.section];
    cdaXSellApp* app = (cdaXSellApp*)[section.apps objectAtIndex:indexPath.row];
    
    [cell setAppValues:app forTable:tableView];
    
    return cell;
}


/* Beginning of custom headers- you can use this as a template /martin
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    cdaXSellAppSection* appSection = [self.xSellApps objectAtIndex:section];

	// create the parent view that will hold header Label
	UIView* customView = [[UIView alloc] init];

    // create the button object
	UILabel * headerLabel = [[UILabel alloc] init];
    headerLabel.text = appSection.name;
    headerLabel.textAlignment = UITextAlignmentLeft;
	headerLabel.font = [UIFont boldSystemFontOfSize:20];
	headerLabel.textColor = [UIColor blackColor];
    headerLabel.lineBreakMode = UILineBreakModeWordWrap;
    headerLabel.numberOfLines = 0;
    
    //size the label to fit the text
    CGSize maximumLabelSize = CGSizeMake(tableView.frame.size.width,9999);    
    CGSize expectedLabelSize = [headerLabel.text sizeWithFont:headerLabel.font 
                                          constrainedToSize:maximumLabelSize 
                                              lineBreakMode:headerLabel.lineBreakMode];
    headerLabel.frame = CGRectMake(headerLabel.frame.origin.x, headerLabel.frame.origin.y, expectedLabelSize.width, expectedLabelSize.height);

    //resize the parent view
    customView.frame = CGRectMake(0, 0, tableView.frame.size.width, headerLabel.frame.size.height);
    
    customView.backgroundColor = [UIColor redColor];
    headerLabel.backgroundColor = [UIColor greenColor];
    
	[customView addSubview:headerLabel];
    
    [headerLabel release];
    
	return customView;
}*/

-(void)reloadXSell {
    noConnectionImage.hidden = YES;

    // createa an activity indicator
    if (self.xSellActivityIndicator == nil) {
        self.xSellActivityIndicator =[[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray] autorelease];
        
        self.xSellActivityIndicator.center = CGPointMake(xSellTableView.frame.size.width/2, xSellTableView.frame.size.height/2);
        
        [xSellTableView addSubview:self.xSellActivityIndicator];
    }
    
    [xSellActivityIndicator startAnimating];
    [[cdaXSellService sharedInstance] xsellAppsForAppWithKey:@"fa096703-d140-46f5-aeb2-ee17907ee0e2" filterByPlatform:cdaXSellDeviceTypeAll onSuccess:^(NSArray *xsellApps) {
        [xSellActivityIndicator stopAnimating];
        self.xSellApps = xsellApps;
        [xSellTableView reloadData];
    } onError:^(NSError *error) {
        [xSellActivityIndicator stopAnimating];
        noConnectionImage.hidden = NO;
        
    }];
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
/* xsell stuff

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    cdaXSellAppSection* section = [xSellApps objectAtIndex:indexPath.section];
    cdaXSellApp* app = (cdaXSellApp*)[section.apps objectAtIndex:indexPath.row];
    cdaXSellAppLink* link = [app.appLinks objectAtIndex:0];
    NSString* url = [link.URL stringByReplacingOccurrencesOfString:@"http://" withString:@"itms://"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
     
}
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    cdaXSellMyUITableViewCell *cell = (cdaXSellMyUITableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    
    //Flurry
    [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"X Sell Object tap %@", cell.headerLabel.text ] inCategory:flurryEventPrefix(@"Landing Page: More Apps Drawer") withLabel:@"title" andValue:-1];

    self.willOpenUrl = cell.appURL;
    
    [self showLeavingAppAlert];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //pretty overkill way of getting
    cdaXSellMyUITableViewCell *cell = [[[cdaXSellMyUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    
    cdaXSellAppSection* section = [self.xSellApps objectAtIndex:indexPath.section];
    cdaXSellApp* app = (cdaXSellApp*)[section.apps objectAtIndex:indexPath.row];
    
    [cell setAppValues:app forTable:tableView];
    
    CGFloat size = [cell sizeContentToFit];
    
    return size;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //display uk info image instead
    /* XXX-mk temp removed
    if ([[[Angelina_AppDelegate get] getCurrentLanguage] isEqualToString:@"en_GB"]) {
        infoImage.image = [UIImage imageNamed:@"instructions_txt_uk.png"];
    }
     */
    
    tabShown = BubblePopLandingPage_TabShown_None;
    
    UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetTabs)] autorelease];
    [overlay addGestureRecognizer:recognizer];
    
    //set the scroll view content size to the image
    infoScrollView.contentSize = infoImage.frame.size;    
    
    
    //Version label - append current version to the scrollview
    [self addVersionLabelToFollowView];
    
    
    infoTab.alpha = 0.0;
    moreAppsTab.alpha = 0.0;
    [UIView animateWithDuration:0.2 animations:^{
        infoTab.alpha = 1.0;
        moreAppsTab.alpha = 1.0;
    }];
    
    xSellTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    

    
    [self reloadXSell];

}

- (void)viewDidUnload {
    [overlay release];
    overlay = nil;
    [infoTab release];
    infoTab = nil;
    [moreAppsTab release];
    moreAppsTab = nil;
    [infoScrollView release];
    infoScrollView = nil;
    [noConnectionImage release];
    noConnectionImage = nil;
    self.xSellApps = nil;
    [self.xSellActivityIndicator removeFromSuperview];
    self.xSellActivityIndicator = nil;
    [xSellTableView release];
    xSellTableView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
	
    //prompt the user if not connected to network
    if (![NetworkUtils connectedToNetwork]) {
        BubblePopCustomAlertViewController *alert = [[BubblePopCustomAlertViewController alloc]init];
        alert.delegate = self;
        [alert show:[self.view superview] alertType:BubblePopCAVCNoNetwork];

        [alert release];	
		
		return;
	}
	
	self.mailComposerController = [[[MFMailComposeViewController alloc] init] autorelease];
	self.mailComposerController.mailComposeDelegate = self;
	
    [self.mailComposerController setSubject:[NSString stringWithFormat:@"Angelina Ballerina's Bubble Pop! v%@ (iPad) Support request",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] ]];
	
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"support@callaway.com"];
	
	[self.mailComposerController setToRecipients:toRecipients];
	
	// Fill out the email body text
	NSString *emailBody = @"";
	[self.mailComposerController setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:self.mailComposerController animated:YES];
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	//message.hidden = NO;
	// Notifies users about errors associated with the interface
	NSString *title = @"";
	NSString *message = @"";
	
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			title = @"Message saved!";
			message = @"Your messade has been saved.";
			[self showAlert:title message:message];
			break;
		case MFMailComposeResultSent:
			title = @"Message sent!";
			message = @"Your support request has been sent. We will get back to you shortly.";
			[self showAlert:title message:message];
			break;
		case MFMailComposeResultFailed:
			title = @"Failed to send!";
			message = @"There was an error. Your email has not been sent.";
			[self showAlert:title message:message];
			break;
		default:
			title = @"Failed to send!";
			message = @"There was an error. Your email has not been sent.";
			[self showAlert:title message:message];
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

//TEMP old alert
-(void) showAlert:(NSString*)title message:(NSString*)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}



- (void)dealloc
{
    [self.mailComposerController dismissModalViewControllerAnimated:NO];
    self.mailComposerController.delegate =nil;
    self.mailComposerController = nil;
    [overlay release];
    [infoTab release];
    [moreAppsTab release];
    [infoScrollView release];
    self.willOpenUrl = nil;
    self.xSellApps = nil;
    self.xSellActivityIndicator = nil;
    [noConnectionImage release];
    self.delegate = nil;
    [xSellTableView release];
    [super dealloc];
}

@end
