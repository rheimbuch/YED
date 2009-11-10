@import <AppKit/AppKit.j>
@import "../YEDNodeViewRegistry.j"
@import "../YEDNode.j"
@import "../YEDNodeView.j"

CPLogRegister(CPLogPrint);

@implementation YEDNodeViewRegistryTest : OJTestCase

- (void)testRegisterAndRetrieveView
{
    CPLog.trace("Creating registry and protoView");
    var registry = [[YEDNodeViewRegistry alloc] init];
    var protoView = [[YEDNodeView alloc] init];
    
    CPLog.trace("Registering protoView for YEDNode");
    [registry registerPrototype:protoView for:YEDNode];
    
    CPLog.trace("Retrieving view for YEDNode");
    var newView = [registry viewFor:YEDNode];
    
    [self assertTrue:(newView)
        message:"newView should have been retrieved"];
    
    [self assertTrue:([newView class] === YEDNodeView)
        message:"newView should be a YEDNodeView"];
    
    [self assertFalse:([newView isEqual:protoView])
        message:"newView should not be exactly the same object as protoView"];
}

@end