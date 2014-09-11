//
//  QYViewController.m
//  LocationShow
//
//  Created by jiwei on 14-9-3.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "QYViewController.h"

#import <CoreLocation/CoreLocation.h>

@interface QYViewController ()<CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) CLLocationManager *manager;//地图管理
@property (nonatomic, strong) NSMutableArray *locationArray;//所有点的集合
@property (nonatomic, strong) CLLocation *startLocation;//起始点
@property (nonatomic, strong) CLLocation *suspendLocation;//暂停点
@property (nonatomic, strong) MKPolyline *nowLine;

@end

@implementation QYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.manager = [[CLLocationManager alloc] init];
    self.locationArray = [[NSMutableArray alloc] init];
    self.manager.delegate = self;
    [self.manager startUpdatingLocation];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - location manager

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    if (!self.startLocation) {
        self.startLocation =locations.lastObject;
        
        self.mapView.region = MKCoordinateRegionMake(self.startLocation.coordinate, MKCoordinateSpanMake(.005f, .005f));
    }
    [self.locationArray addObjectsFromArray:locations];
    
    MKPolyline *route = [self makePolylineWithLocations:self.locationArray];
    [self.mapView insertOverlay:route atIndex:0];
    if (self.nowLine) {
        [self.mapView removeOverlay:self.nowLine];
    }
    self.nowLine = route;

}

- (MKPolyline *)makePolylineWithLocations:(NSMutableArray *)newLocations{
    MKMapPoint *pointArray = malloc(sizeof(MKMapPoint)* newLocations.count);
    for(int i = 0; i < newLocations.count; i++)
    {
        CLLocationCoordinate2D coordinate = [newLocations[i] coordinate];
        pointArray[i] = MKMapPointForCoordinate(coordinate);
    }
    MKPolyline *polyline = [MKPolyline polylineWithPoints:pointArray count:newLocations.count];
    free(pointArray);
    return polyline;
}


#pragma mark - map delegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *routeLineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        routeLineView.strokeColor = [UIColor redColor];
        routeLineView.fillColor = [UIColor redColor];
        routeLineView.lineWidth = 6;
        return routeLineView;
    }
    return nil;
}

-(void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews{
#ifdef RUN_DEBUG
    NSLog(@"%s return OverlayView...",__FUNCTION__);
#endif
}

@end
