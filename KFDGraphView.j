@import <AppKit/CPView.j>

@implementation KFDGraphView : CPView
{
    id          controller                @accessors;
}

- (void)addNodeView:(KFDNodeView)aNodeView
{
    if([[self subviews] containsObject:aNodeView])
        return;
    
    [self addSubview:aNodeView];
}

- (void)removeNodeView:(KFDNodeView)aNodeView
{
    if(![[self subviews] containsObject:aNodeView])
        return;
    [aNodeView removeFromSuperview];
}

- (void)addEdgeView:(KFDEdgeView)edgeView
{
    if([[self subviews] containsObject:edgeView])
        return;
    
    [self addSubview:edgeView];
}

- (void)removeEdgeView:(KFDEdgeView)edgeView
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
    var nodeView = [CPKeyedUnarchiver unarchiveObjectWithData:[[aSender draggingPasteboard] dataForType:KFDNodeViewDragType]],
        location = [self convertPoint:[aSender draggingLocation] fromView:nil];
        
    [nodeView setFrameOrigin:CGPointMake(location.x - CGRectGetWidth([nodeView frame])/2.0, location.y - CGRectGetHeight([nodeView frame])/2.0)];
    [self addNodeView:nodeView];
    if([controller respondsToSelector:@selector(addedNodeView:toGraphView:)])
        [controller addedNodeView:nodeView toGraphView:self];
}

- (void)mouseDown:(CPEvent)anEvent
{
    [[KFDEditorView sharedEditor] setNodeView:nil];
}

@end