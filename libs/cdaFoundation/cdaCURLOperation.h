//
//  cdaXSellDownloadOperation.h
//  cdaXSellServiceSample
//
//  Created by FRANCISCO CANDALIJA on 7/1/11.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CURLOperation.h"

typedef void (^cdaCURLOperationFailureBlock)(NSError*);
typedef void (^cdaCURLOperationSuccessBlock)();


@interface cdaCURLOperation : CURLOperation {

    cdaCURLOperationSuccessBlock successBlock;
    cdaCURLOperationFailureBlock failureBlock;

}


@property(nonatomic,copy) cdaCURLOperationSuccessBlock successBlock;
@property(nonatomic,copy) cdaCURLOperationFailureBlock failureBlock;


@end
