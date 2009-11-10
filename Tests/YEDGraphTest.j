@import "../YEDGraph.j"

@implementation YEDGraphTest : OJTestCase

- (void)testYEDGraphShouldAllowYEDNodes
{
    var graph = [YEDGraph graph],
        n1 = [YEDNode nodeWithName:"n1"],
        n2 = [YEDNode nodeWithName:"n2"];
        
    [self assertTrue:([graph allowsNode:n1])
            message:"Graph should allow n1"];
            
    [self assertTrue:([graph allowsNode:n2])
            message:"Graph should allow n2"];
    
    [graph addNode:n1];
    [graph addNode:n2];
    
    [self assertTrue:([graph containsNode:n1])
            message:"Graph should contain node n1"];
    
    [self assertTrue:([graph containsNode:n2])
            message:"Graph should contain node n2"];
}

- (void)testCreateDirectedEdge
{
    var graph = [YEDGraph graph],
        n1 = [YEDNode nodeWithName:"n1"],
        n2 = [YEDNode nodeWithName:"n2"],
        n3 = [YEDNode nodeWithName:"n3"];
        
    // Add n1 and n2 to graph
    [graph addNode:n1];
    [graph addNode:n2];
    
    // Now create an edge between n1 -> n2
    [graph createDirectedEdgeFrom:n1 to:n2];
    
    // Edge n1 -> n2 should exist
    [self assertTrue:[n1 hasOutgoingEdgeTo:n2]
            message:"n1 should have outgoing edge to n2"];
    [self assertTrue:[n2 hasIncomingEdgeFrom:n1]
            message:"n2 should have incoming edge from n1"];
    
    // Creating an edge to n3 should fail because n3 is not in the graph
    try 
    {
        [graph createDirectedEdgeFrom:n1 to:n3];
    }
    catch(err)
    {
        CPLog.info(err);
    }
    [self assertFalse:[n1 hasOutgoingEdgeTo:n3]
            message:"edge n1 -> n3 should not have been created"];
    [self assertFalse:[n3 hasIncomingEdgeFrom:n1]
            message:"edge n1 -> n3 should not have been created"];
    [self assertFalse:[graph containsNode:n3]
            message:"n3 should not been in the graph"];
}


@end