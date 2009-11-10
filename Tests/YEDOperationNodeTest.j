@import "../YEDNode.j"
@import "../YEDOperationNode.j"
@import "../YEDSubjectNode.j"

@implementation YEDOperationNodeTest : OJTestCase

- (void)testYEDOperationNodeShouldNotConnectToAnotherYEDOperationNode
{
    var node1 = [YEDOperationNode node],
        node2 = [YEDOperationNode node];
    
    [self assertFalse:([node1 canConnectTo:node2])
          message:"A operation node1 should not connect to another operation node2"];
    
    [self assertFalse:([node2 canConnectTo:node1])
          message:"A operation node2 should not connect to another operation node1"];
}

- (void)testYEDOperationNodeShouldConnectToAYEDSubjectNode
{
    var node1 = [YEDOperationNode node],
        node2 = [YEDSubjectNode node];
    
    [self assertTrue:([node1 canConnectTo:node2])
          message:"A Subject node can connect to an operation node"];
}
@end