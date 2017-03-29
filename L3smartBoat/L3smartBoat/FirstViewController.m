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
    
    /*NSURL *targetURL = [NSURL URLWithString:@"http://127.0.0.1:8080"];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSArray *components = [dataString componentsSeparatedByString:@"|"];*/
   
    //[dataString release];
    
    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:8080"]];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
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





#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString* coordonnes = [self getCoordonnees:newStr];
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}


@end
