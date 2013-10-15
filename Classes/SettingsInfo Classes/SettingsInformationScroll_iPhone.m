//
//  SettingsInformationScroll_iPhone.m
//  ThomasSettings
//
//  Created by Radif Sharafullin on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsInformationScroll_iPhone.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>
#import "cdaAffiliateLink.h"
#import "ModalAlert.h"
@interface SettingsInformationScroll_iPhone (topSecret)
- (BOOL) connectedToNetwork;
-(void) showAlert:(NSString*)title message:(NSString*)message;
-(void)displayComposerSheet;
@end

@implementation SettingsInformationScroll_iPhone
@synthesize imgView, vc;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		UIView *rule=[[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 1)] autorelease];
		rule.backgroundColor=[UIColor colorWithRed:84.0f/255.0f green:188.0f/255.0f blue:275.0f/255.0f alpha:1.0f];
		[rule setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		[self addSubview:rule];
		
		sv=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 1, self.frame.size.width, self.frame.size.height-1)];
		sv.showsVerticalScrollIndicator=NO;
		sv.showsHorizontalScrollIndicator=NO;
		
		imgView=[[UIImageView alloc]initWithFrame:sv.bounds];
		[sv addSubview:imgView];
		[self addSubview:sv];
		
		UIImageView *fade=[[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bottomFadeSettigns.png"]]autorelease];
		fade.frame=CGRectMake(0, self.frame.size.height-fade.frame.size.height, self.frame.size.width, fade.frame.size.height);
		fade.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
		[self addSubview:fade];
		
		
    }
    return self;
}
-(void)addEmailButton{
	UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
	button.frame=CGRectMake(5, 1809, 222, 25);
	button.showsTouchWhenHighlighted=YES;
	[button addTarget:self action:@selector(sendEmail) forControlEvents:UIControlEventTouchUpInside];
	[imgView addSubview:button];
	imgView.userInteractionEnabled=YES;
}
-(void)addMoreAppsButton{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
	button.frame=CGRectMake(94,538, 136, 25);
	button.showsTouchWhenHighlighted=YES;
	[button addTarget:self action:@selector(moreAppsPressed) forControlEvents:UIControlEventTouchUpInside];
	[imgView addSubview:button];
	imgView.userInteractionEnabled=YES;
	//button on icon
    UIButton *button_icon=[UIButton buttonWithType:UIButtonTypeCustom];
	button_icon.frame=CGRectMake(7, 94, 76, 76);
	button_icon.showsTouchWhenHighlighted=YES;
	[button_icon addTarget:self action:@selector(moreAppsPressed) forControlEvents:UIControlEventTouchUpInside];
	[imgView addSubview:button_icon];
}

-(void)setContentsImage:(UIImage *)contents{

	imgView.frame=CGRectMake(0, 0, contents.size.width, contents.size.height);
	imgView.image=contents;
	sv.contentSize=CGSizeMake(contents.size.width, contents.size.height);
}

- (void)dealloc {
	[sv release];
	[imgView release];
    [super dealloc];
}


-(void)sendEmail{
	if ([MFMailComposeViewController canSendMail]) {
		[self displayComposerSheet];
	} else {
		NSString *title = @"Sorry!";
		NSString *message = @"You need to have an email account set up on your device in order to send an email from it.";
		[self showAlert:title message:message];
	}
}
-(void)moreAppsPressed{
    if([ModalAlert ask:@"You are about to launch the Appstore. Are you sure you want to continue?" withTitle:@"Open Appstore" withCancel:@"NO" withButtons:[NSArray arrayWithObject:@"YES"]])
        [cdaAffiliateLink launchAffiliateLink:@"http://click.linksynergy.com/fs-bin/click?id=4omJ4S6Jomw&offerid=146261.408089724&type=2&subid=0"];    
}	
-(void)displayComposerSheet{
	
	if ([self connectedToNetwork] == NO) {
		//no network - no email
		NSString *title = @"Can't send email!";
		NSString *message = @"You need an active internet connection to send your support request. Please make sure you're connected to a network before trying to send your request.";
		[self showAlert:title message:message];
		
		return;
	}
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:[NSString stringWithFormat:@"Thomas Misty Island Resque v%@ (iPhone) Support request",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] ]];
	
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"support@callaway.com"];
	
	[picker setToRecipients:toRecipients];
	
	// Fill out the email body text
	NSString *emailBody = @"";
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self.vc presentModalViewController:picker animated:YES];
    [picker release];
}
-(void) showAlert:(NSString*)title message:(NSString*)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}
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
	[self.vc dismissModalViewControllerAnimated:YES];
}
@end
