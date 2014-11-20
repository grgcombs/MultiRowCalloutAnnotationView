//
//  Representative.m
//  Created by Greg Combs on 11/30/11.
//
//  based on work at https://github.com/grgcombs/MultiRowCalloutAnnotationView
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "Representative.h"
#import "MultiRowCalloutCell.h"

@implementation Representative

+ (instancetype)representativeWithName:(NSString *)name party:(NSString *)party image:(UIImage *)image representativeID:(NSString *)representativeID
{
    return [[Representative alloc] initWithName:name party:party image:image representativeID:representativeID];
}

- (instancetype)initWithName:(NSString *)name party:(NSString *)party image:(UIImage *)image representativeID:(NSString *)representativeID
{
    self = [super init];
    if (self)
    {
        _name = name;
        _party = party;
        _image = image;
        _representativeID = representativeID;
    }
    return self;
}


- (MultiRowCalloutCell *)calloutCell
{
    NSDictionary *dict = nil;
    if (_representativeID)
        dict = @{@"id": _representativeID};
    return [MultiRowCalloutCell cellWithImage:_image 
                                        title:_party 
                                     subtitle:_name 
                                     userData:dict];
}

@end
