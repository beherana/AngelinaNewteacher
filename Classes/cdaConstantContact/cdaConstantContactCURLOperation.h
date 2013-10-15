//
//  ConstantContactCURLOperation.h
//  KeepInTouchWidgets
//
//  Created by FRANCISCO CANDALIJA on 5/24/11.
//  Copyright 2011 Callaway Digital Arts, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CURLOperation.h"
#import "cdaContactCollectionService.h"

@interface cdaConstantContactCURLOperation : CURLOperation {
    cdaContactCollectionServiceOperationSuccessHandler onSuccessHandler;
    cdaContactCollectionServiceOperationFailureHandler onFailureHandler;    
}

@property(copy) cdaContactCollectionServiceOperationSuccessHandler onSuccessHandler;
@property(copy) cdaContactCollectionServiceOperationFailureHandler onFailureHandler;    

@end
