@import <AppKit/CPPasteboard.j>
@import "YEDNodeView.j"

YEDNodeViewConnectorDragType = @"YEDNodeViewConnectorDragType";

@implementation YEDNodeViewConnector : CPView
{
    YEDNodeView     nodeView    @accessors;
    CPEvent         mouseDownEvent;
}

- (void)drawRect:(CGRect)rect
{
    var context = [[CPGraphicsContext currentContext] graphicsPort];
    
    CGContextSetFillColor(context, [CPColor yellowColor]);
    CGContextSetStrokeColor(context, [CPColor grayColor]);
    CGContextFillEllipseInRect(context, rect);
    CGContextStrokeEllipseInRect(context, rect);
}

- (void)mouseDown:(CPEvent)event
{
    mouseDownEvent = event;
}

- (void)mouseDragged:(CPEvent)event
{
    var dragTypes = [YEDNodeViewConnectorDragType];
    [[CPPasteboard pasteboardWithName:CPDragPboard] declareTypes:dragTypes owner:self];
    
    var dragView = [[YEDNodeViewConnector alloc] init];
    [dragView setFrame:CGRectMakeCopy([self frame])];
    
    [self dragView:dragView
            at:[dragView bounds].origin
            offset:CGSizeMakeZero()
            event:mouseDownEvent
            pasteboard:nil
            source:self
            slideBack:YES];
}

- (void)pasteboard:(CPPasteboard)aPasteboard provideDataForType:(CPString)aType
{
    if(aType === YEDNodeViewConnectorDragType)
        [aPasteboard setData:@"Retreive nodeView from drag source." forType:aType];
}
@end