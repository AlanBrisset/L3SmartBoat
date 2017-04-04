//
//  ThirdViewController.h
//  L3smartBoat
//
//  Created by Jerome Godefroy on 22/03/2017.
//  Copyright © 2017 Jerome Godefroy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<MapKit/MapKit.h>

@interface ThirdViewController : UIViewController<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property(weak, nonatomic) NSMutableArray *waypoints;

@end
