@import <AppKit/CPView.j>
@import <Foundation/CPNotificationCenter.j>

@import "KFDNodeView.j"

var SharedEditorView            = nil,
    HandleSize                  = 7.0;

@implementation KFDEditorView : CPView
{
    KFDNodeView     nodeView        @accessors;
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
    [self setFrame:CGRectMake(bounds.origin.x-8, bounds.origin.y-8, bounds.size.width+16, bounds.size.height+16)];
}


- (void)drawRect:(CGRect)rect
{
    var bounds = CGRectInset([self bounds], 5.0, 5.0),
        context = [[CPGraphicsContext currentContext] graphicsPort];
    
    console.debug(bounds);
    CGContextSetStrokeColor(context, [CPColor grayColor]);
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokeRect(context, bounds);
    
    [self drawHandles:rect];
}

- (void)drawHandles:(CGRect)rect
{
    console.debug("drawHandles");
    console.debug(rect);
    
    var topLeftPoint        = CGPointMake(rect.origin.x, rect.origin.y),
        topRigthPoint       = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y),
        bottomRightPoint    = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
        bottomLeftPoint     = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
    
    var topLeftHandle       = CGRectMake(topLeftPoint.x, topLeftPoint.y, HandleSize, HandleSize),
        topRightHandle      = CGRectMake(topRigthPoint.x - HandleSize, topRigthPoint.y, HandleSize, HandleSize),
        bottomRightHandle   = CGRectMake(bottomRightPoint.x - HandleSize, bottomRightPoint.y - HandleSize, HandleSize, HandleSize),
        bottomLeftHandle    = CGRectMake(bottomLeftPoint.x, bottomLeftPoint.y - HandleSize, HandleSize, HandleSize);
    
    var context = [[CPGraphicsContext currentContext] graphicsPort];
    
    CGContextSetFillColor(context, [CPColor blackColor]);
    CGContextFillRect(context, topLeftHandle);
    CGContextFillRect(context, topRightHandle);
    CGContextFillRect(context, bottomRightHandle);
    CGContextFillRect(context, bottomLeftHandle);
}

@end