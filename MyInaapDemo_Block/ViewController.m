//
//  ViewController.m
//  MyInaapDemo_Block
//
//  Created by Tops on 29/04/15.
//  Copyright (c) 2015 Tops. All rights reserved.
//

#import "ViewController.h"
#import "IAPHelper.h"
#import "IAPShare.h"

@interface ViewController ()
{
    SKProduct* product;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(![IAPShare sharedHelper].iap) {
        
        NSSet* dataSet = [[NSSet alloc] initWithObjects:@"com.parlez.storekit.upgrade", nil];
        
        [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
        
    }
    [IAPShare sharedHelper].iap.production = YES;
    [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response)
     {
         if(response > 0 ) {
              product =[[IAPShare sharedHelper].iap.products objectAtIndex:0];
             NSLog(@"Product Identifier %@",product.productIdentifier);
         }
     }];
}
-(IBAction)btnBuyClick:(id)sender
{
    [[IAPShare sharedHelper].iap buyProduct:product
                               onCompletion:^(SKPaymentTransaction* trans){
                                   
                                   if(trans.error)
                                   {
                                       NSLog(@"Fail %@",[trans.error localizedDescription]);
                                   }
                                   else if(trans.transactionState == SKPaymentTransactionStatePurchased)
                                   {
                                       [[IAPShare sharedHelper].iap checkReceipt:trans.transactionReceipt AndSharedSecret:@"your sharesecret" onCompletion:^(NSString *response, NSError *error) {
                                           
                                           //Convert JSON String to NSDictionary
                                           NSDictionary* rec = [IAPShare toJSON:response];
                                           
                                           if([rec[@"status"] integerValue]==0)
                                           {
                                               NSString *productIdentifier = trans.payment.productIdentifier;
                                               [[IAPShare sharedHelper].iap provideContent:productIdentifier];
                                               NSLog(@"SUCCESS %@",response);
                                               NSLog(@"Pruchases %@",[IAPShare sharedHelper].iap.purchasedProducts);
                                           }
                                           else {
                                               NSLog(@"Fail");
                                           }
                                       }];
                                   }
                                   else if(trans.transactionState == SKPaymentTransactionStateFailed) {
                                       NSLog(@"Fail");
                                   }
                               }];//end of buy product
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
