//
//  ViewController.h
//  Microsoft_Hackathon_1
//
//  Created by Aiman Abdullah Anees on 12/10/16.
//  Copyright © 2016 Aiman Abdullah Anees. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRARManager.h"
#import <Firebase.h>


@interface ViewController : UIViewController <PRARManagerDelegate>
{
    __weak IBOutlet UIView *loadingV;
    
}


@end

