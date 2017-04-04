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
    
    /* NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                         NSArray *components = [dataString componentsSeparatedByString:@"|"];*/
    //[dataString release];
    
    // --------- Creation de la requête de connexion vers le simulateur ---------
    
    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:8080"]];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [super viewDidLoad];
    
    // ------------------
    
    /*
     * Code bon mais ne fonctionne pas
     * ------------------
     * Draw line
     */
    //Declare C array big enough to hold the number of coordinates in points...
//    CLLocationCoordinate2D coordinates[2]; //points.count];
    
//    int coordinatesIndex = 0;
    
/*    for (NSDictionary * c in points) {
        double x = [[c valueForKey:@"x"] doubleValue];
        double y = [[c valueForKey:@"y"] doubleValue];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = y;
        coordinate.longitude = x;
        
        //Put this coordinate in the C array...
        coordinates[coordinatesIndex] = coordinate;
        
        coordinatesIndex++;
    }   */
    
/*    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 46.1474909; coordinate.longitude = -1.1671439;
    CLLocation *dataCoord = [[CLLocation alloc] initWithLatitude:46.1474909 longitude:-1.1671439];
    coordinates[coordinatesIndex] = coordinate;
    [self pinPosition:dataCoord];
    coordinate.latitude = 45.1474909;
    CLLocation *dataCoord2 = [[CLLocation alloc] initWithLatitude:45.1474909 longitude:-1.1671439];
    coordinates[coordinatesIndex+1] = coordinate;
    [self pinPosition:dataCoord2];
    
    //C array is ready, create the polyline...
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:2];
    
    //Add the polyline to the map...
    [self.mapView addOverlay:polyline level:MKOverlayLevelAboveRoads];
    */
    // ------------------
    
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer *pr = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        pr.strokeColor = [UIColor redColor];
        pr.lineWidth = 5;
        return pr;
    }
    
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	// --------- Paramétrage du zoom initial : on souhaite avoir une vue de La Rochelle lorsqu'on lance l'application. ---------
	// 1
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 46.1474909;
    zoomLocation.longitude= -1.1671439;
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.8	*METERS_PER_MILE, 0.8*METERS_PER_MILE);
    
    // 3
    [_mapView setRegion:viewRegion animated:YES];
    
}

// --------- Récupération des coordonnées depuis la trame. La dernière trame doit être passée en paramètre. Réponse sous la forme "Latitude ; Longitude" ---------
-(NSString*)getCoordonnees:(NSString*)trame {
    NSArray * array = [[NSArray alloc] initWithArray:[trame componentsSeparatedByString:@"$"]];
    NSString * line  = array[3];
    
    NSArray * arrayCoors = [[NSArray alloc] initWithArray:[line componentsSeparatedByString:@","]];
    
    NSString * coordonees = arrayCoors[1]; // Récupération de la latitude
    coordonees = [coordonees stringByAppendingString:@";"];
    coordonees = [coordonees stringByAppendingString:arrayCoors[3]]; // Récupération de la longitude
    
    
	// --- Traitement de la latitude ---
    NSString * latitude = arrayCoors[1];
    
    
    char * tmp = [latitude UTF8String];
    
    NSString *minLat = @"";
    NSString *lat = @"";
    for(int i = latitude.length; i >= 0; i--){
        if(i > latitude.length-7)
            minLat = [NSString stringWithFormat:@"%c%@", tmp[i], minLat];
        else
            lat = [NSString stringWithFormat:@"%c%@", tmp[i], lat];
    }
    

	// --- Traitement de la longitude
    NSString * longitude = arrayCoors[3];
    
    char * tmpLongi = [longitude UTF8String];
    
    NSString *minLongi = @"";
    NSString *longi = @"";
    for(int i = longitude.length; i >= 0; i--){
        if(i > longitude.length-7)
            minLongi = [NSString stringWithFormat:@"%c%@", tmpLongi[i], minLongi];
        else
            longi = [NSString stringWithFormat:@"%c%@", tmpLongi[i], longi];
    }

    // --- Conversion vers des données compréhensible pour l'application
    float latitudeVal = [minLat floatValue];
    latitudeVal = (latitudeVal/60) + [lat intValue];
    
    float longitudeVal = [minLongi floatValue];
    longitudeVal = (longitudeVal/60)+[longi intValue];
    
	// --- Traitement du signe de la valeur de la latitude & de la longitude (Orientation NESO) ---
    if([arrayCoors[2]  isEqual: @"S"])
        latitudeVal = -latitudeVal;
    
    if([arrayCoors[4] isEqual: @"W"])
        longitudeVal = -longitudeVal;
    
    // --- Crée un pin à la position
    CLLocation *dataCoord = [[CLLocation alloc] initWithLatitude:latitudeVal longitude:longitudeVal];
    [self pinPosition:dataCoord];
    
    return coordonees;
}

// --------- Ajout d'un pointeur sur la map ---------
- (void)pinPosition:(CLLocation *)responseCoordinate {
    
    CLLocationCoordinate2D pinCoordinate;
    pinCoordinate.latitude = responseCoordinate.coordinate.latitude;
    pinCoordinate.longitude = responseCoordinate.coordinate.longitude;
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    // [annotation setCoordinate: pinCoordinate];
    annotation.coordinate = pinCoordinate;
    annotation.title = @"Waypoint";
    annotation.subtitle = [NSString stringWithFormat:@"Lat: %f - Long: %f", pinCoordinate.latitude, pinCoordinate.longitude];
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
