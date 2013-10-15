//
//  ConstantContactCollectionService.m
//  KeepInTouchWidgets
//
//  Created by FRANCISCO CANDALIJA on 5/25/11.
//  Copyright 2011 Callaway Digital Arts, Inc. All rights reserved.
//
#import "cdaConstantContactCollectionService.h"
#import "cdaConstantContactCURLOperation.h"
#import "cdaContact.h"
#import "APDocument.h"
#import "APElement.h"

static cdaConstantContactCollectionService * sharedInstance=nil;

@implementation cdaConstantContactCollectionService

@synthesize properties;

+(cdaConstantContactCollectionService*) sharedInstance {
 	if (!sharedInstance) {
		sharedInstance=[[[self class] alloc]init];
	}
	return sharedInstance;   
}
+(void)freeSharedInstance{
    CDA_RELEASE_SAFELY(sharedInstance);
}

-(id) init {
    [super init];

    self.properties = [[cdaConstantContactProperties new] autorelease];
    self.properties.url = @"https://api.constantcontact.com/ws/customers/%@/contacts";
    self.properties.customerId = @"callawaydigital";
    self.properties.createContactContentyType = @"application/atom+xml;type=entry";
    self.properties.apiKey = @"34129609-3835-43bb-a5ca-4eaf204581a3";
    self.properties.apiSecret = @"Spider@99";
    return self;
}

- (NSMutableURLRequest*) buildCreateContactRequest {
    NSString* urlString = [NSString stringWithFormat:self.properties.url, self.properties.customerId];
    NSMutableURLRequest* theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: urlString]];
    
    [theRequest setValue:self.properties.createContactContentyType forHTTPHeaderField:@"Content-type"];
    return theRequest;    
}

- (NSMutableURLRequest*) buildAddContactToListRequest:(NSString*) contactURL {
    NSMutableURLRequest* theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: contactURL]];    
    [theRequest setValue:self.properties.createContactContentyType forHTTPHeaderField:@"Content-type"];
    return theRequest;    
}


- (NSMutableURLRequest*) buildFindIdRequestForEmailAddress: (NSString*) emailAddress {
    NSString* urlBase = [NSString stringWithFormat:self.properties.url, self.properties.customerId];
    NSString* urlString = [NSString stringWithFormat:@"%@?email=%@", urlBase, [emailAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest* theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: urlString]];
    return theRequest;    
}

-(NSString*) buildPostPayloadWithContact:(cdaContact*)contact addToLists:(NSArray*) listIds withOptInSource: (cdaOptInSource)optInSource  {
    
    NSString *optInSourceValue;
    switch (optInSource) {
        case cdaOptInSource_REQUESTED_BY_CONTACT:
            optInSourceValue = @"ACTION_BY_CONTACT";
            break;            
        case cdaOptInSource_REQUESTED_BY_CDA:
            optInSourceValue = @"ACTION_BY_CUSTOMER";
            break;
        default:
            @throw [NSException exceptionWithName:@"optInSource value not supported" reason:[NSString stringWithFormat:@"optInSource with value %d not supported", optInSource] userInfo:nil];
    }
    
    NSMutableString* payload =  [NSMutableString stringWithFormat:@"<entry xmlns=\"http://www.w3.org/2005/Atom\">\
                                 <title type=\"text\"> </title>\
                                 <updated>2008-07-23T14:21:06.407Z</updated>\
                                 <author></author>\
                                 <id>data:,none</id>\
                                 <summary type=\"text\">Contact</summary>\
                                 <content type=\"application/vnd.ctct+xml\">\
                                 <Contact xmlns=\"http://ws.constantcontact.com/ns/1.0/\">\
                                 <EmailAddress>%@</EmailAddress>\
                                 <EmailType>%@</EmailType>\
                                 <FirstName>%@</FirstName>\
                                 <MiddleName>%@</MiddleName>\
                                 <LastName>%@</LastName>\
                                 <JobTitle>%@</JobTitle>\
                                 <CompanyName>%@</CompanyName>\
                                 <HomePhone>%@</HomePhone>\
                                 <WorkPhone>%@</WorkPhone>\
                                 <Addr1>%@</Addr1>\
                                 <Addr2>%@</Addr2>\
                                 <Addr3>%@</Addr3>\
                                 <City>%@</City>\
                                 <StateCode>%@</StateCode>\
                                 <StateName>%@</StateName>\
                                 <CountryCode>%@</CountryCode>\
                                 <CountryName>%@</CountryName>\
                                 <PostalCode>%@</PostalCode>\
                                 <SubPostalCode>%@</SubPostalCode>\
                                 <Note>%@</Note>\
                                 <OptInSource>%@</OptInSource>",
                                 contact.emailAddress,
                                 contact.emailType,
                                 contact.firstName, 
                                 contact.middleName,
                                 contact.lastName, 
                                 contact.jobTitle,
                                 contact.companyName,
                                 contact.homePhone,
                                 contact.workPhone,
                                 contact.addr1,
                                 contact.addr2,
                                 contact.addr3,
                                 contact.city,
                                 contact.stateCode,
                                 contact.stateName,
                                 contact.countryCode,
                                 contact.countryName,
                                 contact.postalCode,
                                 contact.subPostalCode,
                                 contact.note,
                                 optInSourceValue];                                                                   

    NSMutableArray* customFields = [NSMutableArray array];
    [customFields addObject:contact.brand];
    [customFields addObject:contact.appName];
    [customFields addObject:contact.appCategory];
    [customFields addObjectsFromArray:contact.customFields];
    // Start in fourth custom field. First 3 are for brand, app name and category
    int customFieldIndex = 1;
    for( NSString* customField in customFields ) {
        [payload appendFormat:@"<CustomField%d>%@</CustomField%d>",
         customFieldIndex, customField, customFieldIndex];
        customFieldIndex++;
        if( customFieldIndex > 15 ) {
            NSLog(@"Specified more than 15 custom fields, but only the first 15 are used");
            break;
        }
    }                                 
                                 
    [payload appendString:@"<ContactLists>"];                                     
    for( NSNumber* listId in listIds ) {
        [payload appendFormat:@"<ContactList id=\"http://api.constantcontact.com/ws/customers/%@/lists/%d\" />",
         self.properties.customerId, [listId intValue]];
    }
    [payload appendString:@"</ContactLists>\
     </Contact>\
     </content>\
     </entry>"]; 
    return payload;
}

-(NSString*) buildPutPayloadToAddContactId:(NSString*)contactId withEmailAddress:(NSString*)emailAddress toLists:(NSArray*) listIds  {
    
    NSMutableString* payload =  [NSMutableString stringWithFormat:@"<entry xmlns=\"http://www.w3.org/2005/Atom\">\
                                 <id>%@</id>\
                                 <title type=\"text\"></title>\
                                 <updated>2008-07-23T14:21:06.407Z</updated>\
                                 <author></author>\
                                 <content type=\"application/vnd.ctct+xml\">\
                                 <Contact xmlns=\"http://ws.constantcontact.com/ns/1.0/\">\
                                 <EmailAddress>%@</EmailAddress>\
                                 <OptInSource>ACTION_BY_CUSTOMER</OptInSource>",
                                 contactId,
                                 emailAddress];                                                                   
    
    
    [payload appendString:@"<ContactLists>"];                                     
    for( NSNumber* listId in listIds ) {
        [payload appendFormat:@"<ContactList id=\"http://api.constantcontact.com/ws/customers/%@/lists/%d\" />",
         self.properties.customerId, [listId intValue]];
    }
    [payload appendString:@"</ContactLists>\
     </Contact>\
     </content>\
     </entry>"]; 
    return payload;
}



-(void) collectContact:(cdaContact*) contact addToLists :(NSArray*)listIds withOptInSource:(cdaOptInSource)optInSource onSuccess: (cdaContactCollectionServiceOperationSuccessHandler)onSuccessHandler onFailure: (cdaContactCollectionServiceOperationFailureHandler)onFailureHandler {
    
    NSMutableURLRequest* theRequest = [self buildCreateContactRequest];
    theRequest.HTTPMethod = @"POST";    
    [theRequest setHTTPBody:[[self buildPostPayloadWithContact:contact addToLists:listIds withOptInSource:optInSource] dataUsingEncoding:NSUTF8StringEncoding]]; 
    NSString *username = [NSString stringWithFormat:@"%@%@%@", self.properties.apiKey, @"%", self.properties.customerId];
    NSString *secret = self.properties.apiSecret;        
    
    cdaConstantContactCURLOperation* op = [[[cdaConstantContactCURLOperation alloc]initWithRequest:theRequest] autorelease];
    op.defaultCredential = [[[NSURLCredential alloc] initWithUser:username password:secret persistence:NSURLCredentialPersistenceForSession] autorelease];
    op.onSuccessHandler = onSuccessHandler;
    op.onFailureHandler = ^(NSError* error) {
        if( error.code == 409 ) {
            // The contact is already created, let's find the id
            NSMutableURLRequest* findIdRequest = [self buildFindIdRequestForEmailAddress:contact.emailAddress];
            findIdRequest.HTTPMethod = @"GET";
            cdaConstantContactCURLOperation* op = [[[cdaConstantContactCURLOperation alloc]initWithRequest:findIdRequest] autorelease];
            op.onSuccessHandler = ^(int statusCode, NSDictionary* headers, NSData* contents) {
                APDocument* document = [APDocument documentWithXMLString:[NSString stringWithUTF8String:[contents bytes]]];
                APElement* entryElement = [[document rootElement] firstChildElementNamed:@"entry"];
                APElement* idElement = [entryElement firstChildElementNamed:@"id"];
                NSString* userResourceURL = [idElement.value stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"];
                NSMutableURLRequest* theRequest = [self buildAddContactToListRequest:userResourceURL];
                theRequest.HTTPMethod = @"PUT";    
                [theRequest setHTTPBody:[[self buildPutPayloadToAddContactId:idElement.value withEmailAddress:contact.emailAddress toLists:listIds] dataUsingEncoding:NSUTF8StringEncoding]]; 
                cdaConstantContactCURLOperation  *op = [[[cdaConstantContactCURLOperation alloc]initWithRequest:theRequest] autorelease];
                op.onSuccessHandler = onSuccessHandler;
                op.onFailureHandler = ^(NSError* error) {
                    NSLog(@"Error trying to update list with contact: %@", error);
                    onFailureHandler(error);
                };
                [op start];                
            };
            op.onFailureHandler = ^(NSError* error) {
                NSLog(@"Error trying to get id of contact from email address: %@", error);
                onFailureHandler(error);
            };
            [op start];
        } else {
            NSLog(@"Error different to contact already exist: %@", error);
            onFailureHandler(error);
        }
    };
    [op start];
}

-(void)dealloc{
    self.properties=nil;
    [super dealloc];
}

@end
