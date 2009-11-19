@import <AppKit/CPBezierPath.j>
@import <AppKit/CPView.j>
@import <Foundation/CPNotificationCenter.j>

@import "YEDNodeView.j"

var intersectLineLine = function(a1, a2, b1, b2) 
{
    var ua_t = (b2.x - b1.x) * (a1.y - b1.y) - (b2.y - b1.y) * (a1.x - b1.x);
    var ub_t = (a2.x - a1.x) * (a1.y - b1.y) - (a2.y - a1.y) * (a1.x - b1.x);
    var u_b  = (b2.y - b1.y) * (a2.x - a1.x) - (b2.x - b1.x) * (a2.y - a1.y);

    if ( u_b != 0 ) {
        var ua = ua_t / u_b;
        var ub = ub_t / u_b;

        if ( 0 <= ua && ua <= 1 && 0 <= ub && ub <= 1 ) {
            result = {type:"intersection", points:[]};
            result.points.push(
                {
                    x: a1.x + ua * (a2.x - a1.x),
                    y: a1.y + ua * (a2.y - a1.y)
                }
            );
        } else {
            result = {type:"none", points:[]};
        }
    } else {
        if ( ua_t == 0 || ub_t == 0 ) {
            result = {type:"coincident", points:[]};
        } else {
            result = {type:"parallel", points:[]};
        }
    }
    return result;
};

var intersectLineRect = function(a1, a2, rect) {
    var min        = rect.origin;
    var max        = {x:rect.origin.x+rect.size.width, y:rect.origin.y+rect.size.height};
    var topRight   = {x:max.x, y:min.y };
    var bottomLeft = {x:min.x, y:max.y };
    
    var inter1 = intersectLineLine(min, topRight, a1, a2);
    var inter2 = intersectLineLine(topRight, max, a1, a2);
    var inter3 = intersectLineLine(max, bottomLeft, a1, a2);
    var inter4 = intersectLineLine(bottomLeft, min, a1, a2);
    
    var result = {type:"none", points:[]};
    
    result.points = result.points.concat(inter1.points);
    result.points = result.points.concat(inter2.points);
    result.points = result.points.concat(inter3.points);
    result.points = result.points.concat(inter4.points);
    
    if ( result.points.length > 0 )
        result.type = "intersection";

    return result;
};

var Padding = 20;


@implementation YEDEdgeView : CPView
{
    YEDNodeView     startNodeView       @accessors;
    YEDNodeView     endNodeView         @accessors;
    CPColor         strokeColor         @accessors;
    BOOL            isSelected          @accessors;
}

+ (id)edgeFromView:(YEDNodeView)start toView:(YEDNodeView)end
{
    return [[self alloc] initEdgeFromView:start toView:end];
}

- (id)initEdgeFromView:(YEDNodeView)start toView:(YEDNodeView)end
{
    self = [self init];
    if(self)
    {
        [self setStartNodeView:start];
        [self setEndNodeView:end];
        [self setStrokeColor:[CPColor blackColor]];
    }
    return self;
}

- (void)setStartNodeView:(YEDNodeView)start
{
    if(startNodeView === start)
        return;
    
    var center = [CPNotificationCenter defaultCenter];
    
    if(startNodeView)
    {
        [center removeObserver:self
                name:CPViewFrameDidChangeNotification
                object:startNodeView];
    }
    
    [self willChangeValueForKey:@"startNodeView"];
    startNodeView = start;
    [self didChangeValueForKey:@"startNodeView"];
    
    if(startNodeView)
    {
        [center addObserver:self
                selector:@selector(nodeViewFrameChanged:)
                name:CPViewFrameDidChangeNotification
                object:startNodeView];
        
        [self nodeViewFrameChanged:nil];
        
        [[startNodeView superview] addSubview:self];
        [[startNodeView superview] addSubview:startNodeView];
        if(endNodeView)
            [[endNodeView superview] addSubview:endNodeView];
    }
    else
    {
        [self removeFromSuperview];
    }
}

- (void)setEndNodeView:(YEDNodeView)endView
{
    if(endNodeView === endView)
        return;
    
    var center = [CPNotificationCenter defaultCenter];
    
    if(endNodeView)
    {
        [center removeObserver:self
                name:CPViewFrameDidChangeNotification
                object:endNodeView];
    }
    
    [self willChangeValueForKey:@"endNodeView"];
    endNodeView = endView
    [self didChangeValueForKey:@"endNodeView"];
    
    if(endNodeView)
    {
        [center addObserver:self
                selector:@selector(nodeViewFrameChanged:)
                name:CPViewFrameDidChangeNotification
                object:endNodeView];
        
        [self nodeViewFrameChanged:nil];
        
        [[endNodeView superview] addSubview:self];
        [[endNodeView superview] addSubview:endNodeView];
        if(startNodeView)
            [[startNodeView superview] addSubview:startNodeView];
    }
    else
    {
        [self removeFromSuperview];
    }
}

- (void)mouseDown:(CPEvent)event
{
    var location = [self convertPoint:[event locationInWindow] fromView:nil];
    var onEdge = [self containsPoint:location];
    if(onEdge)
    {
        CPLog.trace("Selecting Edge");
        [[CPNotificationCenter defaultCenter] 
            postNotificationName:"YEDSelectedItemNotification"
            object:self
            userInfo:[CPDictionary dictionaryWithJSObject:{
                "mouseDown":event
            }]];
    }
    else
        [super mouseDown:event];

}

- (id)hitTest:(CGPoint)point
{   
    if([self containsPoint:[self convertPoint:point fromView:[self superview]]])
        return self;
    else
        return nil;
}

- (BOOL)containsPoint:(CGPoint)point
{
    var A = [self convertPoint:[startNodeView center] fromView:[self superview]],
        B = [self convertPoint:[endNodeView center] fromView:[self superview]];
    
    var slope = (B.y - A.y)/(B.x - A.x);
    
    var x = point.x,
        y = point.y;
    
    var Y = slope*(x - A.x) + A.y;
    var X = (y - A.y)/slope + A.x
    
    return ((Y-10 <= y) && (y <= Y+10)) || ((X-10 <= x) && (x <= X+10));
}

- (void)nodeViewFrameChanged:(CPNotification)notification
{
    if(!startNodeView || !endNodeView)
        return;
    // CPLog.trace("YEDEdgeView: startNodeViewFrameChanged:");
    var startCenter = [startNodeView center],
        endOrigin = [endNodeView center],
        delta = CGPointMake(endOrigin.x - startCenter.x, endOrigin.y - startCenter.y),
        frame = CGRectMakeZero();
    
    var minXPoint = startCenter.x <= endOrigin.x ? startCenter.x : endOrigin.x,
        minYPoint = startCenter.y <= endOrigin.y ? startCenter.y : endOrigin.y,
        maxXPoint = startCenter.x >= endOrigin.x ? startCenter.x : endOrigin.x,
        maxYPoint = startCenter.y >= endOrigin.y ? startCenter.y : endOrigin.y;
    
    var width = Math.abs(maxXPoint-minXPoint),
        height = Math.abs(maxYPoint-minYPoint);
    
    // width = width < 20 ? 20 : width;
    // height = height < 20 ? 20 : height;
    // CPLog.trace("w = %s, h = %s", width, height);
    
    frame = CGRectMake(minXPoint,
                       minYPoint,
                       width,
                       height);
    
    [self setFrame:CGRectInset(frame, -Padding, -Padding)];
    [self setNeedsDisplay:YES];
}

- (void)setIsSelected:(BOOL)selected
{
    if(isSelected === selected)
        return;
    
    [self willChangeValueForKey:@"isSelected"];
    isSelected = selected;
    [self didChangeValueForKey:@"isSelected"];
    
    if(isSelected)
    {
        [self setStrokeColor:[CPColor redColor]];
        [self setNeedsDisplay:YES];
    }
    else
    {
        [self setStrokeColor:[CPColor blackColor]];
        [self setNeedsDisplay:YES];
    }
}

- (id)drawRect:(CGRect)rect
{
    // CPLog.trace("YEDEdgeView drawRect:");
    if(!startNodeView || !endNodeView)
        return;
    
    var rect = CPRectInset(rect, Padding, Padding);
    // CPLog.trace("YEDEdgeView: drawing edge");
    var startPoint = [self convertPoint:[startNodeView center] fromView:[self superview]],
        endPoint = [self convertPoint:[endNodeView center] fromView:[self superview]],
        context = [[CPGraphicsContext currentContext] graphicsPort];
    
    
    CGContextSetStrokeColor(context, [self strokeColor]);
    CGContextSetLineWidth(context, 3.0);
    
    var path = [CPBezierPath bezierPath];
    [path setLineWidth:2.0];
    [path moveToPoint:startPoint];
    [path lineToPoint:endPoint];
    
    [path stroke];
    
    
    

    var intersection = intersectLineRect([startNodeView center], [endNodeView center], [endNodeView frame]);
    if(intersection.type === "intersection")
    {
        // console.log(intersection);
        var pt = intersection.points[0];
        // console.log(pt);
        // var point = [self convertPoint:CGPointMake(pt.x,pt.y) fromView:nil];
        var point = [self convertPoint:CGPointMake(pt.x,pt.y) fromView:[self superview]];
        // CPLog.trace("Marker at: ("+point.x+", "+point.y+")");
        var markerRect = CGRectMake(point.x-7,point.y-7,14,14);
        console.debug(markerRect);
        CGContextSetFillColor(context, [self strokeColor]);
        CGContextFillEllipseInRect(context, markerRect);
        
    }
}


@end