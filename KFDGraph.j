@import <Foundation/CPObject.j>
@import <Foundation/CPSet.j>
@import <Foundation/CPException.j>
@import <Foundation/CPNotificationCenter.j>
@import "KFDNode.j"

// Exceptions
KFDGraphCannotCreateDirectedEdgeException = @"KFDGraphCannotCreateDirectedEdgeException";
KFDGraphNodeTypeNotAllowedException = @"KFDGraphNodeTypeNotAllowedException";

// Notifications
KFDGraphNodeAddedNotification = @"KFDGraphNodeAddedNotification";
KFDGraphNodeRemovedNotification = @"KFDGraphNodeRemovedNotification";
KFDGraphEdgeNotAllowedNotification = @"KFDGraphEdgeNotAllowedNotification";
KFDGraphEdgeWouldCauseCycleNotification = @"KFDGraphEdgeWouldCauseCycleNotification";
KFDGraphEdgeAddedNotification = @"KFDGraphEdgeAddedNotification";
KFDGraphEdgeRemovedNotification = @"KFDGraphEdgeRemovedNotification"

/*! @class KFDGraph
    ** Delegate Protocol **
    - (void)willAddNode:(KFDNode)aNode toGraph:(KFDGraph)aGraph
    - (void)didAddNode(KFDNode)aNode toGraph:(KFDGraph)aGraph
    - (void)willRemoveNode:(KFDNode)aNode fromGraph:(KFDGraph)aGraph
    - (void)didRemoveNode:(KFDNode)aNode fromGraph:(KFDGraph)aGraph
    - (void)willAddEdgeFromNode:(KFDNode)startNode toNode:(KFDNode)endNode inGraph:(KFDGraph)aGraph
    - (void)didAddEdge:(BOOL)edgeAdded fromNode:(KFDNode)startNode toNode:(KFDNode)endNode inGraph:(KFDGraph)aGraph
    - (void)willRemoveEdgeFromNode:(KFDNode)startNode toNode:(KFDNode)endNode inGraph:(KFDGraph)aGraph
    - (void)didRemoveEdge:(BOOL)edgeRemoved fromNode:(KFDNode)startNode toNode:(KFDNode)endNode inGraph:(KFDGraph)aGraph

*/

@implementation KFDGraph : CPObject
{
    CPSet   nodes       @accessors;
    CPSet   allowedNodeTypes;
    id      delegate    @accessors;
}


- (id)init
{
    self = [super init];
    if(self)
    {
        nodes = [CPSet set];
        allowedNodeTypes = [CPSet setWithObject:KFDNode];
    }
    return self;
}

- (id)initWithNodes:(CPArray)otherNodes
{
    var self = [self init];
    if(self)
    {
        var nodeIter = [otherNodes objectEnumerator];
        var otherNode = nil;
    
        while(otherNode = [nodeIter nextObject])
        {
            [self addNode:otherNode];
        }
    }
    return self;
}

+ (id)graph
{
    return [[self alloc] init];
}

+ (id)graphWithNodes:(CPArray)nodes
{
    return [[self alloc] initWithNodes:nodes];
}

- (void)addNode:(KFDNode)aNode
{
    if([self allowsNode:aNode]) 
    {
        if([delegate respondsToSelector:@selector(willAddNode:toGraph:)])
            [delegate willAddNode:aNode toGraph:self];
            
        [nodes addObject:aNode];
        
        [[CPNotificationCenter defaultCenter] 
            postNotificationName:KFDGraphNodeAddedNotification
            object:self
            userInfo:[CPDictionary dictionaryWithJSObject:{
                node:aNode
            }]];
        
        if([delegate respondsToSelector:@selector(didAddNode:toGraph:)])
            [delegate didAddNode:aNode toGraph:self];
    }
    else 
    {
        [CPException raise:KFDGraphNodeTypeNotAllowedException message:"The type of the added node is not allowed in this graph."];
    }
}

- (void)removeNode:(KFDNode)aNode
{
    if([nodes containsObject:aNode])
    {
        if([delegate respondsToSelector:@selector(willRemoveNode:fromGraph:)])
            [delegate willRemoveNode:aNode fromGraph:self];
            
        [aNode disconnectFromAllNodes];
        [nodes removeObject:aNode];
        
        [[CPNotificationCenter defaultCenter] 
            postNotificationName:KFDGraphNodeRemovedNotification
            object:self
            userInfo:[CPDictionary dictionaryWithJSObject:{
                node:aNode
            }]];
        
        if([delegate respondsToSelector:@selector(didRemoveNode:fromGraph:)])
            [delegate didRemoveNode:aNode fromGraph:self];
    }
}

- (void)createDirectedEdgeFrom:(KFDNode)fromNode to:(KFDNode)toNode
{ 
    // if(![nodes containsObject:fromNode])
    //     [self addNode:fromNode];
    // 
    // if(![nodes containsObject:toNode])
    //     [self addNode:toNode];
    
    // If the nodes aren't in the nodes set, then they aren't allowed
    if(![nodes containsObject:fromNode] || ![nodes containsObject:toNode])
    {
        [CPException raise:KFDGraphCannotCreateDirectedEdgeException reason:"One of the nodes is not in the graph."];
        return;
    }
        
    if([delegate respondsToSelector:@selector(willAddEdgeFromNode:toNode:inGraph:)])
        [delegate willAddEdgeFromNode:fromNode toNode:toNode inGraph:self];
    
    try
    {    
        [fromNode directedEdgeTo:toNode];
    }
    catch(err)
    {
        if([err name] === KFDNodeNotAllowedException)
        {
            if([delegate respondsToSelector:@selector(directedEdgeFromNode:toNode:isNotAllowedInGraph:)])
                [delegate directedEdgeFromNode:fromNode toNode:toNode isNotAllowedInGraph:self];
            
            [[CPNotificationCenter defaultCenter] 
                postNotificationName:KFDGraphEdgeNotAllowedNotification
                object:self
                userInfo:[CPDictionary dictionaryWithJSObject:{
                    fromNode:fromNode,
                    toNode:toNode
                }]];
                
            if([delegate respondsToSelector:@selector(didAddEdge:fromNode:toNode:inGraph:)])
                [delegate didAddEdge:NO fromNode:fromNode toNode:toNode inGraph:self];
            
            return;
        }
        else if([err name] === KFNodeCycleException)
        {
            if([delegate respondsToSelector:@selector(directedEdgeFromNode:toNode:wouldIntroduceCycleInGraph:)])
                [delegate directedEdgeFromNode:fromNode toNode:toNode wouldIntroduceCycleInGraph:self];
            
            [[CPNotificationCenter defaultCenter] 
                postNotificationName:KFDGraphEdgeWouldCauseCycleNotification
                object:self
                userInfo:[CPDictionary dictionaryWithJSObject:{
                    fromNode:fromNode,
                    toNode:toNode
                }]];
                
            if([delegate respondsToSelector:@selector(didAddEdge:fromNode:toNode:inGraph:)])
                [delegate didAddEdge:NO fromNode:fromNode toNode:toNode inGraph:self];
            
            return;
        }
        else
        {
            // Otherwise rethrow the error
            throw err;
        }
    }
    
    if([delegate respondsToSelector:@selector(didAddEdge:fromNode:toNode:inGraph:)])
        [delegate didAddEdge:YES fromNode:fromNode toNode:toNode inGraph:self];
    
    [[CPNotificationCenter defaultCenter] 
        postNotificationName:KFDGraphEdgeAddedNotification
        object:self
        userInfo:[CPDictionary dictionaryWithJSObject:{
            fromNode:fromNode,
            toNode:toNode
        }]];
}

- (void)removeDirectedEdgeFrom:(KFDNode)fromNode to:(KFDNode)toNode
{
    // Only remove the edge if both nodes are in the graph
    if(![nodes containsObject:fromNode] || ![nodes containsObject:toNode])
        return;
    
    if([delegate respondsToSelector:@selector(willRemoveEdgeFromNode:toNode:inGraph:)])
        [delegate willRemoveEdgeFromNode:fromNode toNode:toNode inGraph:self];
        
    [fromNode removeDirectedEdgeTo:toNode];
    
    if([delegate respondsToSelector:@selector(didRemoveEdge:fromNode:toNode:inGraph:)])
        [delegate didRemoveEdge:YES fromNode:fromNode toNode:toNode inGraph:self];
    
    [[CPNotificationCenter defaultCenter] 
        postNotificationName:KFDGraphEdgeRemovedNotification
        object:self
        userInfo:[CPDictionary dictionaryWithJSObject:{
            fromNode:fromNode,
            toNode:toNode
        }]];
}

- (BOOL)containsNode:(KFDNode)aNode
{
    return [nodes containsObject:aNode];
}

- (void)allowsNode:(KFDNode)aNode
{
    var isAllowed = NO,
        allowedNodeTypeIter = [allowedNodeTypes objectEnumerator],
        allowedNodeType = nil;
    
    while(allowedNodeType = [allowedNodeTypeIter nextObject])
    {
        if([aNode isKindOfClass:allowedNodeType])
        {
            isAllowed = YES;
            break;
        }
    }
    return isAllowed;
}



@end