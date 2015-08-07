//
//  RoutineView.m
//  dayRoutine
//
//  Created by James chan on 5/8/15.
//  Copyright (c) 2015 James` Awesome App House. All rights reserved.
//


#import "RoutineView.h"

@interface RoutineView()

@property (nonatomic) CGPoint centreP;
@property (nonatomic) CGFloat picScaleFactor;// for image/circule scale
@property (nonatomic) CGFloat CircuitExternalR;
@property (nonatomic) CGFloat CircuitMiddleR;
@property (nonatomic) CGFloat CircuitInternalR;

#define CIRCUIT_EXTERNAL_RADIUS 110
#define CIRCUIT_MIDDLE_RADIUS 100
#define CIRCUIT_INTERNAL_RADIUS 70

@end

@implementation RoutineView

#pragma mark - Properties

@synthesize picScaleFactor = _picScaleFactor;

- (CGFloat)picCardScaleFactor
{
    if (!_picScaleFactor) _picScaleFactor = DEFAULT_PIC_SCALE_FACTOR;
    return _picScaleFactor;
}

- (void)setPicCardScaleFactor:(CGFloat)picScaleFactor
{
    _picScaleFactor = picScaleFactor;
    [self setNeedsDisplay];
}

- (void)setActivities:(NSMutableArray *)activities
{
    _activities = activities;
    [self setNeedsDisplay];
}

- (void)setPic:(UIImage *)pic
{
    _pic = pic;
    [self setNeedsDisplay];
}

- (void)setDescrip:(NSString *)subTitle
{
    _subTitle = subTitle;
    [self setNeedsDisplay];

}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self setNeedsDisplay];
}

- (CGFloat)CircuitExternalR
{
    if (!_CircuitExternalR) _CircuitExternalR = CIRCUIT_EXTERNAL_RADIUS * self.picScaleFactor;
    return _CircuitExternalR;
}

- (CGFloat)CircuitMiddleR
{
    if (!_CircuitMiddleR) _CircuitMiddleR = CIRCUIT_MIDDLE_RADIUS * self.picScaleFactor;
    return _CircuitMiddleR;
}

- (CGFloat)CircuitInternalR
{
    if (!_CircuitInternalR) _CircuitInternalR = CIRCUIT_INTERNAL_RADIUS * self.picScaleFactor;
    return _CircuitInternalR;
}

// get the frame centre
- (CGPoint )centreP
{
    return CGPointMake(self.frame.size.width/2, self.frame.size.height * 4/7 );
}

#pragma mark - draw life routine circle

#define CORNER_FONT_STANDARD_HEIGHT 180.0
#define CORNER_RADIUS 12.0

- (CGFloat)cornerScaleFactor { return self.bounds.size.height / CORNER_FONT_STANDARD_HEIGHT; }
- (CGFloat)cornerRadius { return CORNER_RADIUS * [self cornerScaleFactor] ; }
- (CGFloat)cornerOffset { return [self cornerRadius] / 3.0; }

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:[self cornerRadius]];
    
    [roundedRect addClip];

    [[UIColor colorWithRed:206/255.0 green:206/255.0 blue:206/255.0 alpha:1.0] setFill];
    UIRectFill(self.bounds); 
    
    [[UIColor blackColor] setStroke];
    [roundedRect stroke];

    [self.pic drawInRect:CGRectMake(self.centreP.x - self.CircuitInternalR,
                                    self.centreP.y - self.CircuitInternalR,
                                    self.CircuitInternalR*2,self.CircuitInternalR*2)];
    
    for (int i = 0;i < [self.activities count];i = i+4){
        
        [self drawActivy:[self.activities[i] floatValue]
                 toAngle:[self.activities[i+1] floatValue]
               withColor:[self getDefinedColor:[self.activities[i+3] intValue]]];

        [self addActivityLabelFromAngle: [self TimeToRadian:[self.activities[i] floatValue]]
                                toAngle: [self TimeToRadian:[self.activities[i+1] floatValue]]
                            withRadious:self.CircuitExternalR
                             usedbyText:[NSString stringWithFormat:@"%@",self.activities[i+2] ]];
    }
    
    [self drawExternalCircuit];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.title;
    
    [titleLabel setFont:[UIFont fontWithName:@"Arial-BoldItalicMT" size:20 * self.picScaleFactor]];
    
    [titleLabel drawTextInRect:CGRectMake(self.centreP.x - [titleLabel.text length] * 10 * self.picScaleFactor,
                                          self.centreP.y - self.CircuitMiddleR - self.CircuitInternalR,
                                          [titleLabel.text length] * 20 * self.picScaleFactor , 5 * self.picScaleFactor)];
    titleLabel.text = self.subTitle;
    [titleLabel drawTextInRect:CGRectMake(self.centreP.x -[titleLabel.text length]* 5 * self.picScaleFactor,
                                         self.centreP.y - self.CircuitInternalR - self.CircuitInternalR  ,
                                          [titleLabel.text length] * 20* self.picScaleFactor ,5* self.picScaleFactor)];
}

- (void)addActivityLabelFromAngle:(CGFloat)startAngle
                          toAngle:(CGFloat)endAngle
                      withRadious:(CGFloat)iRadius
                       usedbyText:(NSString*)text
{
    endAngle = (startAngle + endAngle)/2;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    //get the middle point of the arc
    [bezierPath addArcWithCenter:self.centreP radius:iRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.text = text;
    
    [timeLabel setFont:[UIFont fontWithName:@"Helvetica" size:12* self.picScaleFactor]];
    
    double labelY = 0;
    double labelX = 0;
    
    if (endAngle < 0 || endAngle > M_PI)
        labelY = 0-10* self.picScaleFactor;
    else
        labelY = 10* self.picScaleFactor;
    
    if (endAngle >  0.5 * M_PI && endAngle < 1.5 * M_PI)
        labelX =  12 * [text length]* self.picScaleFactor ;
    else
        labelX = 0;
    
    [timeLabel drawTextInRect:CGRectMake(bezierPath.currentPoint.x - labelX ,
                                         bezierPath.currentPoint.y + labelY, [text length] * 20 * self.picScaleFactor,5 * self.picScaleFactor)];
}

//get defined color
- (UIColor*) getDefinedColor :(int) number
{
    if (number == 0){
        return [UIColor whiteColor];
    }if (number == 1){
        return [UIColor colorWithRed:248/255.0 green:184/255.0 blue:98/255.0 alpha:1.0];
    }if (number == 2){
        return [UIColor colorWithRed:114/255.0 green:174/255.0 blue:114/255.0 alpha:1.0] ;
    }if (number == 3){
        return [UIColor colorWithRed:57/255.0 green:187/255.0 blue:198/255.0 alpha:1.0] ;
    }if (number == 4){
        return [UIColor colorWithRed:188/255.0 green:224/255.0 blue:196/255.0 alpha:1.0] ;
    }else
        return nil;
}

//covert time to radian
- (CGFloat)TimeToRadian:(CGFloat)TimeFloat{return ((TimeFloat/6 -1) * 0.5 * M_PI);}


//draw activity
- (void)drawActivy:(CGFloat)startAngle toAngle:(CGFloat)endAngle withColor:(UIColor*) fillColor
{
    
    [self  drawCircuitFromAngle: [self TimeToRadian:startAngle]
                        toAngle: [self TimeToRadian:endAngle]
                  withFillColor: fillColor
                withStrokeColor: [UIColor whiteColor]
            FromExternalRadious: self.CircuitInternalR
               toInternalRadius: self.CircuitExternalR];
}

//draw the time circuit
- (void)drawExternalCircuit{
    
    for ( CGFloat s = 0; s <= 24 - CIRCUIT_INCREMENT; s = s + CIRCUIT_INCREMENT ){
        
        [self  drawCircuitFromAngle: [self TimeToRadian:s]
                            toAngle: [self TimeToRadian:s + CIRCUIT_INCREMENT]
                      withFillColor: Nil
                    withStrokeColor: [UIColor blackColor]
                FromExternalRadious: self.CircuitMiddleR
                   toInternalRadius: self.CircuitExternalR];
    }
    
    //draw 2 time label
    UILabel *timeLabel = [[UILabel alloc] init];
    
    [timeLabel setFont:[UIFont fontWithName:@"Arial" size:15 * self.picScaleFactor]];
    
    timeLabel.text = @"00:00";
    [timeLabel drawTextInRect:CGRectMake(self.centreP.x - 22.5 * self.picScaleFactor ,
                                         self.centreP.y - self.CircuitMiddleR * 0.9 ,
                                         45 * self.picScaleFactor, 10 * self.picScaleFactor)];
    
    timeLabel.text = @"12:00AM";
    [timeLabel drawTextInRect:CGRectMake(self.centreP.x - 31.5* self.picScaleFactor,
                                         self.centreP.y + self.CircuitMiddleR * 0.8 ,
                                         70 * self.picScaleFactor, 10 * self.picScaleFactor)];
    
}

- (void)drawCircuitFromAngle:(CGFloat)startAngle toAngle:(CGFloat)endAngle
               withFillColor:(UIColor*) fillColor withStrokeColor: (UIColor*) strokeColor
         FromExternalRadious:(CGFloat)iRadius  toInternalRadius:(CGFloat)eRadius
{
    UIBezierPath *bezierPathArc = [UIBezierPath bezierPath];
    
    //draw external/middle arc lines
    [bezierPathArc addArcWithCenter:self.centreP radius:iRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [bezierPathArc addArcWithCenter:self.centreP radius:eRadius startAngle:endAngle endAngle:startAngle clockwise:NO];
    
    //draw the last line by using arc drawing
    [bezierPathArc addArcWithCenter:self.centreP radius:iRadius startAngle:startAngle endAngle:startAngle clockwise:YES];
    
    [bezierPathArc setLineWidth:1.0];
    [strokeColor setStroke];
    [bezierPathArc stroke];
    
    //fill the color
    if (fillColor) {
        [fillColor setFill];
        [bezierPathArc fill];
    }
}

#pragma mark - Initialization

- (void)setup
{
    self.backgroundColor = nil;
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.picScaleFactor = frame.size.height/ DEFAULT_FRAME_LENGTH; //set up the scale factor
    [self setup];
    return self;
}

@end