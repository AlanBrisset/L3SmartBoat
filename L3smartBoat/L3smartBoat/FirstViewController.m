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
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    /*
     *  Example for adding pin
     */
    CLLocation *data = [[CLLocation alloc] initWithLatitude:46.1474909 longitude:-1.1671439];
    // Add new line inside refreshTapped, in the setCompletionBlock, right after logging the response string
    [self pinPosition:data];
    
    CLLocation *data2 = [[CLLocation alloc] initWithLatitude:47.1474909 longitude:-0.1671439];
    [self pinPosition:data2];
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
    
    
    return coordonees;
}

// Add new method above refreshTapped
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

@end
