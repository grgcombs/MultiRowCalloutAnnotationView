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

@implementation District

#pragma mark For Demonstration Purposes

/* Naturally, you should set up your annotation objects as usual, but this demo factory helps distance the cell data from the view controller. */
+ (instancetype)demoAnnotationFactory
{
    Representative *dudeOne = [Representative representativeWithName:@"Rep. Dude" party:@"Republican" image:[UIImage imageNamed:@"redstar"] representativeID:@"TXL1"];
    Representative *dudeTwo = [Representative representativeWithName:@"Rep. Guy" party:@"Democrat" image:[UIImage imageNamed:@"bluestar"] representativeID:@"TXL2"];
    return [District districtWithCoordinate:CLLocationCoordinate2DMake(30.274722, -97.740556) title:@"Austin Representatives" representatives:@[dudeOne, dudeTwo]];    
}

#pragma mark - The Good Stuff

+ (instancetype)districtWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title representatives:(NSArray *)representatives
{
    return [[District alloc] initWithCoordinate:coordinate title:title representatives:representatives];
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title representatives:(NSArray *)representatives
{
    self = [super init];
    if (self)
    {
        _coordinate = coordinate;
        _title = title;
        _representatives = representatives;
    }
    return self;
}


- (NSArray *)calloutCells
{
    if (!_representatives || [_representatives count] == 0)
        return nil;
    return [self valueForKeyPath:@"representatives.calloutCell"];
}

@end
