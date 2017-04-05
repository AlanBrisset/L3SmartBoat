//
//  ThirdViewController.h
//  L3smartBoat
//
//  Created by Jerome Godefroy on 22/03/2017.
//  Copyright © 2017 Jerome Godefroy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<MapKit/MapKit.h>

@interface ThirdViewController : UIViewController<UIGestureRecognizerDelegate, NSURLConnectionDelegate>

{
    NSMutableData *_responseData;
}


@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property(weak, nonatomic) NSMutableArray *waypoints;

@property( nonatomic) NSString* waypointData;

@property( nonatomic) NSInteger* cpt;

@property( nonatomic) CFReadStreamRef *readStream;

@property( nonatomic) CFWriteStreamRef *writeStream;

@property( nonatomic) NSOutputStream *outputStream;

@property( nonatomic) NSOutputStream *inputStream;

@property( nonatomic) NSString *filePath;





@end
