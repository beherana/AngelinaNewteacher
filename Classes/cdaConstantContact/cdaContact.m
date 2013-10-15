//
//  Contact.m
//  KeepInTouchWidgets
//
//  Created by FRANCISCO CANDALIJA on 5/25/11.
//  Copyright 2011 Callaway Digital Arts, Inc. All rights reserved.
//

#import "cdaContact.h"

NSString * const cdaBrandAngelina = @"Angelina";
NSString * const cdaBrandThomas = @"Thomas";
NSString * const cdaBrandSesame = @"Sesame";
NSString * const cdaBrandMartha = @"Martha";

NSString * const cdaAppCategoryKids = @"Kids";
NSString * const cdaAppCategoryLifestyle = @"Lifestyle";
NSString * const cdaAppCategoryBooks = @"Book";


@implementation cdaContact
@synthesize emailAddress,
emailType,
firstName,
middleName,
lastName,
jobTitle,
companyName,
homePhone,
workPhone,
addr1,
addr2,
addr3,
city,
stateCode,
stateName,
countryCode,
countryName,
postalCode,
subPostalCode,
note,
brand,
appName,
appCategory,
customFields;

-(id) init {
    [super init];
    self.emailAddress = @"";
    self.emailType = @"HTML";
    self.firstName = @"";
    self.middleName = @"";
    self.lastName = @"";
    self.jobTitle = @"";
    self.companyName = @"";
    self.homePhone = @"";
    self.workPhone = @"";
    self.addr1 = @"";
    self.addr2 = @"";
    self.addr3 = @"";
    self.city = @"";
    self.stateCode = @"";
    self.stateName = @"";
    self.countryCode = @"";
    self.countryName = @"";
    self.postalCode = @"";
    self.subPostalCode = @"";
    self.note = @"";
    self.brand = @"";
    self.appName = @"";
    self.appCategory = @"";
    self.customFields = [NSMutableArray arrayWithCapacity:15];
    return self;
}

- (void)dealloc {
    self.emailAddress = nil;
    self.emailType = nil;
    self.firstName = nil;
    self.middleName = nil;
    self.lastName = nil;
    self.jobTitle = nil;
    self.companyName = nil;
    self.homePhone = nil;
    self.workPhone = nil;
    self.addr1 = nil;
    self.addr2 = nil;
    self.addr3 = nil;
    self.city = nil;
    self.stateCode = nil;
    self.stateName = nil;
    self.countryCode = nil;
    self.countryName = nil;
    self.postalCode = nil;
    self.subPostalCode = nil;
    self.note = nil;
    self.brand = nil;
    self.appName = nil;
    self.appCategory = nil;
    self.customFields = nil;
    [super dealloc];
}

-(void) setEmailType:(NSString *)theEmailType {
    if( theEmailType != nil ) {
        if( ![theEmailType isEqualToString:@"HTML"] &&
           ![theEmailType isEqualToString:@"Text"] ) {
            @throw [NSException exceptionWithName:@"Invalid value for email type" reason:[NSString stringWithFormat:@"Needs to be 'HTML' or 'Text' but passed %@", theEmailType] userInfo:nil];
        }
    } else {
        [emailType release];
    }
    emailType = theEmailType;
}

@end
