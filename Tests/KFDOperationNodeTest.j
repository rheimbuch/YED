@import "../KFDNode.j"
@import "../KFDOperationNode.j"
@import "../KFDSubjectNode.j"

@implementation KFDOperationNodeTest : OJTestCase

- (void)testKFDOperationNodeShouldNotConnectToAnotherKFDOperationNode
{
    var node1 = [KFDOperationNode node],
        node2 = [KFDOperationNode node];
    
    [self assertFalse:([node1 canConnectTo:node2])
          message:"A operation node1 should not connect to another operation node2"];
    
    [self assertFalse:([node2 canConnectTo:node1])
          message:"A operation node2 should not connect to another operation node1"];
}

- (void)testKFDOperationNodeShouldConnectToAKFDSubjectNode
{
    var node1 = [KFDOperationNode node],
        node2 = [KFDSubjectNode node];
    
    [self assertTrue:([node1 canConnectTo:node2])
          message:"A Subject node can connect to an operation node"];
}
@end