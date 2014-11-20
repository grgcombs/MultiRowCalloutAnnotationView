//
//  GenericPinAnnotationView.m
//  Created by Gregory Combs on 11/30/11.
//
//  based on work at https://github.com/grgcombs/MultiRowCalloutAnnotationView
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "GenericPinAnnotationView.h"

NSString* const GenericPinReuseIdentifier = @"GenericPinReuse";

@implementation GenericPinAnnotationView

+ (instancetype)pinViewWithAnnotation:(NSObject <MKAnnotation> *)annotation
{
    return [[GenericPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:GenericPinReuseIdentifier];
}

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.canShowCallout = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (!_preventSelectionChange)
    {
        [super setSelected:selected animated: animated];
    }
}

@end
