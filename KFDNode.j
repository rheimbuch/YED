@import <Foundation/CPObject.j>
@import <Foundation/CPSet.j>

// Constants
KFDNodeCycleException = "KFDNodeCycleException";

/*
 * Performs a depth-first-search of an edge set,
 *  tracking each node encountered. If a node is
 *  encountered more than once, then a cycle has 
 *  been found.
 */
KFDNodeGraphHasCycles = function(aNode, traverseParents) 
{
    CPLog.trace("KFDNodeGraphHasCycles: Testing for cycles starting at %s", [aNode name]);
    traverseParents = traverseParents || NO;
    var stack = []
    function isAcyclic(node)
    {
        if([stack containsObject:node])
        {
            return false;
        }
        stack.push(node);
        CPLog.trace("KFDNodeGraphHasCycles: at node %s", [node name]);
        
        var targetNode = nil;
        var nodeIter = traverseParents ? [[node inEdges] objectEnumerator] : 
                                         [[node outEdges] objectEnumerator];
        
        traverseParents ? CPLog.trace("KFDNodeGraphHasCycles: Traversing inEdges") : 
                          CPLog.trace("KFDNodeGraphHasCycles: Travering outEdges");
        
        while(targetNode = [nodeIter nextObject])
        {
            if(!isAcyclic(targetNode, traverseParents))
            {
                return false;
            }
        }
        stack.pop();
        return true;
    }
    
    var result = isAcyclic(aNode);
    CPLog.trace("KFDNodeGraphHasCycles: Graph staring at %s is acyclic: %s", [aNode name], result);
    return !result;
};

@implementation KFDNode : CPObject
{
    CPString    name                    @accessors;
    CPSet       outEdges                @accessors(readonly);
    CPSet       inEdges                 @accessors(readonly);
    CPSet       allowsConnectionsTo      @accessors(readonly);
    CPSet       allowsConnectionsFrom    @accessors(readonly);
    
    BOOL        isAcyclic     @accessors;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        outEdges = [CPSet set];
        inEdges = [CPSet set];
        allowsConnectionsTo = [CPSet setWithObject:[self class]];
        allowsConnectionsFrom = [CPSet setWithObject:[self class]];
        isAcyclic = NO;
    }
    return self;
}

- (id)initAcyclic
{
    self = [self init]
    if(self)
    {
        isAcyclic = YES;
    }
    return self;
}

+ (id)node
{
    return [[self alloc] init];
}

+ (id)nodeWithName:(CPString)aName
{
    var node = [self node];
    [node setName:aName];
    return node;
}

+ (id)acyclicNode
{
    return [[self alloc] initAcyclic];
}

+ (id)acyclicNodeWithName:(CPString)aName
{
    var node = [self acyclicNode];
    [node setName:aName]
    return node;
}

- (BOOL)hasOutgoingEdgeTo:(KFDNode)otherNode
{
    return [outEdges containsObject:otherNode];
}

- (BOOL)hasIncomingEdgeFrom:(KFDNode)otherNode
{
    return [otherNode hasOutgoingEdgeTo:self];
}

- (void)directedEdgeTo:(KFDNode)otherNode
{
    if([self canConnectTo:otherNode])
    {
        CPLog.trace("directedEdgeTo: %s allowed to connect to %s", [self name], [otherNode name]);
        
        // If the otherNode has no incoming or outgoing edges, then it cannot introduce
        //  any cycles into the graph. We test because adding a single, indepedent node 
        //  is a common case.
        var otherNodeCouldIntroduceCycles = [[otherNode inEdges] anyObject] || [[otherNode outEdges] anyObject];
        CPLog.trace("directedEdgeTo: %s could introduce a cycle?: %s", [otherNode name], otherNodeCouldIntroduceCycles);
        
        //Add the node to the graph first
        [[self outEdges] addObject:otherNode];
        [[otherNode inEdges] addObject:self];
        
        if(isAcyclic && otherNodeCouldIntroduceCycles)
        {

            if([self cycleInDescendents] || [self cycleInParents])
            {
                CPLog.warn("directedEdgeTo: detected a cycle! removing edge from %s to %s", [self name], [otherNode name]);
                //If adding the edge/connection introduces cycles, we should remove it.
                [[self outEdges] removeObject:otherNode];
                [[otherNode inEdges] removeObject:self];
                
                [CPException raise:KFDNodeCycleException reason:"Connecting the node would introduce a cycle."];
            }
            
        }
    }
    else
    {
        CPLog.warn("directedEdgeTo: %s not allowed to connect to %s", [self name], [otherNode name]);      
        [CPException raise:KFDNodeNotAllowedException reason:"Node is not allowed to be added."];
    }
}

- (void)directedEdgeFrom:(KFDNode)otherNode
{
    [otherNode directedEdgeTo:self];
}


- (void)removeDirectedEdgeTo:(KFDNode)otherNode
{
    
}
/*
 * Is the node allowed to connect to another node.
 * By default all KFDNodes can connect to any other node.
 */
- (BOOL)canConnectTo:(KFDNode)otherNode
{
    var allowTo = false;
    var allowToIter = [allowsConnectionsTo objectEnumerator];
    
    var allowedNodeClass = nil;
    while(allowedNodeClass = [allowToIter nextObject])
    {
        if([otherNode isKindOfClass:allowedNodeClass])
            allowTo = true;
    }
    
    
    
    var allowFrom = false;
    var allowFromIter = [[otherNode allowsConnectionsFrom] objectEnumerator];
    
    var allowedNodeClass = nil;
    while(allowedNodeClass = [allowFromIter nextObject])
    {
        if([self isKindOfClass:allowedNodeClass])
            allowFrom = true;
    }
    
    return allowTo && allowFrom;
}

- (BOOL)canRecieveConnectionFrom:(KFDNode)otherNode
{
    return [otherNode canConnectTo:self];
}

- (CPSet)allDescendents
{
    var descendents = [CPSet set];
    
    function traverse(node) {
        [descendents unionSet:[node outEdges]];
        var iter = [[node outEdges] objectEnumerator];
        while(node = [iter nextObject])
        {
            traverse(node);
        }
    }
    traverse(self);
    return descendents;
}

- (BOOL)cycleInDescendents
{
    return KFDNodeGraphHasCycles(self,NO);
}

- (BOOL)cycleInParents
{
    return KFDNodeGraphHasCycles(self,YES);
}


@end