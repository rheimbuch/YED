@import "../YEDNode.j"
@import "../YEDSubjectNode.j"
@import "../YEDOperationNode.j"

@implementation YEDSubjectNodeTest : OJTestCase

- (void)testYEDSubjectNodeShouldNotConnectToAnotherYEDSubjectNode
{
    var node1 = [YEDSubjectNode node],
        node2 = [YEDSubjectNode node];
    
    [self assertFalse:([node1 canConnectTo:node2])
          message:"A subject node1 should not connect to another subject node2"];
    
    [self assertFalse:([node2 canConnectTo:node1])
          message:"A subject node2 should not connect to another subject node1"];
}

- (void)testYEDSubjectNodeShouldConnectToAYEDOperationNode
{
    var node1 = [YEDSubjectNode node],
        node2 = [YEDOperationNode node];
    
    [self assertTrue:([node1 canConnectTo:node2])
          message:"A Subject node can connect to an operation node"];
}
@end