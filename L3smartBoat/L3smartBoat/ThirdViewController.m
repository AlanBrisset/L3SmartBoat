//
//  ThirdViewController.m
//  L3smartBoat
//
//  Created by Jerome Godefroy on 22/03/2017.
//  Copyright © 2017 Jerome Godefroy. All rights reserved.
//

#import "ThirdViewController.h"
//#import "Mapbox.h"

#define METERS_PER_MILE 1609.344

@interface ThirdViewController () <MKMapViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation ThirdViewController

int timer = 1;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    
    // double tapping zooms the map, so ensure that can still happen
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    doubleTap.numberOfTapsRequired = 2;
    [self.mapView addGestureRecognizer:doubleTap];
    
    // delay single tap recognition until it is clearly not a double
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    singleTap.delegate = self;
    [self.mapView addGestureRecognizer:singleTap];
    
    // also, long press for the hell of it
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //user needs to press for 2 seconds
    [self.mapView addGestureRecognizer:lpgr];
    //[lpgr release];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap
{
    // convert tap location (CGPoint)
    // to geographic coordinates (CLLocationCoordinate2D)
    CLLocationCoordinate2D location = [self.mapView convertPoint:[tap locationInView:self.mapView]
                                            toCoordinateFromView:self.mapView];
    
    NSLog(@"You tapped at: %.5f, %.5f", location.latitude, location.longitude);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // you could check for specific gestures here, but ¯\_(ツ)_/¯
    return YES;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    // drop a marker annotation

    
        MKPointAnnotation *point = [MKPointAnnotation new];
        point.coordinate = [self.mapView convertPoint:[longPress locationInView:longPress.view]
                                 toCoordinateFromView:self.mapView];
        NSString *num = [NSString stringWithFormat:@"%d",timer];
        NSString *pointT = [NSString stringWithFormat:@"Checkpoint n°%@",num];

        point.title = pointT;
        point.subtitle = [NSString stringWithFormat:@"lat: %.3f, lon: %.3f", point.coordinate.latitude, point.coordinate.longitude];
        [self.mapView addAnnotation:point];
        [self.mapView selectAnnotation:point animated:YES];
        usleep(9888);
        timer ++;
            
        

    
}

- (BOOL)mapView:(MKMapView *)mapView annotationCanShowCallout:(id <MKAnnotation>)annotation
{
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    // 1
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 46.1474909;
    zoomLocation.longitude= -1.1671439;
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.8	*METERS_PER_MILE, 0.8*METERS_PER_MILE);
    
    // 3
    [_mapView setRegion:viewRegion animated:YES];
}



@end
