//
//  Contact.h
//  KeepInTouchWidgets
//
//  Created by FRANCISCO CANDALIJA on 5/25/11.
//  Copyright 2011 Callaway Digital Arts, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const cdaBrandAngelina;
extern NSString * const cdaBrandThomas;
extern NSString * const cdaBrandSesame;
extern NSString * const cdaBrandMartha;

extern NSString * const cdaAppCategoryKids;
extern NSString * const cdaAppCategoryLifestyle;
extern NSString * const cdaAppCategoryBooks;

@interface cdaContact : NSObject {
    NSString* emailAddress;
    NSString* emailType;
    NSString* firstName;
    NSString* middleName;
    NSString* lastName;
    NSString* jobTitle;    
    NSString* companyName;
    NSString* homePhone;   
    NSString* workPhone;        
    NSString* addr1;            
    NSString* addr2;
    NSString* addr3;
    NSString* city;    
    NSString* stateCode;
    NSString* stateName;
    NSString* countryCode;
    NSString* countryName;
    NSString* postalCode;
    NSString* subPostalCode;
    NSString* note;
    NSString* brand;
    NSString* appName;
    NSString* appCategory;
    NSMutableArray*  customFields; 
}

@property (nonatomic, retain) NSString* emailAddress;
@property (nonatomic, retain) NSString* emailType; // TODO: enforce HTML or Text
@property (nonatomic, retain) NSString* firstName;
@property (nonatomic, retain) NSString* middleName;
@property (nonatomic, retain) NSString* lastName;
@property (nonatomic, retain) NSString* jobTitle;    
@property (nonatomic, retain) NSString* companyName;
@property (nonatomic, retain) NSString* homePhone;   
@property (nonatomic, retain) NSString* workPhone;        
@property (nonatomic, retain) NSString* addr1;            
@property (nonatomic, retain) NSString* addr2;
@property (nonatomic, retain) NSString* addr3;
@property (nonatomic, retain) NSString* city;    
@property (nonatomic, retain) NSString* stateCode;
@property (nonatomic, retain) NSString* stateName;
@property (nonatomic, retain) NSString* countryCode;
@property (nonatomic, retain) NSString* countryName;
@property (nonatomic, retain) NSString* postalCode;
@property (nonatomic, retain) NSString* subPostalCode;
@property (nonatomic, retain) NSString* note;
@property (nonatomic, retain) NSString* brand;
@property (nonatomic, retain) NSString* appName;
@property (nonatomic, retain) NSString* appCategory;
@property (nonatomic, retain) NSMutableArray*  customFields; 

@end
