//
//  FirstViewController.m
//  L3smartBoat
//
//  Created by Jerome Godefroy on 22/03/2017.
//  Copyright © 2017 Jerome Godefroy. All rights reserved.
//

#import "FirstViewController.h"

#define METERS_PER_MILE 1609.344

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    
    
    /* test de la récupération des coordonnées
     
    NSError * erreur = nil;
    NSString * contenu = [NSString stringWithContentsOfFile:@"/users/nathan/Desktop/fichier.txt" encoding:NSUTF8StringEncoding error:&erreur];
    NSString * coordonnees = [self getCoordonnees:contenu];*/
    
    /*
     *  Init draw line
     */
    //initialize your map view and add it to your view hierarchy - **set its delegate to self***
    CLLocationCoordinate2D coordinateArray[2];
    int lat1 = 46.1474909;
    int lat2 = 45.1474909;
    int longi = -1.1671439;
    coordinateArray[0] = CLLocationCoordinate2DMake(lat1, longi);
    coordinateArray[1] = CLLocationCoordinate2DMake(lat2, longi);
    
    
    self.routeLine = [MKPolyline polylineWithCoordinates:coordinateArray count:2];
    [self.mapView setVisibleMapRect:[self.routeLine boundingMapRect]]; //If you want the route to be visible
    
    [self.mapView addOverlay:self.routeLine];
    
    [super viewDidLoad];
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

//permet de recuperer les coordonnées depuis la trame !!!il faut passer la derniere trame en parametre!!!  reponse sous la forme "lattitude;longitude"
-(NSString*)getCoordonnees:(NSString*)trame {
    NSArray * array = [[NSArray alloc] initWithArray:[trame componentsSeparatedByString:@"$"]];
    NSString * line  = array[3];
    
    NSArray * arrayCoors = [[NSArray alloc] initWithArray:[line componentsSeparatedByString:@","]];
    
    NSString * coordonees = arrayCoors[1];
    coordonees = [coordonees stringByAppendingString:@";"];
    coordonees = [coordonees stringByAppendingString:arrayCoors[3]];
    
    // Send coord to pinPosition
    CLLocation *dataCoord = [[CLLocation alloc] initWithLatitude:[arrayCoors[1] intValue] longitude:[arrayCoors[3] intValue]];
    [self pinPosition:dataCoord];
    
    return coordonees;
}

// Add pin on the map
- (void)pinPosition:(CLLocation *)responseCoordinate {
    
    CLLocationCoordinate2D pinCoordinate;
    pinCoordinate.latitude = responseCoordinate.coordinate.latitude;
    pinCoordinate.longitude = responseCoordinate.coordinate.longitude;
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    // [annotation setCoordinate: pinCoordinate];
    annotation.coordinate = pinCoordinate;
    annotation.title = @"Title"; //You can set the subtitle too
    [self.mapView addAnnotation:annotation];
}


// Display line drawed
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if(overlay == self.routeLine)
    {
        if(nil == self.routeLineView)
        {
            
            self.routeLineView = [[MKPolylineRenderer alloc] initWithOverlay:[self routeLine]];
            self.routeLineView.fillColor = [UIColor redColor];
            self.routeLineView.strokeColor = [UIColor redColor];
            self.routeLineView.lineWidth = 5;
            
        }
        
        return self.routeLineView;
    }
    
    return nil;
}

@end
