    //
//  InfoPopoverController.mm
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 12/2/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "InfoPopoverController.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>
#include "Angelina_AppDelegate.h"
#include "cdaAnalytics.h"
#import "cdaConstantContactCollectionService.h"
#import "Reachability.h"

@interface InfoPopoverController (PrivateMethods)
-(void) showAlert:(NSString*)title message:(NSString*)message;
-(void)launchMailAppOnDevice;
-(void)displayComposerSheet;
- (BOOL)connectedToNetwork;
@end

@implementation InfoPopoverController

@synthesize willOpenUrl = _willOpenUrl;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	scroller.contentSize=CGSizeMake(452, 2008-60);
    scrollerRight.contentSize=CGSizeMake(389, 1170+80);
    NSString *infopath = [Angelina_AppDelegate getLocalizedAssetName:@"info_text.png"];
	info = [UIImage imageNamed:infopath];
	//info_uk = [UIImage imageNamed:@"info_text_uk.png"];
    /*
	Angelina_AppDelegate *appDelegate = (Angelina_AppDelegate *)[[UIApplication sharedApplication] delegate];
	if ([[appDelegate getCurrentLanguage] isEqualToString:@"en_GB"]) {
		infotext.image = info_uk;
	} else {
		infotext.image = info;
	}
     */
    infotext.image = info;
    scroller.target=self;
    scroller.selector=@selector(hideKeyboard);
    scroller.delegate=self;
    
    scrollerRight.target=self;
    scrollerRight.selector=@selector(hideKeyboard);
    scrollerRight.delegate=self;
    
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
	versionLabel.text = [NSString stringWithFormat:@"Angelina Ballerina's New Teacher: Version %@", [bundleInfo objectForKey:@"CFBundleVersion"]];
    [versionLabel setFont:[UIFont fontWithName:@"MuseoSlab-500" size:16]];
    [versionLabel setTextColor:[UIColor colorWithRed:0.345 green:0.227 blue:0 alpha:1]];
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self hideKeyboard];
}
-(void)hideKeyboard{
    [emailTextField resignFirstResponder];
}
- (IBAction)show:(UIView*)starter {
    [self retain];
    
    [starter addSubview:self.view];
    [starter bringSubviewToFront:self.view];
    
    self.view.alpha = 0.0;
    [UIView animateWithDuration:0.2
                          delay:0.2
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.view.alpha = 1.0;
                     }
                     completion:nil];
}

-(IBAction) emailSupport:(id)sender {
	if ([MFMailComposeViewController canSendMail]) {
		[self displayComposerSheet];
	} else {
		NSString *title = @"Sorry!";
		NSString *message = @"You need to have an email account set up on your device in order to send an email from it.";
		[self showAlert:title message:message];
	}

}

-(IBAction) close:(id)sender {
    [self.view removeFromSuperview];
    [self autorelease];    
}

#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
	
	if ([self connectedToNetwork] == NO) {
		//no network - no email
		NSString *title = @"Can't send email!";
		NSString *message = @"You need an active internet connection to send your support request. Please make sure you're connected to a network before trying to send your request.";
		[self showAlert:title message:message];
		
		return;
	}
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
		[picker setSubject:[NSString stringWithFormat:@"Angelina's new ballet Teacher v%@ (iPad) Support request",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] ]];
	
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"support@callaway.com"];
	
	[picker setToRecipients:toRecipients];
	
	// Fill out the email body text
	NSString *emailBody = @"";
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
    [picker release];
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
-(void) showAlert:(NSString*)title message:(NSString*)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}

#pragma mark -
#pragma mark Workaround

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
    [[cdaAnalytics sharedInstance] trackEvent:@"INFO support email"];
    [[cdaAnalytics sharedInstance] trackEvent:@"INFO support email"];
    
	NSString *recipients = [NSString stringWithFormat:@"mailto:support@callaway.com&subject=Angelina's new ballet Teacher v%@ Support request",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	NSString *body = @"&body=";
	
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}
#pragma mark -
#pragma mark GET APP FROM APPSTORE
- (void)showLeavingAppAlert
{
    CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
    alert.delegate = self;
    [alert show:self.view alertType:[self connectedToNetwork] ? CAVCLeaveAppWebsite : CAVCNoNetwork];
    [alert release];	
}

-(IBAction) getAppFromAppstore:(id)sender {

    int tag = [(UIButton *)sender tag];
    NSLog(@"This is the app we're getting: %i", tag);

    
    [[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"INFO app store for App: %d", tag]];
    
    if (tag == 1) {
        //Get Misty Island
        self.willOpenUrl = [NSURL URLWithString:@"http://click.linksynergy.com/fs-bin/click?id=4omJ4S6Jomw&offerid=146261.408089724&type=2&subid=0"];
    }
    else if (tag == 2) {
        //Hero
        self.willOpenUrl = [NSURL URLWithString:@"http://click.linksynergy.com/fs-bin/click?id=4omJ4S6Jomw&offerid=146261.436522852&type=2&subid=0"];
    }
    [self showLeavingAppAlert];
}

- (void)CustomAlertViewController:(CustomAlertViewController *)alert wasDismissedWithValue:(NSInteger)value
{
    if (alert.alertType == CAVCLeaveAppWebsite) {
        if (value == CAVCButtonTagOk) {
            [[UIApplication sharedApplication] openURL:self.willOpenUrl];
        }
    }
    self.willOpenUrl = nil;
}

- (IBAction)subscribeAction:(id)sender {
     [self hideKeyboard];
    
    NSString *emailAddress=emailTextField.text;
    if (![emailAddress length]) return;
    
    Reachability * r=[Reachability reachabilityForInternetConnection];
    if ([r currentReachabilityStatus]==NotReachable) {
        CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
        alert.delegate = nil;
        [alert show:self.view alertType:CAVCNoNetwork];
        [alert release];
        return;
    }
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^(?i)([A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4})$"];
    if(![regExPredicate evaluateWithObject:emailAddress]){
    
        
        CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
        alert.delegate = nil;
        [alert show:self.view alertType:CAVCBadEmailAddress];
        [alert release];
        
        
        return;
    }
    
    
    
    self.view.userInteractionEnabled=FALSE;
    cdaContact* contact = [[cdaContact new] autorelease];
    contact.emailAddress = emailAddress;
    contact.brand = cdaBrandAngelina;
    contact.appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    contact.appCategory = cdaAppCategoryKids;
    NSArray* listIds = [NSArray arrayWithObject:[NSNumber numberWithInt:1]];
    
    CGSize viewSize=CGSizeMake(100, 80);
    UIView * indicatorParent=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-viewSize.width/2, self.view.frame.size.height/2-viewSize.height/2, viewSize.width, viewSize.height)];
    indicatorParent.backgroundColor=[UIColor colorWithWhite:0 alpha:.6];
    indicatorParent.layer.cornerRadius=9;
    [self.view addSubview:indicatorParent];
    UIActivityIndicatorView *spinner=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center=CGPointMake(viewSize.width/2,viewSize.height/2);
    [indicatorParent addSubview:spinner];
    [spinner startAnimating];
    [spinner release];
    [indicatorParent release];
    
                              
                               
    
    [[cdaConstantContactCollectionService sharedInstance] 
     collectContact:contact 
     addToLists:listIds 
     withOptInSource:cdaOptInSource_REQUESTED_BY_CONTACT 
     onSuccess:^(int statusCode, NSDictionary *headers, NSData* data) {
         self.view.userInteractionEnabled=TRUE;
         [indicatorParent removeFromSuperview];
         

         CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
         alert.delegate = nil;
         [alert show:self.view alertType:CAVCSubscribeSuccess];
         [alert release];
         
     }
     onFailure:^(NSError* error) {
        
         
         self.view.userInteractionEnabled=TRUE;
         [indicatorParent removeFromSuperview];
         
         CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
         alert.delegate = nil;
         [alert show:self.view alertType:CAVCSubscribeError];
         [alert release];
     }];

}

- (IBAction)facebookAction:(id)sender {
     [self hideKeyboard];
    self.willOpenUrl = [NSURL URLWithString:@"http://www.facebook.com/angelinaballerina"];
    [self showLeavingAppAlert];
}

- (IBAction)twitterAction:(id)sender {
     [self hideKeyboard];
    self.willOpenUrl = [NSURL URLWithString:@"http://twitter.com/#!/callawaydigital"];
    [self showLeavingAppAlert];
}

- (IBAction)giftAction:(id)sender {
     [self hideKeyboard];
    self.willOpenUrl = [NSURL URLWithString:@"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/giftSongsWizard?gift=1&salableAdamId=441834607&productType=C&pricingParameter=STDQ"];
    [self showLeavingAppAlert];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
 [self hideKeyboard];
}

#pragma mark -
#pragma mark Check for Internet Connection
- (BOOL) connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return 0;
    }
	
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}
#pragma mark -
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [emailTextField release];
    emailTextField = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
	[scroller release];
    [scrollerRight release];
	[infotext release];
    [emailTextField release];
    self.willOpenUrl = nil;
    [super dealloc];
}

#pragma mark TextField delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self performSelector:@selector(subscribeAction:) withObject:nil afterDelay:.3];
    return YES;
}
@end
