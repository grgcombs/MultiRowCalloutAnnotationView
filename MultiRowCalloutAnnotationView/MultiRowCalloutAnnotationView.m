//
//  MultiRowCalloutAnnotationView.m
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

#import "MultiRowCalloutAnnotationView.h"
#import "GenericPinAnnotationView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

NSString* const MultiRowCalloutReuseIdentifier = @"MultiRowCalloutReuse";

CGFloat const kMultiRowCalloutCellGap = 3;

@interface MultiRowCalloutAnnotationView()
@property (nonatomic,retain) IBOutlet UILabel *titleLabel;
@property (nonatomic,assign) CGFloat cellInsetX;
@property (nonatomic,assign) CGFloat cellOffsetY;
- (void)setTitleWithAnnotation:(id<MultiRowAnnotationProtocol>)annotation;
- (void)setCalloutCellsWithAnnotation:(id<MultiRowAnnotationProtocol>)annotation;
- (void)copyAccessoryTappedBlockToCalloutCells;

@property (nonatomic,assign) CGFloat contentHeight;
@property (nonatomic,assign) CGPoint offsetFromParent;
@property (nonatomic,readonly) CGFloat yShadowOffset;
@property (nonatomic,retain) UIView *contentView;
- (void)prepareContentFrame;
- (void)prepareFrameSize;
- (void)prepareOffset;
- (CGSize)contentSize;
- (void)enableSibling:(MKAnnotationView *)sibling;
- (void)preventParentSelectionChange;
- (void)allowParentSelectionChange;

    // Abstract Class Vars and Methods
@property (nonatomic,readonly) CGSize actualSize; // contentSize + buffers
@property (nonatomic,assign) BOOL animateOnNextDrawRect;
@property (nonatomic,assign) CGRect endFrame;
- (void)animateIn;
- (void)animateInStepTwo;
- (void)animateInStepThree;
- (CGFloat)relativeParentXPosition;
- (void)adjustMapRegionIfNeeded;
@end

@implementation MultiRowCalloutAnnotationView
@synthesize calloutCells = _calloutCells;
@synthesize cellInsetX = _cellInsetX;
@synthesize cellOffsetY = _cellOffsetY;
@synthesize titleLabel = _titleLabel;
@synthesize onCalloutAccessoryTapped = _onCalloutAccessoryTapped;
@synthesize parentAnnotationView = _parentAnnotationView;
@synthesize mapView = _mapView;
@synthesize contentView = _contentView;
@synthesize animateOnNextDrawRect = _animateOnNextDrawRect;
@synthesize endFrame = _endFrame;
@synthesize yShadowOffset = _yShadowOffset;
@synthesize offsetFromParent = _offsetFromParent;
@synthesize contentHeight = _contentHeight;

+ (MultiRowCalloutAnnotationView *)calloutWithAnnotation:(id<MultiRowAnnotationProtocol>)annotation onCalloutAccessoryTapped:(MultiRowAccessoryTappedBlock)block {
    return [[[MultiRowCalloutAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MultiRowCalloutReuseIdentifier onCalloutAccessoryTapped:block] autorelease];
}

- (id)initWithAnnotation:(id<MultiRowAnnotationProtocol>)annotation reuseIdentifier:(NSString *)reuseIdentifier onCalloutAccessoryTapped:(MultiRowAccessoryTappedBlock)block {
    self = [super initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentHeight = 80.0;
        _yShadowOffset = 6;
        self.offsetFromParent = CGPointMake(8, -14); //this works for MKPinAnnotationView
        self.enabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.cellInsetX = 15;
        self.cellOffsetY = 10;
        self.onCalloutAccessoryTapped = block;
        [self setTitleWithAnnotation:annotation];
        [self setCalloutCellsWithAnnotation:annotation];
    }
    return self;
}

- (id)initWithAnnotation:(id<MultiRowAnnotationProtocol>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [self initWithAnnotation:annotation reuseIdentifier:reuseIdentifier onCalloutAccessoryTapped:nil];
    return self;
}

- (void)dealloc {
    self.calloutCells = nil;
    self.titleLabel = nil;
    Block_release(_onCalloutAccessoryTapped);
    self.parentAnnotationView = nil;
    self.mapView = nil;
    self.contentView = nil;
    [super dealloc];
}

#pragma mark - Setters and Accessors

- (void)setAnnotation:(id <MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    if (!annotation)
        return;
    [self setTitleWithAnnotation:(id<MultiRowAnnotationProtocol>)annotation];
    [self setCalloutCellsWithAnnotation:(id<MultiRowAnnotationProtocol>)annotation];
    [self prepareFrameSize];
    [self prepareOffset];
    [self prepareContentFrame];
    [self setNeedsDisplay];
}

- (void)setTitleWithAnnotation:(id<MultiRowAnnotationProtocol>)annotation {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.textColor = [UIColor colorWithRed:242/255.f green:245/255.f blue:226/255.f alpha:1];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14]; 
        _titleLabel.shadowColor = [UIColor darkTextColor];
        _titleLabel.shadowOffset = CGSizeMake(0, -1);
        [self.contentView addSubview:_titleLabel];
    }
    if (annotation) {
        _cellOffsetY = 35 + (2*kMultiRowCalloutCellGap);
        _titleLabel.text = annotation.title;
        _titleLabel.hidden = NO;
    }
    else {
        _titleLabel.hidden = YES;
        _cellOffsetY = 10;
    }
}

- (void)setCalloutCellsWithAnnotation:(id<MultiRowAnnotationProtocol>)annotation {
    if (annotation)
        [self setCalloutCells:[annotation calloutCells]];
}

- (void)setCalloutCells:(NSArray *)calloutCells {
    if (_calloutCells) {
        for (MultiRowCalloutCell *cell in _calloutCells)
            [cell removeFromSuperview];
        [_calloutCells release];
    }
    _calloutCells = [calloutCells retain];
    if (calloutCells) {
        self.contentHeight = _cellOffsetY + ([calloutCells count] * (kMultiRowCalloutCellSize.height + kMultiRowCalloutCellGap));
        for (MultiRowCalloutCell *cell in calloutCells)
            [self.contentView addSubview:cell];
        [self prepareContentFrame];
        [self copyAccessoryTappedBlockToCalloutCells];
    } 
}

#pragma mark - Block setters

    // NOTE: Sometimes see crashes when relying on just the copy property. Using Block_copy ensures correct behavior

- (void)setOnCalloutAccessoryTapped:(MultiRowAccessoryTappedBlock)onCalloutAccessoryTapped {
    if (_onCalloutAccessoryTapped) {
        Block_release(_onCalloutAccessoryTapped);
        _onCalloutAccessoryTapped = nil;
    }
    _onCalloutAccessoryTapped = Block_copy(onCalloutAccessoryTapped);
    [self copyAccessoryTappedBlockToCalloutCells];
}

- (void)copyAccessoryTappedBlockToCalloutCells {
    if (!self.onCalloutAccessoryTapped)
        return;
    for (MultiRowCalloutCell *cell in _calloutCells)
        if (!cell.onCalloutAccessoryTapped)
            cell.onCalloutAccessoryTapped = _onCalloutAccessoryTapped;
}

#pragma mark - Layout

- (void)prepareContentFrame {
    self.contentView.frame = CGRectMake(self.bounds.origin.x + 10, self.bounds.origin.y + 3, [self contentSize].width, [self contentSize].height);
    if (self.titleLabel)
        _titleLabel.frame = CGRectMake(_cellInsetX, 10, kMultiRowCalloutCellSize.width - (2*_cellInsetX), 25);
    NSInteger index = 0;
    for (MultiRowCalloutCell *cell in self.calloutCells) {
        cell.frame = CGRectMake(_cellInsetX, _cellOffsetY + index * (kMultiRowCalloutCellSize.height+kMultiRowCalloutCellGap), kMultiRowCalloutCellSize.width - (_cellInsetX*2), kMultiRowCalloutCellSize.height - (2*kMultiRowCalloutCellGap));
        [cell setNeedsDisplay];
        index++;
    }
}

- (CGSize)contentSize {
    return CGSizeMake(kMultiRowCalloutCellSize.width, self.contentHeight);
}

#pragma mark - Selection/Deselection

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    
    //If the accessory is hit, the map view may want to select an annotation sitting below it, so we must disable the other annotations
    //But not the parent because that will screw up the selection
    if (/*hitView == self.accessory*/ [hitView isKindOfClass:[UIButton class]]) {
        [self preventParentSelectionChange];
        [self performSelector:@selector(allowParentSelectionChange) withObject:nil afterDelay:1.0];
        for (UIView *aView in self.superview.subviews) {
            if ([aView isKindOfClass:[MKAnnotationView class]] && aView != self.parentAnnotationView) {
                MKAnnotationView *sibling = (MKAnnotationView *)aView;
                sibling.enabled = NO;
                [self performSelector:@selector(enableSibling:) withObject:sibling afterDelay:1.0];
            }
        }
    }
    return hitView;
}

- (void)enableSibling:(MKAnnotationView *)sibling {
    sibling.enabled = YES;
}

- (void)preventParentSelectionChange {
    if (_parentAnnotationView && [_parentAnnotationView respondsToSelector:@selector(setPreventSelectionChange:)]) {
        GenericPinAnnotationView *parentView = (GenericPinAnnotationView *)self.parentAnnotationView;
        parentView.preventSelectionChange = YES;
    }
}

- (void)allowParentSelectionChange {
    if (!_mapView || !_parentAnnotationView)
        return;
    //The MapView may think it has deselected the pin, so we should re-select it
    [self.mapView selectAnnotation:self.parentAnnotationView.annotation animated:NO];
    if ([_parentAnnotationView respondsToSelector:@selector(setPreventSelectionChange:)]) {
        GenericPinAnnotationView *parentView = (GenericPinAnnotationView *)_parentAnnotationView;
        parentView.preventSelectionChange = NO;
    }
}

#pragma mark - Abstract Class Methods

#define CalloutMapAnnotationViewBottomShadowBufferSize 6.0f
#define CalloutMapAnnotationViewContentHeightBuffer 8.0f
#define CalloutMapAnnotationViewHeightAboveParent 2.0f

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (!_mapView)
        return;
    [self adjustMapRegionIfNeeded];
    [self animateIn];
    [self setNeedsLayout];
}

- (CGSize)actualSize {
    return CGSizeMake([self contentSize].width + 20, [self contentSize].height + CalloutMapAnnotationViewContentHeightBuffer + CalloutMapAnnotationViewBottomShadowBufferSize - self.offsetFromParent.y);
}

- (void)prepareFrameSize {
    CGRect frame = self.frame;
    frame.size = [self actualSize];
    self.frame = frame;
}

- (void)prepareOffset {
    CGPoint parentOrigin = [self.mapView convertPoint:self.parentAnnotationView.frame.origin fromView:self.parentAnnotationView.superview];
    CGFloat xOffset =    (self.actualSize.width / 2) - (parentOrigin.x + self.offsetFromParent.x);
        //Add half our height plus half of the height of the annotation we are tied to so that our bottom lines up to its top
        //Then take into account its offset and the extra space needed for our drop shadow
    CGFloat yOffset = -(self.frame.size.height / 2 + self.parentAnnotationView.frame.size.height / 2) + self.offsetFromParent.y + CalloutMapAnnotationViewBottomShadowBufferSize;
    self.centerOffset = CGPointMake(xOffset, yOffset);
}

    //if the pin is too close to the edge of the map view we need to shift the map view so the callout will fit.
- (void)adjustMapRegionIfNeeded {
    if (!_mapView)
        return;
    
        //Longitude
    CGFloat xPixelShift = 0;
    if ([self relativeParentXPosition] < 38) {
        xPixelShift = 38 - [self relativeParentXPosition];
    } else if ([self relativeParentXPosition] > self.frame.size.width - 38) {
        xPixelShift = (self.frame.size.width - 38) - [self relativeParentXPosition];
    }
    
        //Latitude
    CGPoint mapViewOriginRelativeToParent = [self.mapView convertPoint:self.mapView.frame.origin toView:self.parentAnnotationView];
    CGFloat yPixelShift = 0;
    CGFloat pixelsFromTopOfMapView = -(mapViewOriginRelativeToParent.y + self.frame.size.height - CalloutMapAnnotationViewBottomShadowBufferSize);
    CGFloat pixelsFromBottomOfMapView = self.mapView.frame.size.height + mapViewOriginRelativeToParent.y - self.parentAnnotationView.frame.size.height;
    if (pixelsFromTopOfMapView < 7) {
        yPixelShift = 7 - pixelsFromTopOfMapView;
    } else if (pixelsFromBottomOfMapView < 10) {
        yPixelShift = -(10 - pixelsFromBottomOfMapView);
    }
    
        //Calculate new center point, if needed
    if (xPixelShift || yPixelShift) {
        CGFloat pixelsPerDegreeLongitude = self.mapView.frame.size.width / self.mapView.region.span.longitudeDelta;
        CGFloat pixelsPerDegreeLatitude = self.mapView.frame.size.height / self.mapView.region.span.latitudeDelta;
        
        CLLocationDegrees longitudinalShift = -(xPixelShift / pixelsPerDegreeLongitude);
        CLLocationDegrees latitudinalShift = yPixelShift / pixelsPerDegreeLatitude;
        
        CLLocationCoordinate2D newCenterCoordinate = {self.mapView.region.center.latitude + latitudinalShift, self.mapView.region.center.longitude + longitudinalShift};
        
        [self.mapView setCenterCoordinate:newCenterCoordinate animated:YES];
        
            //fix for now
        self.frame = CGRectMake(self.frame.origin.x - xPixelShift, self.frame.origin.y - yPixelShift, self.frame.size.width, self.frame.size.height);
            //fix for later (after zoom or other action that resets the frame)
        self.centerOffset = CGPointMake(self.centerOffset.x - xPixelShift, self.centerOffset.y);
    }
}

- (CGFloat)xTransformForScale:(CGFloat)scale {
    CGFloat xDistanceFromCenterToParent = self.endFrame.size.width / 2 - [self relativeParentXPosition];
    return (xDistanceFromCenterToParent * scale) - xDistanceFromCenterToParent;
}

- (CGFloat)yTransformForScale:(CGFloat)scale {
    CGFloat yDistanceFromCenterToParent = (((self.endFrame.size.height) / 2) + self.offsetFromParent.y + CalloutMapAnnotationViewBottomShadowBufferSize + CalloutMapAnnotationViewHeightAboveParent);
    return yDistanceFromCenterToParent - yDistanceFromCenterToParent * scale;
}

- (void)animateIn {
    self.endFrame = self.frame;
    CGFloat scale = 0.001f;
    self.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, [self xTransformForScale:scale], [self yTransformForScale:scale]);
    [UIView beginAnimations:@"animateIn" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.075];
    [UIView setAnimationDidStopSelector:@selector(animateInStepTwo)];
    [UIView setAnimationDelegate:self];
    scale = 1.1;
    self.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, [self xTransformForScale:scale], [self yTransformForScale:scale]);
    [UIView commitAnimations];
}

- (void)animateInStepTwo {
    [UIView beginAnimations:@"animateInStepTwo" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationDidStopSelector:@selector(animateInStepThree)];
    [UIView setAnimationDelegate:self];
    CGFloat scale = 0.95;
    self.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, [self xTransformForScale:scale], [self yTransformForScale:scale]);
    [UIView commitAnimations];
}

- (void)animateInStepThree {
    [UIView beginAnimations:@"animateInStepThree" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.075];
    CGFloat scale = 1.0;
    self.transform = CGAffineTransformMake(scale, 0.0f, 0.0f, scale, [self xTransformForScale:scale], [self yTransformForScale:scale]);
    [UIView commitAnimations];
}

- (void)drawRect:(CGRect)rect {
    CGFloat stroke = 1.0;
    CGFloat radius = 7.0;
    CGMutablePathRef path = CGPathCreateMutable();
    UIColor *color;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat parentX = [self relativeParentXPosition];
        //Determine Size
    rect = self.bounds;
    rect.size.width -= stroke + 14;
    rect.size.height -= stroke + CalloutMapAnnotationViewHeightAboveParent - self.offsetFromParent.y + CalloutMapAnnotationViewBottomShadowBufferSize;
    rect.origin.x += stroke / 2.0 + 7;
    rect.origin.y += stroke / 2.0;
    
        //Create Path For Callout Bubble
    CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y + radius);
    CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI / 2, 1);
    CGPathAddLineToPoint(path, NULL, parentX - 15, rect.origin.y + rect.size.height);
    CGPathAddLineToPoint(path, NULL, parentX, rect.origin.y + rect.size.height + 15);
    CGPathAddLineToPoint(path, NULL, parentX + 15, rect.origin.y + rect.size.height);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + radius, rect.origin.y);
    CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
    CGPathCloseSubpath(path);
    
        //Fill Callout Bubble & Add Shadow
    color = [[UIColor blackColor] colorWithAlphaComponent:.6];
    [color setFill];
    CGContextAddPath(context, path);
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake (0, self.yShadowOffset), 6, [UIColor colorWithWhite:0 alpha:.5].CGColor);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
        //Stroke Callout Bubble
    color = [[UIColor darkGrayColor] colorWithAlphaComponent:.9];
    [color setStroke];
    CGContextSetLineWidth(context, stroke);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    
        //Determine Size for Gloss
    CGRect glossRect = self.bounds;
    glossRect.size.width = rect.size.width - stroke;
    glossRect.size.height = (rect.size.height - stroke) / 2;
    glossRect.origin.x = rect.origin.x + stroke / 2;
    glossRect.origin.y += rect.origin.y + stroke / 2;
    
    CGFloat glossTopRadius = radius - stroke / 2;
    CGFloat glossBottomRadius = radius / 1.5;
    
        //Create Path For Gloss
	CGMutablePathRef glossPath = CGPathCreateMutable();
	CGPathMoveToPoint(glossPath, NULL, glossRect.origin.x, glossRect.origin.y + glossTopRadius);
	CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x, glossRect.origin.y + glossRect.size.height - glossBottomRadius);
	CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossBottomRadius, glossRect.origin.y + glossRect.size.height - glossBottomRadius, glossBottomRadius, M_PI, M_PI / 2, 1);
	CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossBottomRadius, glossRect.origin.y + glossRect.size.height);
	CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossBottomRadius, glossRect.origin.y + glossRect.size.height - glossBottomRadius, glossBottomRadius, M_PI / 2, 0.0f, 1);
	CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossRect.size.width, glossRect.origin.y + glossTopRadius);
	CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossTopRadius, glossRect.origin.y + glossTopRadius, glossTopRadius, 0.0f, -M_PI / 2, 1);
	CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossTopRadius, glossRect.origin.y);
	CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossTopRadius, glossRect.origin.y + glossTopRadius, glossTopRadius, -M_PI / 2, M_PI, 1);
	CGPathCloseSubpath(glossPath);
    
        //Fill Gloss Path    
    CGContextAddPath(context, glossPath);
    CGContextClip(context);
    CGFloat colors[] =
    {
        1, 1, 1, .3,
        1, 1, 1, .1,
    };
    CGFloat locations[] = { 0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, colors, locations, 2);
    CGPoint startPoint = glossRect.origin;
    CGPoint endPoint = CGPointMake(glossRect.origin.x, glossRect.origin.y + glossRect.size.height);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
        //Gradient Stroke Gloss Path    
    CGContextAddPath(context, glossPath);
    CGContextSetLineWidth(context, 2);
    CGContextReplacePathWithStrokedPath(context);
    CGContextClip(context);
    CGFloat colors2[] =
    {
        1, 1, 1, .3,
        1, 1, 1, .1,
        1, 1, 1, .0,
    };
    CGFloat locations2[] = { 0, .1, 1.0 };
    CGGradientRef gradient2 = CGGradientCreateWithColorComponents(space, colors2, locations2, 3);
    CGPoint startPoint2 = glossRect.origin;
    CGPoint endPoint2 = CGPointMake(glossRect.origin.x, glossRect.origin.y + glossRect.size.height);
    CGContextDrawLinearGradient(context, gradient2, startPoint2, endPoint2, 0);
    
        //Cleanup
    CGPathRelease(path);
    CGPathRelease(glossPath);
    CGColorSpaceRelease(space);
    CGGradientRelease(gradient);
    CGGradientRelease(gradient2);
}

- (CGFloat)relativeParentXPosition {
    if (!_mapView || !_parentAnnotationView)
        return 0;
    CGPoint parentOrigin = [self.mapView convertPoint:self.parentAnnotationView.frame.origin fromView:self.parentAnnotationView.superview];
    return parentOrigin.x + self.offsetFromParent.x;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_contentView];
    }
    return _contentView;
}

@end
