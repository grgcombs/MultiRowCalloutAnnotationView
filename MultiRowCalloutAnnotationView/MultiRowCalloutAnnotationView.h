//
//  MultiRowCalloutAnnotationView.h
//  Created by Greg Combs on 11/29/11.
//
//  based on work at https://github.com/grgcombs/MultiRowCalloutAnnotationView
//
//  A portion of this class is based on James Rantanen's work at Asynchrony Solutions
//    http://blog.asolutions.com/2010/09/building-custom-map-annotation-callouts-part-1/
//    http://blog.asolutions.com/2010/09/building-custom-map-annotation-callouts-part-2/
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "MultiRowAnnotationProtocol.h"
#import "MultiRowCalloutCell.h"

@interface MultiRowCalloutAnnotationView : MKAnnotationView
+ (instancetype)calloutWithAnnotation:(id<MultiRowAnnotationProtocol>)annotation onCalloutAccessoryTapped:(MultiRowAccessoryTappedBlock)block;
- (instancetype)initWithAnnotation:(id<MultiRowAnnotationProtocol>)annotation reuseIdentifier:(NSString *)reuseIdentifier onCalloutAccessoryTapped:(MultiRowAccessoryTappedBlock)block NS_DESIGNATED_INITIALIZER;
/* Callout cells are MultiRowCalloutCells.  If the annotation object responds to "calloutCells",
 this will be set automatically upon initialization */
@property (nonatomic,strong) NSArray *calloutCells;
@property (nonatomic,copy) MultiRowAccessoryTappedBlock onCalloutAccessoryTapped; // copied to cells
@property (nonatomic,strong) MKAnnotationView *parentAnnotationView;
@property (nonatomic,unsafe_unretained) MKMapView *mapView;
@end

extern NSString* const MultiRowCalloutReuseIdentifier;
