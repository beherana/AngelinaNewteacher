//
//  LandingPageTabsViewController.m
//  Misty-Island-Rescue-Universal
//
//  Created by Karl Söderström on 2011-08-04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LandingPageTabsViewController.h"
#import "NetworkUtils.h"
#import "Angelina_AppDelegate.h"
#import "cdaXSellService.h"
#import "cdaXSellApp.h"
#import "cdaXSellAppSection.h"
#import "cdaXSellAppLink.h"
#import "cdaXSellMyUITableViewCell.h"
#import "cdaAnalytics.h"
#import "MAZeroingWeakRef.h"

enum 
{
    kAppStoreLink = 1,
    kWebsiteLink,
};

@implementation LandingPageTabsViewController

@synthesize willOpenUrl = _willOpenUrl;
@synthesize webViewHelper;
@synthesize delegate;
@synthesize xSellApps, xSellActivityIndicator;
@synthesize mailComposerController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //keep the views original frame
        //viewOriginalFrame = CGRectMake(0, 718, 1024, 50);
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

//append the current version numnber to followScrollView
-(void) addVersionLabelToFollowView {
//    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
//    UILabel *versionLabel = [[UILabel alloc] init];
//	versionLabel.text = [NSString stringWithFormat:@"Thomas & Friends Hero of the Rails: Version %@", [bundleInfo objectForKey:@"CFBundleVersion"]];
//    [versionLabel setFont:[UIFont fontWithName:@"Georgia" size:14]];
//    [versionLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
//    CGSize versionLabelSize = [versionLabel.text sizeWithFont:versionLabel.font constrainedToSize:followScrollView.frame.size lineBreakMode:versionLabel.lineBreakMode];
//    versionLabel.contentMode = UIViewContentModeBottomLeft;
//    
//    //append label to scrollview
//    versionLabel.frame = CGRectMake(1, followScrollView.contentSize.height+26, versionLabelSize.width, versionLabelSize.height);    
//    //get current scroll view size and extend it
//    CGSize scrollViewSize = followScrollView.contentSize;
//    //extend content size for scroll view
//    scrollViewSize.height += versionLabel.frame.size.height+26;
//    followScrollView.contentSize = scrollViewSize;
//    
//    [followScrollView addSubview:versionLabel];
//    [versionLabel release];
    
        NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
        UILabel *versionLabel = [[UILabel alloc] init];
        versionLabel.text = [NSString stringWithFormat:@"Angelina Ballerina's New Teacher: Version %@", [bundleInfo objectForKey:@"CFBundleVersion"]];
        [versionLabel setFont:[UIFont fontWithName:@"MuseoSlab-500" size:((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 14 : 16)]];
        [versionLabel setTextColor:[UIColor colorWithRed:0.345 green:0.227 blue:0 alpha:1]];
        CGSize versionLabelSize = [versionLabel.text sizeWithFont:versionLabel.font constrainedToSize:followScrollView.frame.size lineBreakMode:versionLabel.lineBreakMode];
        versionLabel.contentMode = UIViewContentModeBottomLeft;
        
        //append label to scrollview
        versionLabel.frame = CGRectMake(((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 1 : 37), followScrollView.contentSize.height+12, versionLabelSize.width, versionLabelSize.height);    
        //get current scroll view size and extend it
        CGSize scrollViewSize = followScrollView.contentSize;
        //extend content size for scroll view
        scrollViewSize.height += versionLabel.frame.size.height+12;
        followScrollView.contentSize = scrollViewSize;
        
        [followScrollView addSubview:versionLabel];
        
        [versionLabel release];

    
//    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
//	versionLabel.text = [NSString stringWithFormat:@"Angelina Ballerina's New Teacher: Version %@", [bundleInfo objectForKey:@"CFBundleVersion"]];
//    [versionLabel setFont:[UIFont fontWithName:@"MuseoSlab-500" size:16]];
//    [versionLabel setTextColor:[UIColor colorWithRed:0.345 green:0.227 blue:0 alpha:1]];
}

- (void)resetTabs {
    
    if (tabShown == LandingPage_TabShown_MoreApps) {
        [[cdaAnalytics sharedInstance] trackEvent:@"close" inCategory:@"Landing Page: More Apps Drawer" withLabel:@"tap" andValue:-1];
    }
    else if (tabShown == LandingPage_TabShown_Info) {
        [[cdaAnalytics sharedInstance] trackEvent:@"close" inCategory:@"Landing Page: Info Drawer" withLabel:@"tap" andValue:-1];
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
                         //[self.view removeFromSuperview];
                     }];
    
    tabShown = LandingPage_TabShown_None;
    
}

-(void) resetScroll {
    [infoScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [followScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (IBAction)btnInfoTabAction:(id)sender {
    if (tabShown == LandingPage_TabShown_None) {
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
                             frame.origin.x = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? -34 : 11;
                             infoTab.frame = frame;
                         }
                         completion:nil];
        tabShown = LandingPage_TabShown_Info;

        [self resetScroll];
    } else {
        [self resetTabs];
    }
}

- (IBAction)btnInfoShowHelpAction:(id)sender {
    [infoHelpView setHidden:NO];
    [infoInformationView setHidden:YES];
}

- (IBAction)btnInfoShowInformationAction:(id)sender {
    [infoHelpView setHidden:YES];
    [infoInformationView setHidden:NO];
}


- (IBAction)btnMoreAppsTabAction:(id)sender {
    if (tabShown == LandingPage_TabShown_None) {

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
        tabShown = LandingPage_TabShown_MoreApps;
        
        [self resetScroll];
    } else {
        [self resetTabs];
    }
}

//leaving app or no network dialogue
- (void)showLeavingAppAlert:(int) linkType
{
    CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
    alert.delegate = self;

    if (![NetworkUtils connectedToNetwork]) {
        [alert show:[self.view superview] alertType:CAVCNoNetwork];
    }
    else {
        if (linkType == kAppStoreLink) {
            [alert show:[self.view superview] alertType:CAVCLeaveAppAppStore];
        }
        else {
            [alert show:[self.view superview] alertType:CAVCLeaveAppWebsite];
        }
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
    //reset state before continuing
    [self resetTabs];
    
    //goto the url
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)btnFacebookAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"Facebook" inCategory:@"Landing Page: Info Drawer" withLabel:@"tap" andValue:-1];
    
    self.willOpenUrl = [NSURL URLWithString:@"http://www.facebook.com/angelinaballerina"];
    
    [self showLeavingAppAlert:kWebsiteLink];
}

- (IBAction)btnTwitterAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"Twitter" inCategory:@"Landing Page: Info Drawer" withLabel:@"tap" andValue:-1];

    self.willOpenUrl = [NSURL URLWithString:@"http://twitter.com/#!/callawaydigital"];
    
    [self showLeavingAppAlert:kWebsiteLink];
}

- (IBAction)btnAngelinaAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"Callaway Logo" inCategory:@"Landing Page: Info Drawer" withLabel:@"tap" andValue:-1];

    self.willOpenUrl = [NSURL URLWithString:@"http://www.angelinaballerina.com"];

    [self showLeavingAppAlert:kWebsiteLink];
}


- (IBAction)btnCallawayAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"Angelina Official Website Logo" inCategory:@"Landing Page: Info Drawer" withLabel:@"tap" andValue:-1];

    self.willOpenUrl = [NSURL URLWithString:@"http://www.callaway.com"];
    
    [self showLeavingAppAlert:kWebsiteLink];
}

- (IBAction)btnHITAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"HIT Logo" inCategory:@"Landing Page: Info Drawer" withLabel:@"tap" andValue:-1];
    
    self.willOpenUrl = [NSURL URLWithString:@"http://www.hitentertainment.com"];
    
    [self showLeavingAppAlert:kWebsiteLink];
}

- (IBAction)btnGiftAction:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"Gift This App" inCategory:@"Landing Page: More Apps Drawer" withLabel:@"tap" andValue:-1];
    
    self.willOpenUrl = [NSURL URLWithString:@"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/giftSongsWizard?gift=1&salableAdamId=441834607&productType=C&pricingParameter=STDQ"];
    
    [self showLeavingAppAlert:kAppStoreLink];
}

-(IBAction)btnEmailSupport:(id)sender {
    [[cdaAnalytics sharedInstance] trackEvent:@"support@callaway.com" inCategory:@"Landing Page: Info Drawer" withLabel:@"tap" andValue:-1];
    
    //temp disable email support
    //if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) return;
    
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


-(void)reloadXSell {
    noConnectionImage.hidden = YES;

    // createa an activity indicator
    if (self.xSellActivityIndicator == nil) {
        self.xSellActivityIndicator =[[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray] autorelease];
        
        self.xSellActivityIndicator.center = CGPointMake(xSellTableView.frame.size.width/2, xSellTableView.frame.size.height/2);
        
        [xSellTableView addSubview:self.xSellActivityIndicator];
    }
    
    [xSellActivityIndicator startAnimating];
    // Blocks retain objects used inside, and if 'self' is used then it is a cricular dependency. 
    // Problem and solution discussed here; http://stackoverflow.com/questions/5525567/ios-4-blocks-and-retain-counts
    // Setup weak references for use in block below.
    MAZeroingWeakRef *blockXSellActivityIndicator = [MAZeroingWeakRef refWithTarget:xSellActivityIndicator];
    MAZeroingWeakRef *blockXSellTableView = [MAZeroingWeakRef refWithTarget:xSellTableView];
    MAZeroingWeakRef *blockNoConnectionImage = [MAZeroingWeakRef refWithTarget:noConnectionImage];
    MAZeroingWeakRef *blockSelf = [MAZeroingWeakRef refWithTarget:self];
    [[cdaXSellService sharedInstance] xsellAppsForAppWithKey:@"3af1946a-354d-4305-8f7b-096a9ee4c12b" filterByPlatform:cdaXSellDeviceTypeAll onSuccess:^(NSArray *xsellApps) {
        [blockXSellActivityIndicator.target stopAnimating];
        [blockSelf.target setXSellApps:xsellApps];
        [blockXSellTableView.target reloadData];
    } onError:^(NSError *error) {
        [blockXSellActivityIndicator.target stopAnimating];
        [blockNoConnectionImage.target setHidden:NO];
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
    [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"X Sell Object tap: %@", cell.headerLabel.text] inCategory:@"Landing Page: More Apps Drawer" withLabel:@"title" andValue:-1];

    self.willOpenUrl = cell.appURL;
    
    [self showLeavingAppAlert:kAppStoreLink];
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
    if ([[[Angelina_AppDelegate get] getCurrentLanguage] isEqualToString:@"en_GB"]) {
        infoImage.image = [UIImage imageNamed:@"help_text_uk.png"];
    }
    
    tabShown = LandingPage_TabShown_None;
    
    UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetTabs)] autorelease];
    [overlay addGestureRecognizer:recognizer];
    
    //determine the size of the scroll content area
    infoScrollView.contentSize = infoImage.frame.size;
    followScrollView.contentSize = CGSizeMake(followImage.frame.size.width+followImage.frame.origin.x, followImage.frame.size.height+followImage.frame.origin.y);
    
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
    [followScrollView release];
    infoScrollView = nil;
    followScrollView = nil;
    [copyView release];
    copyView = nil;
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
        CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
        alert.delegate = self;
        [alert show:[self.view superview] alertType:CAVCNoNetwork];

        [alert release];	
		
		return;
	}
	
	self.mailComposerController = [[[MFMailComposeViewController alloc] init] autorelease];
	self.mailComposerController.mailComposeDelegate = self;
	
    [self.mailComposerController setSubject:[NSString stringWithFormat:@"Angelina Ballerina's New Teacher v%@ (%@) Support request",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"], (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? @"iPhone" : @"iPad"]];
	
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"support@callaway.com"];
	
	[self.mailComposerController setToRecipients:toRecipients];
	
	// Fill out the email body text
	NSString *emailBody = @"";
	[self.mailComposerController setMessageBody:emailBody isHTML:NO];
	
	[[[Angelina_AppDelegate get] currentRootViewController] presentModalViewController:self.mailComposerController animated:YES];
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
	[[[Angelina_AppDelegate get] currentRootViewController] dismissModalViewControllerAnimated:YES];
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
    [followScrollView release];
    [followImage release];
    [infoImage release];
    [webView release];
    [infoButton release];
    [infoTabCloseButton release];
    [moreAppsButton release];
    [moreAppsTabCloseButton release];
    [infoInformationView release];
    [infoHelpView release];
    
    self.webViewHelper = nil;
    [copyView release];

    self.willOpenUrl = nil;
    self.xSellApps = nil;
    self.xSellActivityIndicator = nil;
    [noConnectionImage release];
    self.delegate = nil;
    [xSellTableView release];
    [super dealloc];
}

@end
