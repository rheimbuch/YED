@import <AppKit/CPView.j>

@implementation YEDGraphView : CPView
{
    id          controller                @accessors;
}

- (void)addNodeView:(YEDNodeView)aNodeView
{
    if([[self subviews] containsObject:aNodeView])
        return;
    
    [self addSubview:aNodeView];
}

- (void)removeNodeView:(YEDNodeView)aNodeView
{
    if(![[self subviews] containsObject:aNodeView])
        return;
    [aNodeView removeFromSuperview];
}

- (void)addEdgeView:(YEDEdgeView)edgeView
{
    if([[self subviews] containsObject:edgeView])
        return;
    
    [self addSubview:edgeView];
}

- (void)removeEdgeView:(YEDEdgeView)edgeView
{
    if(![[self subviews] containsObject:edgeView])
        return
        
    [edgeView removeFromSuperview];
}

- (void)removeAllNodeViews
{
    var viewIter = [[self subviews] objectEnumerator];
    var view = nil;
    
    while(view = [viewIter nextObject])
    {
        [view removeFromSuperview];
    }
}

- (void)performDragOperation:(CPDraggingInfo)aSender
{
    var nodeView = [CPKeyedUnarchiver unarchiveObjectWithData:[[aSender draggingPasteboard] dataForType:YEDNodeViewDragType]],
        location = [self convertPoint:[aSender draggingLocation] fromView:nil];
        
    [nodeView setFrameOrigin:CGPointMake(location.x - CGRectGetWidth([nodeView frame])/2.0, location.y - CGRectGetHeight([nodeView frame])/2.0)];
    [self addNodeView:nodeView];
    if([controller respondsToSelector:@selector(addedNodeView:toGraphView:)])
        [controller addedNodeView:nodeView toGraphView:self];
}

- (void)mouseDown:(CPEvent)anEvent
{
    [[YEDEditorView sharedEditor] setNodeView:nil];
}

@end