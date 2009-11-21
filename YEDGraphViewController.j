@import <AppKit/CPViewController.j>
@import "YEDGraph.j"
@import "YEDGraphView.j"
@import "YEDNodeViewRegistry.j"
@import "YEDSelectionManager.j"

@implementation YEDGraphViewController : CPViewController 
{
    YEDNodeViewRegistry     nodeViewRegistry    @accessors;
    YEDSelectionManager     selectionManager    @accessors;
    BOOL                    viewAlreadyAdded;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        nodeViewRegistry = [YEDNodeViewRegistry registry];
        viewAlreadyAdded = NO;
    }
    return self;
}

// - (void)loadRepresentedObject
// {
//     [self setRepresentedObject: [YEDGraph graph]];
// }

- (void)loadView
{
    if(_view)
        return;
    
    _view = [[YEDGraphView alloc] init];
}

- (void)_loadNodeViewsFromGraph
{
    if(!_representedObject)
        return;
    
    [[self view] removeAllSubviews];
    
    var nodeIter = [[[self representedObject] nodes] objectEnumerator];
    var node = nil;
    while(node = [nodeIter nextObject])
    {
        if(![self viewForNode:node])
            [self addNodeToView:node];
        
        var edgeIter = [[node outEdges] objectEnumerator],
            endNode = nil;
        
        while(endNode = [edgeIter nextObject])
        {
            [self addEdgeToViewFrom:node to:endNode];
        }
    }
}

- (void)_setupObservers
{
    var center = [CPNotificationCenter defaultCenter];
    var graph = [self representedObject];
    
    // Observe changes in the graph
    [center addObserver:self 
            selector:@selector(graphNodeAdded:) 
            name:YEDGraphNodeAddedNotification
            object:graph];
    [center addObserver:self
            selector:@selector(graphNodeRemoved:)
            name:YEDGraphNodeRemovedNotification
            object:graph];
    [center addObserver:self
            selector:@selector(graphEdgeAdded:)
            name:YEDGraphEdgeAddedNotification
            object:graph];
    [center addObserver:self
            selector:@selector(graphEdgeRemoved:)
            name:YEDGraphEdgeRemovedNotification
            object:graph];
    
    // Observe changes in the graph view
    [center addObserver:self
            selector:@selector(graphViewNodeViewAdded:)
            name:YEDGraphViewNodeViewAddedNotification
            object:[self view]];
    [center addObserver:self
            selector:@selector(graphViewNodeViewRemoved:)
            name:YEDGraphViewNodeViewRemovedNotification
            object:[self view]];
    [center addObserver:self
            selector:@selector(graphViewEdgeViewAdded:)
            name:YEDGraphViewEdgeViewAddedNotification
            object:[self view]];
    [center addObserver:self
            selector:@selector(graphViewEdgeViewRemoved:)
            name:YEDGraphViewEdgeViewRemovedNotification
            object:[self view]];
}

- (void)_removeObservers
{
    var center = [CPNotificationCenter defaultCenter];
    var graph = [self representedObject];
    
    // Stop observing changes in the graph
    [center removeObserver:self
            name:YEDGraphNodeAddedNotification
            object:graph];
    [center removeObserver:self
            name:YEDGraphNodeRemovedNotification
            object:graph];
    [center removeObserver:self
            name:YEDGraphEdgeAddedNotification
            object:graph];
    [center removeObserver:self
            name:YEDGraphEdgeRemovedNotification
            object:graph];
            
    // Stop observing changes in the graph view
    [center removeObserver:self
            name:YEDGraphViewNodeViewAddedNotification
            object:[self view]];
    [center removeObserver:self
            name:YEDGraphViewNodeViewRemovedNotification
            object:[self view]];
    [center removeObserver:self
            name:YEDGraphViewEdgeViewAddedNotification
            object:[self view]];
    [center removeObserver:self
            name:YEDGraphViewEdgeViewRemovedNotification
            object:[self view]];
}

- (CPArray)nodeViews
{
    return [[self view] nodeViews];
}

- (CPArray)edgeViews
{
    return [[self view] edgeViews];
}

- (void)addNodeToView:(YEDNode)node
{
    // If the node isn't already in the graph, we don't want to add it to the view
    if(![[self graph] containsNode:node] || viewAlreadyAdded)
        return;
    
    var view = [self viewForNode:node] || [nodeViewRegistry viewFor:node];
    CPLog.trace("YEDGraphViewController: addNodeToView:")
    //console.debug(view);
    
    // If the nodeView is already in the graphView, bail
    if([[[self view] nodeViews] containsObject:view])
        return;
    
    var graphCenter = [[self view] center];
    [view setCenter: [[self view] convertPoint:graphCenter fromView:nil]];
    
    var randPointShift = function(point, scale)
    {
        scale = scale || 100;
        var randX = (Math.random() - 0.5) * scale,
            randY = (Math.random() - 0.5) * scale;
        return CGPointMake(point.x + randX, point.y + randY);
    };
    
    var origin = [view frameOrigin];
    [view setFrameOrigin:randPointShift(origin, 200)];
    [[self view] addNodeView:view];
}

- (void)removeNodeFromView:(YEDNode)node
{
    CPLog.trace("YEDGraphViewController: removeNodeFromView:")
    // If the node is still in the graph, we don't want to remove it from the view
    if([[self graph] containsNode:node])
        return;
    // Find the nodeview associated with this node and remove it
    var view = [self viewForNode:node];
    //console.debug(view);
    [view removeFromSuperview];
}

- (YEDNodeView)viewForNode:(YEDNode)node
{
    // if(![[self graph] containsNode:node])
    //     return;
    
    var viewIter = [[self nodeViews] objectEnumerator];
    var view = nil
    while(view = [viewIter nextObject])
    {
        if([[view representedObject] isEqual:node])
        {
            return view;
        }
    }
    return nil;
}

- (YEDEdgeView)viewForEdgeFromNode:(YEDNode)start toNode:(YEDNode)end
{
    var viewIter = [[self edgeViews] objectEnumerator],
        view = nil;
    
    while(view = [viewIter nextObject])
    {
        var startNode = [[view startNodeView] representedObject],
            endNode   = [[view endNodeView] representedObject];
        if(startNode === start && endNode === end)
            return view;
    }
}

- (void)addEdgeToViewFrom:(YEDNode)start to:(YEDNode)end
{
    CPLog.trace("YEDGraphViewController: addEdgeToViewFrom:to:");
    //console.debug(start, end);
    CPLog.trace([[self graph] containsEdgeFromNode:start toNode:end]);
    if(![[self graph] containsEdgeFromNode:start toNode:end] || viewAlreadyAdded)
        return;
    
    CPLog.trace("YEDGraphViewController: addEdgeToViewFrom:to: retrieving views");
    var startView = [self viewForNode:start],
        endView = [self viewForNode:end];
    if(!startView)
    {
        [self addNodeToView:start];
        startView = [self viewForNode:start];
    }
    if(!endView)
    {
        [self addNodeToView:end];
        endView = [self viewForNode:end];
    }

    if(!startView || !endView)
        return;
    
    CPLog.trace("YEDGraphViewController: addEdgeToViewFrom:to: creating Edge View");
    //console.debug([self viewForEdgeFromNode:start toNode:end]);
    var edgeView = [self viewForEdgeFromNode:start toNode:end] || [YEDEdgeView edgeFromView:startView toView:endView];
    
    if(![[self edgeViews] containsObject:edgeView])
        [[self view] addEdgeView:edgeView];
}

- (void)removeEdgeFromViewFrom:(YEDNode)start to:(YEDNode)end
{
    if([[self graph] containsEdgeFromNode:start toNode:end])
        return;
    
    var startView = [self viewForNode:start],
        endView = [self viewForNode:end];
    
    if(!startView || !endView)
        return;
    
    var view = [self viewForEdgeFromNode:start toNode:end];
        

    if([view startNodeView] === startView && [view endNodeView] === endView)
    {
        [view setStartNodeView:nil];
        [view setEndNodeView:nil];
        [view removeFromSuperview];
    }
}

- (void)setRepresentedObject:(id)object
{
    if([self representedObject])
    {
        [self _removeObservers];
    }
    [super setRepresentedObject:object];
    
    [self _loadNodeViewsFromGraph];
    [self _setupObservers];
}

- (void)graph
{
    return [self representedObject];
}

- (void)setGraph:(YEDGraph)aGraph
{
    [self willChangeValueForKey:@"graph"];
    [self setRepresentedObject:aGraph];
    [self didChangeValueForKey:@"graph"];
}

@end

@implementation YEDGraphViewController (NotificationHandlers)
/**
 Handlers for graph changes
 */
- (void)graphNodeAdded:(CPNotification)notification
{
    var node = [[notification userInfo] objectForKey:"node"];
    [self addNodeToView:node];
}

- (void)graphNodeRemoved:(CPNotification)notification
{
    var node = [[notification userInfo] objectForKey:"node"];
    [self removeNodeFromView:node];
}

- (void)graphEdgeAdded:(CPNotification)notification
{
    CPLog.trace("YEDGraphViewController: graphEdgeAdded");
    var startNode = [[notification userInfo] objectForKey:"fromNode"],
        endNode = [[notification userInfo] objectForKey:"toNode"];
    [self addEdgeToViewFrom:startNode to:endNode];
}

- (void)graphEdgeRemoved:(CPNotification)notification
{
    CPLog.trace("YEDGraphViewController: graphEdgeRemoved");
    var startNode = [[notification userInfo] objectForKey:"fromNode"],
        endNode = [[notification userInfo] objectForKey:"toNode"];
    [self removeEdgeFromViewFrom:startNode to:endNode];
}

/**
 Handlers for graph view changes
 */
- (void)graphViewNodeViewAdded:(CPNotification)notification
{
    CPLog.trace("graphViewNodeViewAdded:");
    
    var graphView = [notification object],
        nodeView  = [[notification userInfo] valueForKey:@"nodeView"],
        node      = [nodeView representedObject];
    
    if(!node)
    {
        CPLog.error("The nodeView added does not have a node. Removing the nodeView.");
        [nodeView removeFromSuperview];
        return;
    }
        
    
    if(![[self representedObject] containsNode:node])
    {
        viewAlreadyAdded = YES;
        [[self representedObject] addNode:node];
        viewAlreadyAdded = NO;
    }
}

- (void)graphViewNodeViewRemoved:(CPNotification)notification
{
    CPLog.trace("graphViewNodeViewRemoved:");
    
    var graphView   = [notification object],
        nodeView    = [[notification userInfo] valueForKey:@"nodeView"],
        node        = [nodeView representedObject];
    
    if(!node)
    {
        CPLog.error("The nodeView removed does not have a node. Not modifying graph.");
        return;
    }
    
    if([[self representedObject] containsNode:node])
    {
        [[self representedObject] removeNode:node];
    }
}

- (void)graphViewEdgeViewAdded:(CPNotification)notification
{
    CPLog.trace("graphViewEdgeViewAdded:");
    
    var graphView = [notification object],
        graph     = [self representedObject],
        edgeView  = [[notification userInfo] valueForKey:@"edgeView"],
        startNode = [[notification userInfo] valueForKey:@"startNode"],
        endNode   = [[notification userInfo] valueForKey:@"endNode"];
    
    try
    {
        viewAlreadyAdded = YES;
        [graph createDirectedEdgeFrom:startNode to:endNode];
        viewAlreadyAdded = NO;
    }
    catch(err)
    {
        CPLog.warn(err);
        //console.debug(startNode);
        //console.debug(endNode);
        alert(err);
        [edgeView removeFromSuperview];
        viewAlreadyAdded = NO;
    }
}

- (void)graphViewEdgeViewRemoved:(CPNotification)notification
{
    CPLog.trace("graphViewEdgeViewRemoved:");
}

@end

@implementation YEDGraphViewController (SelectionManager)

/**
 Delegate method that informs the selection manager if it should handle 
 the view item it recieved in a selection notification.
*/
- (BOOL)selectionManager:(YEDSelectionManager)manager shouldHandle:(id)item
{
    var view = [self view];
    return [[view subviews] containsObject:item];
}

/**
 Methods for interacting with the current selection
 */
- (CPArray)selectedViews
{
    //console.debug([[[selectionManager selectedItems] allObjects] copy]);
    return [[[selectionManager selectedItems] allObjects] copy];
}

- (CPArray)selectedViewsOfType:(id)classType
{
    var selectedViews       = [self selectedViews],
        selectedTypeViews   = [CPArray array],
        viewIter            = [selectedViews objectEnumerator],
        currentView         = nil;
    
    while(currentView = [viewIter nextObject])
    {
        if([currentView isKindOfClass:classType])
            [selectedTypeViews addObject:currentView];
    }
    return selectedTypeViews;
}

- (CPArray)selectedNodeViews
{
    return [self selectedViewsOfType:YEDNodeView];
}

- (CPArray)selectedEdgeViews
{
    return [self selectedViewsOfType:YEDEdgeView];
}

- (CPArray)selectedNodes
{
    var selectedNodeViews   = [self selectedNodeViews],
        viewIter            = [selectedNodeViews objectEnumerator],
        currentView         = nil,
        selectedNodes       = [CPArray array],
        node                = nil;
    
    while(currentView = [viewIter nextObject])
    {
        node = [currentView representedObject];
        if(node)
            [selectedNodes addObject:node];
            
    }
    return selectedNodes;
}

- (void)deleteSelected
{
    var graph = [self representedObject],
        selectedEdgeViews = [self selectedEdgeViews],
        selectedNodes = [self selectedNodes];
    //console.debug(graph);
    //console.debug(selectedEdgeViews);
    //console.debug(selectedNodes);
    var edgeViewIter = [selectedEdgeViews objectEnumerator],
        edgeView = nil,
        edgeStartNode = nil,
        edgeEndNode = nil;
    
    while(edgeView = [edgeViewIter nextObject])
    {
        edgeStartNode = [[edgeView startNodeView] representedObject];
        edgeEndNode = [[edgeView endNodeView] representedObject];
        
        [graph removeDirectedEdgeFrom:edgeStartNode to:edgeEndNode];
    }
    
    var nodeIter = [selectedNodes objectEnumerator],
        node = nil;
    
    while(node = [nodeIter nextObject])
    {
        [graph removeNode:node];
    }
    
}
@end