//
//  ThirdViewController.m
//  L3smartBoat
//
//  Created by Jerome Godefroy on 22/03/2017.
//  Copyright © 2017 Jerome Godefroy. All rights reserved.
//

#import "ThirdViewController.h"

#define METERS_PER_MILE 1609.344

@interface ThirdViewController () <MKMapViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation ThirdViewController

int timer = 1;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cpt = 0;
    
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

    
    
    
    // Lancement de la récupération des données du NMEA simulator
    
    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:8080"]];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}








// GESTION DES ACTIONS DU DOIGT SUR LA MAP (pression longue durée) + STOCKAGE ET AFFICHAGE DES WAYPOINTS SUR LA MAP


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
    // you could check for specific gestures here
    return YES;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    // drop a marker annotation
    MKPointAnnotation *point = [MKPointAnnotation new];
    point.coordinate = [self.mapView convertPoint:[longPress locationInView:longPress.view] toCoordinateFromView:self.mapView];
    NSString *num = [NSString stringWithFormat:@"%d",timer];

    point.title = [NSString stringWithFormat:@"Waypoint n°%@",num];
    
    // add waypoint in list
    [self.waypoints addObject:point];

    
    // beautify marker
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
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.8*METERS_PER_MILE, 0.8*METERS_PER_MILE);
    
    // 3
    [_mapView setRegion:viewRegion animated:YES];
}










// --------- Récupération des coordonnées depuis la trame. Remplacement de la ligne de waypoints par nos propres waypoints ---------


-(NSString*)setRequestNMEA:(NSString*)trame {
    NSArray * array = [[NSArray alloc] initWithArray:[trame componentsSeparatedByString:@"$"]];
    
    NSString* name = @"Wpt";
    NSString* longitude;
    NSString* latitude;
    NSString* signe1;
    NSString* signe2;
    MKPointAnnotation *pointTemp;
    
    // Rajoute le nombre de zéro pour avoir le nom de la forme "WptXXX"
    for(int i = 0; i < (3-[[NSString stringWithFormat:@"%ld", (long)self.cpt] length]); i++)
        name = [NSString stringWithFormat:@"%@%d", name, 0];
    
    pointTemp = self.waypoints[(long)self.cpt];
    
    latitude  = [NSString stringWithFormat:@"%f", pointTemp.coordinate.latitude];
    longitude = [NSString stringWithFormat:@"%f", pointTemp.coordinate.longitude];
    
    // --- Traitement du signe de la valeur de la latitude & de la longitude (Orientation NESO) ---
    if([[latitude substringToIndex:1]  isEqual: @"-"])
        signe1 = @"S";
    else
        signe1 = @"N";
    
    
    if([[longitude substringToIndex:1]  isEqual: @"-"])
        signe2 = @"W";
    else
        signe2 = @"E";
    
    
    // Clone array pour le modifier
    NSMutableArray *arrayUpdate = [array mutableCopy];
    
    // Modifie la ligne de waypoint
    arrayUpdate[9] = [NSString stringWithFormat:@"GPWPL,%@,%@,%@,%@,%@*30\n", latitude, signe1, longitude, signe2, [NSString stringWithFormat:@"%@%ld", name, (long)self.cpt]];
    
    return [arrayUpdate componentsJoinedByString:@"$"];
    
	}
    
    










// RECEPTION DES DONNEES DU NMEA SIMULATOR + TRAITEMENT DES ENVOIS AU MEME INSTANT --------------------------------------------

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
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
    NSString* trame = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSString* waypointData = [self setRequestNMEA:trame];
    
    
    // Envoi données avec waypoints au serveur python
    
    [self sendNetworkCommunication: waypointData];
    
    
    // creation du fichier .txt et ecriture des données avec waypoints
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = @"/Users/leocharpentier/Desktop";
    self.filePath = [NSString stringWithFormat:@"%@/waypoints.txt",
                     documentsDirectory];
  
    [waypointData writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    
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









// ENVOI DES DONNEES AU NMEA SLEUTH AVEC WAYPOINT SUR SERVER PYTHON --------------------------------------------



-(void)sendNetworkCommunication:(NSString *)dataS  {
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL,
                                       (CFStringRef)@"127.0.0.1",
                                       8081,
                                       &readStream,
                                       &writeStream);
    NSInputStream *inputStream = (__bridge_transfer NSInputStream *)readStream;
    NSOutputStream *outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
    
    NSString *response  = dataS;
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
    
}



@end



