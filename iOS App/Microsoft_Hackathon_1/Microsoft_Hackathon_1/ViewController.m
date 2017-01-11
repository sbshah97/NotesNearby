//
//  ViewController.m
//  Microsoft_Hackathon_1
//
//  Created by Aiman Abdullah Anees on 12/10/16.
//  Copyright © 2016 Aiman Abdullah Anees. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController




-(void)alert:(NSString*)title withDetails:(NSString*)details {
    UIAlertView *alert = [[UIAlertView alloc]  initWithTitle:title
                                                     message:details
                                                    delegate:nil
                                           cancelButtonTitle:@"Ok"
                                           otherButtonTitles:nil];
    [alert show];
}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [PRARManager sharedManagerWithRadarAndSize:self.view.frame.size andDelegate:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *strUrl = [NSString stringWithFormat:@"https://mysecondproject-db358.firebaseio.com"];
    FIRDatabaseReference *ref = [[FIRDatabase database] referenceFromURL:strUrl];
    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *post = snapshot.value;
        NSLog(@"%@",post);
        NSLog(@"%i",post.count+1);
        
    }];
    
    CLLocationCoordinate2D locationCoordinates = CLLocationCoordinate2DMake(25.082681,55.147529);
    [[PRARManager sharedManager] startARWithData:[self getDummyData] forLocation:locationCoordinates];
}


-(NSArray*)getDummyData
{
    NSArray *dummyData = @[
                           @{
                               @"id":@(0),
                               @"lat":@(25.083130),
                               @"lon":@(55.147607),
                               @"title":@"Friends House.."
                               },
                           @{
                               @"id":@(1),
                               @"lat":@(25.082780),
                               @"lon":@(55.147655),
                               @"title":@"Buy Grocery"
                               },
                           @{
                               @"id":@(2),
                               @"lat":@(25.083732),
                               @"lon":@(55.147709),
                               @"title":@"Awesome View"
                               }
                           
                           ];
    return dummyData;
}


-(void)prarDidSetupAR:(UIView *)arView withCameraLayer:(AVCaptureVideoPreviewLayer *)cameraLayer andRadarView:(UIView *)radar
{
    [self.view.layer addSublayer:cameraLayer];
    [self.view addSubview:arView];
    [self.view bringSubviewToFront:[self.view viewWithTag:AR_VIEW_TAG]];
    [self.view addSubview: radar];
}

-(void)prarUpdateFrame:(CGRect)arViewFrame
{
    [[self.view viewWithTag:AR_VIEW_TAG] setFrame:arViewFrame];
    
    
}

-(void)prarGotProblem:(NSString *)problemTitle withDetails:(NSString *)problemDetails
{
    [self alert:problemTitle withDetails:problemDetails];
    
}



@end
