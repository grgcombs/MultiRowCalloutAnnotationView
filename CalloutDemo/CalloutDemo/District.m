//
//  DemoMapAnnotation.m
//  Created by Gregory Combs on 11/30/11.
//
//  based on work at https://github.com/grgcombs/MultiRowCalloutAnnotationView
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "District.h"
#import "Representative.h"

@interface District()
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title representatives:(NSArray *)representatives;
@end

@implementation District
@synthesize title = _title;
@synthesize coordinate = _coordinate;
@synthesize representatives = _representatives;

#pragma mark For Demonstration Purposes

/* Naturally, you should set up your annotation objects as usual, but this demo factory helps distance the cell data from the view controller. */
+ (District *)demoAnnotationFactory {
    Representative *dudeOne = [Representative representativeWithName:@"Rep. Dude" party:@"Republican" image:[UIImage imageNamed:@"redstar"] representativeID:@"TXL1"];
    Representative *dudeTwo = [Representative representativeWithName:@"Rep. Guy" party:@"Democrat" image:[UIImage imageNamed:@"bluestar"] representativeID:@"TXL2"];
    return [District districtWithCoordinate:CLLocationCoordinate2DMake(30.274722, -97.740556) title:@"Austin Representatives" representatives:[NSArray arrayWithObjects:dudeOne, dudeTwo, nil]];    
}

#pragma mark - The Good Stuff

+ (District *)districtWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title representatives:(NSArray *)representatives {
    return [[[District alloc] initWithCoordinate:coordinate title:title representatives:representatives] autorelease];
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title representatives:(NSArray *)representatives {
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.title = title;
        self.representatives = representatives;
    }
    return self;
}

- (void)dealloc {
    self.title = nil;
    self.representatives = nil;
    [super dealloc];
}

- (NSArray *)calloutCells {
    if (!_representatives || [_representatives count] == 0)
        return nil;
    return [self valueForKeyPath:@"representatives.calloutCell"];
}

// For selection/deselection of the callout in the map view controller, we need to make a copy of the annotation
- (id)copyWithZone:(NSZone *)zone {
    District *objectCopy = [[District allocWithZone:zone] initWithCoordinate:_coordinate title:_title representatives:_representatives];
    return objectCopy;
}

@end
