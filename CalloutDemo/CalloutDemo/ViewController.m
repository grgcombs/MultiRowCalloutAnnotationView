//
//  ViewController.h
//  Created by Gregory Combs on 11/30/11.
//
//  based on work at https://github.com/grgcombs/MultiRowCalloutAnnotationView
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "ViewController.h"
#import "District.h"
#import "GenericPinAnnotationView.h"
#import "MultiRowCalloutAnnotationView.h"

@interface ViewController()
@property (nonatomic, retain) MKAnnotationView *selectedAnnotationView;
@property (nonatomic,retain) District *pinAnnotation;
@property (nonatomic,retain) District *calloutAnnotation;
@end

@implementation ViewController
@synthesize mapView = _mapView;
@synthesize pinAnnotation = _pinAnnotation;
@synthesize calloutAnnotation = _calloutAnnotation;
@synthesize selectedAnnotationView = _selectedAnnotationView;

- (void)dealloc {
    self.mapView = nil;
    self.selectedAnnotationView = nil;
    self.calloutAnnotation = nil;
    self.pinAnnotation = nil;
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.mapView = nil;
    self.selectedAnnotationView = nil;
    self.calloutAnnotation = nil;
    self.pinAnnotation = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pinAnnotation = [District demoAnnotationFactory];
    [self.mapView addAnnotation:self.pinAnnotation];
}

#pragma mark - The Good Stuff

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    NSString *identifier = nil;
    if (annotation == self.calloutAnnotation) {
        identifier = @"CalloutAnnotation";
        MultiRowCalloutAnnotationView *annotationView = (MultiRowCalloutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (!annotationView) {
            MultiRowAccessoryTappedBlock onTap = ^(MultiRowCalloutCell *cell, UIControl *control, NSDictionary *userData) {
                NSLog(@"Representative (%@) with ID '%@' was tapped.", cell.subtitle, [userData objectForKey:@"id"]);
            };
            annotationView = [[[MultiRowCalloutAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier onCalloutAccessoryTapped:onTap] autorelease];
        }
        else
            annotationView.annotation = annotation;
        annotationView.parentAnnotationView = self.selectedAnnotationView;
        annotationView.mapView = mapView;
        return annotationView;
    } else if (annotation == self.pinAnnotation) {
        identifier = @"PinAnnotation";
        GenericPinAnnotationView* annotationView = (GenericPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (!annotationView) {
            annotationView = [[[GenericPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
            annotationView.pinColor = MKPinAnnotationColorGreen;
        }
        annotationView.annotation = annotation;
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView {
    id<MKAnnotation> annotation = aView.annotation;
    if (!annotation || ![aView isSelected])
        return;
    if (aView.annotation == self.pinAnnotation) {
        if (!_calloutAnnotation) {
            _calloutAnnotation = [_pinAnnotation copy];
            [mapView addAnnotation:_calloutAnnotation];
        }
        self.selectedAnnotationView = aView;
    }
    else
        [mapView setCenterCoordinate:annotation.coordinate animated:YES];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)aView {
    if (aView.annotation != self.pinAnnotation)
        return;
    GenericPinAnnotationView *pinView = (GenericPinAnnotationView *)aView;
    if (self.calloutAnnotation && pinView.preventSelectionChange == NO) {
        [mapView removeAnnotation:_calloutAnnotation];
        self.calloutAnnotation = nil;
    }
}

#pragma mark - Boilerplate Stuff

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.mapView.annotations)
        [_mapView removeAnnotations:_mapView.annotations];
}

@end
