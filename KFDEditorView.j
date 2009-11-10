@import <AppKit/CPView.j>
@import <Foundation/CPNotificationCenter.j>

@import "CPView+OffsetCorners.j"
@import "KFDNodeView.j"

var SharedEditorView            = nil,
    HandleSize                  = 10.0,
    HandleSlop                  = 20.0,
    Margin                      = 15.0,
    Padding                     = 10.0;

var topLeftHandle       = CGRectMakeZero(),
    topRightHandle      = CGRectMakeZero(),
    bottomRightHandle   = CGRectMakeZero(),
    bottomLeftHandle    = CGRectMakeZero();

var sloppyHandle = function(rect)
{
    return CGRectInset(rect, -HandleSlop, -HandleSlop);
};

@implementation KFDEditorView : CPView
{
    KFDNodeView     nodeView        @accessors;
    BOOL            isResizing;
    CGPoint         resizeLocation;
}

+ (id)sharedEditor
{
    if(!SharedEditorView)
        SharedEditorView = [[KFDEditorView alloc] initWithFrame:CPRectMakeZero()];
    return SharedEditorView;
}

- (id)initWithFrame:(CPRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if(self)
    {
        
    }
    return self;
}

- (void)setNodeView:(KFDNodeView)aNodeView
{
    if(nodeView === aNodeView)
        return;
    
    CPLog.trace("KFDEditorView: setNodeView");
    var center = [CPNotificationCenter defaultCenter];
    
    if(nodeView)
    {
        [center removeObserver:self
                name:CPViewFrameDidChangeNotification
                object:nodeView];
    }
    
    [self willChangeValueForKey:@"nodeView"]
    nodeView = aNodeView;
    [self didChangeValueForKey:@"nodeView"];
    
    if(nodeView)
    {
        [center addObserver:self
                selector:@selector(nodeViewFrameChanged:)
                name:CPViewFrameDidChangeNotification
                object:nodeView];
        
        [self nodeViewFrameChanged:nil];
        
        [[nodeView superview] addSubview:self];
        [[nodeView superview] addSubview:nodeView];

    }
    else
    {
        [self removeFromSuperview];
    }
}

- (void)nodeViewFrameChanged:(CPNotification)notification
{
    var bounds = [nodeView frame];
    // [self setFrame:CGRectMake(bounds.origin.x-FrameOutset, bounds.origin.y-FrameOutset, bounds.size.width+(FrameOutset*2), bounds.size.height+(FrameOutset*2))];
    [self setFrame:CGRectInset(bounds, -(Margin+Padding), -(Margin+Padding))];
}



- (void)mouseDown:(CPEvent)event
{
    var location = [self convertPoint:[event locationInWindow] fromView:nil];
    // CPLog.trace("KFDEditorView: mouseDown");
    
    if(CGRectContainsPoint(sloppyHandle(topLeftHandle), location))
    {
        // CPLog.trace("KFDEditorView: topLeftHandle");
        isResizing = YES;
        resizeLocation = [event locationInWindow];
        
    }
    else if(CGRectContainsPoint(sloppyHandle(topRightHandle), location))
    {
        // CPLog.trace("KFDEditorView: topRightHandle");
        isResizing = YES;
        resizeLocation = [event locationInWindow];
        
    }
    else if(CGRectContainsPoint(sloppyHandle(bottomRightHandle), location))
    {
        // CPLog.trace("KFDEditorView: bottomRightHandle");
        isResizing = YES;
        resizeLocation = [event locationInWindow];
        
    }
    else if(CGRectContainsPoint(sloppyHandle(bottomLeftHandle), location))
    {
        // CPLog.trace("KFDEditorView: bottomLeftHandle");
        isResizing = YES;
        resizeLocation = [event locationInWindow];
        
    }
    else
    {
        [super mouseDown:event];
    }
}

- (void)mouseDragged:(CPEvent)event
{
    if(!isResizing)
        return;
        
    var handleLocation = [self convertPoint:[event locationInWindow] fromView:nil]
    
    var location = [event locationInWindow],
        dX = location.x - resizeLocation.x,
        dY = location.y - resizeLocation.y;
    
    // CPLog.trace("KFDEditorView: mouseDragged");
    // CPLog.trace("dX = " + dX);
    // CPLog.trace("dY = " + dY);
    
    if(CGRectContainsPoint(sloppyHandle(topLeftHandle), handleLocation))
    {
        [nodeView offsetFrameTopLeft:CGPointMake(dX,dY)];
    }
    else if(CGRectContainsPoint(sloppyHandle(topRightHandle), handleLocation))
    {
        [nodeView offsetFrameTopRight:CGPointMake(dX,dY)];
    }
    else if(CGRectContainsPoint(sloppyHandle(bottomRightHandle), handleLocation))
    {
        [nodeView offsetFrameBottomRight:CGPointMake(dX,dY)];
    }
    else if(CGRectContainsPoint(sloppyHandle(bottomLeftHandle), handleLocation))
    {
        [nodeView offsetFrameBottomLeft:CGPointMake(dX,dY)];
    }
    [self setNeedsDisplay:YES];
    resizeLocation = location;
}

- (void)mouseUp:(CPEvent)event
{
    if(!isResizing)
        return;
    
    isResizing = NO;
}

- (void)drawRect:(CGRect)rect
{
    var bounds = CGRectInset([self bounds], Margin, Margin),
        context = [[CPGraphicsContext currentContext] graphicsPort];
    
    CGContextSetStrokeColor(context, [CPColor grayColor]);
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokeRect(context, bounds);
    
    [self drawHandles:CGRectInset(bounds,-(HandleSize/2),-(HandleSize/2))];
}

- (void)drawHandles:(CGRect)rect
{
    
    var topLeftPoint        = CGPointMake(rect.origin.x, rect.origin.y),
        topRigthPoint       = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y),
        bottomRightPoint    = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
        bottomLeftPoint     = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
    
    var totalHandleSize = HandleSize + (HandleSlop*2);
    
    topLeftHandle       = CGRectMake(topLeftPoint.x, topLeftPoint.y, HandleSize, HandleSize);
    topRightHandle      = CGRectMake(topRigthPoint.x - HandleSize, topRigthPoint.y, HandleSize, HandleSize);
    bottomRightHandle   = CGRectMake(bottomRightPoint.x - HandleSize, bottomRightPoint.y - HandleSize, HandleSize, HandleSize);
    bottomLeftHandle    = CGRectMake(bottomLeftPoint.x, bottomLeftPoint.y - HandleSize, HandleSize, HandleSize);
    
    var context = [[CPGraphicsContext currentContext] graphicsPort];
    
    function drawHandle(rect)
    {
        // var newRect = CGRectMake(rect.origin.x,rect.origin.y, rect.size.width - HandleSlop*2, rect.size.height - HandleSlop*2);
        // CGContextFillEllipseInRect(context, rect);
        CGContextFillRect(context, rect);
        
        // CGContextFillEllipseInRect(context, rect);
    }
    
    CGContextSetFillColor(context, [CPColor blackColor]);
    drawHandle(topLeftHandle);
    drawHandle(topRightHandle);
    drawHandle(bottomRightHandle);
    drawHandle(bottomLeftHandle);
}

@end