@import <AppKit/CPView.j>
@import <Foundation/CPNotificationCenter.j>

@import "YEDEdgeView.j"
@import "YEDNodeView.j"

YEDGraphViewNodeViewAddedNotification       = @"YEDGraphViewNodeViewAddedNotification",
YEDGraphViewNodeViewRemovedNotification     = @"YEDGraphViewNodeViewRemovedNotification",
YEDGraphViewEdgeViewAddedNotification       = @"YEDGraphViewEdgeViewAddedNotification",
YEDGraphViewEdgeViewRemovedNotification     = @"YEDGraphViewEdgeViewRemovedNotification";

@implementation YEDGraphView : CPView
{
    id          controller                @accessors;
}

- (void)addNodeView:(YEDNodeView)aNodeView
{
    if([[self subviews] containsObject:aNodeView])
        return;
    
    [self addSubview:aNodeView];
    
    [[CPNotificationCenter defaultCenter] 
        postNotificationName:YEDGraphViewNodeViewAddedNotification
        object:self
        userInfo:[CPDictionary dictionaryWithJSObject:{
            "nodeView": aNodeView,
            "node": [aNodeView representedObject]
        }]];
}

- (void)removeNodeView:(YEDNodeView)aNodeView
{
    if(![[self subviews] containsObject:aNodeView])
        return;
    [aNodeView removeFromSuperview];
    
    [[CPNotificationCenter defaultCenter] 
        postNotificationName:YEDGraphViewNodeViewRemovedNotification
        object:self
        userInfo:[CPDictionary dictionaryWithJSObject:{
            "nodeView": aNodeView,
            "node": [aNodeView representedObject]
        }]];
}

- (void)addEdgeView:(YEDEdgeView)edgeView
{
    if([[self subviews] containsObject:edgeView])
        return;
    
    [self addSubview:edgeView];
    
    [[CPNotificationCenter defaultCenter] 
        postNotificationName:YEDGraphViewEdgeViewAddedNotification
        object:self
        userInfo:[CPDictionary dictionaryWithJSObject:{
            "edgeView": edgeView,
            "startNode": [[edgeView startNodeView] representedObject],
            "endNode": [[edgeView endNodeView] representedObject]
        }]];
}

- (void)removeEdgeView:(YEDEdgeView)edgeView
{
    if(![[self subviews] containsObject:edgeView])
        return
        
    [edgeView removeFromSuperview];
    
    [[CPNotificationCenter defaultCenter] 
        postNotificationName:YEDGraphViewEdgeViewRemovedNotification
        object:self
        userInfo:[CPDictionary dictionaryWithJSObject:{
            "edgeView": edgeView,
            "startNode": [[edgeView startNodeView] node],
            "endNode": [[edgeView endNodeView] node]
        }]];
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
    [[CPNotificationCenter defaultCenter] 
        postNotificationName:"YEDSelectedItemNotification"
        object:nil
        userInfo:[CPDictionary dictionaryWithJSObject:{
            "mouseDown":anEvent
        }]];
}

@end