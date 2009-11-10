@import <AppKit/AppKit.j>
@import "../KFDNodeViewRegistry.j"
@import "../KFDNode.j"
@import "../KFDNodeView.j"

CPLogRegister(CPLogPrint);

@implementation KFDNodeViewRegistryTest : OJTestCase

- (void)testRegisterAndRetrieveView
{
    CPLog.trace("Creating registry and protoView");
    var registry = [[KFDNodeViewRegistry alloc] init];
    var protoView = [[KFDNodeView alloc] init];
    
    CPLog.trace("Registering protoView for KFDNode");
    [registry registerPrototype:protoView for:KFDNode];
    
    CPLog.trace("Retrieving view for KFDNode");
    var newView = [registry viewFor:KFDNode];
    
    [self assertTrue:(newView)
        message:"newView should have been retrieved"];
    
    [self assertTrue:([newView class] === KFDNodeView)
        message:"newView should be a KFDNodeView"];
    
    [self assertFalse:([newView isEqual:protoView])
        message:"newView should not be exactly the same object as protoView"];
}

@end