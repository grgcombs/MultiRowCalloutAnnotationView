//
//  MultiRowAnnotation.m
//  Created by Greg Combs on 11/30/11.
//
//  based on work at https://github.com/grgcombs/MultiRowCalloutAnnotationView
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "MultiRowAnnotation.h"

@implementation MultiRowAnnotation
@synthesize title = _title;
@synthesize coordinate = _coordinate;
@synthesize calloutCells = _calloutCells;

+ (MultiRowAnnotation *)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title calloutCells:(NSArray *)calloutCells {
    return [[MultiRowAnnotation alloc] initWithCoordinate:coordinate title:title calloutCells:calloutCells];
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title calloutCells:(NSArray *)calloutCells {
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.title = title;
        self.calloutCells = calloutCells;
    }
    return self;
}


    // For selection/deselection of the callout in the map view controller, we need to make a copy of the annotation
- (id)copyWithZone:(NSZone *)zone {
    MultiRowAnnotation *objectCopy = [[MultiRowAnnotation allocWithZone:zone] initWithCoordinate:_coordinate title:_title calloutCells:_calloutCells];
    return objectCopy;
}

- (void)copyAttributesFromAnnotation:(NSObject <MultiRowAnnotationProtocol> *)annotation {
    self.coordinate = annotation.coordinate;
    self.title = annotation.title;
    self.calloutCells = [annotation calloutCells];
}

@end
