/*
 * AppController.j
 * KefedDiagram
 *
 * Created by You on October 27, 2009.
 * Copyright 2009, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "KFDEdgeView.j"
@import "KFDGraph.j"
@import "KFDGraphViewController.j"
@import "KFDNode.j"
@import "KFDNodeView.j"
@import "KFDNodeViewRegistry.j"
@import "KFDOperationNode.j"
@import "KFDSubjectNode.j"


CPLogRegister(CPLogConsole);

@implementation AppController : CPObject
{
    CPWindow    theWindow; //this "outlet" is connected automatically by the Cib
    CPView      contentView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
    // [[KFDEditorView sharedEditor] setBackgroundColor:[CPColor blueColor]];
    // Setup default Node Views
    CPLog.trace("Setting up view registry");
    var registry = [KFDNodeViewRegistry registry];
    var subjectNodeView = [[KFDNodeView alloc] initWithFrame:CPRectMake(0,0,150,50)];
    [subjectNodeView setBorderWidth:4.0];
    [subjectNodeView setBorderColor:[CPColor redColor]];
    [subjectNodeView setCornerRadius:10];
    [subjectNodeView setFillColor:[CPColor whiteColor]];
    [registry registerPrototype:subjectNodeView
                for:KFDSubjectNode];
    
    var operationNodeView = [[KFDNodeView alloc] initWithFrame:CPRectMake(0,0,100,80)];
    [operationNodeView setBorderWidth:3.0];
    [operationNodeView setBorderColor:[CPColor greenColor]];
    [operationNodeView setCornerRadius:0];
    [operationNodeView setFillColor:[CPColor whiteColor]];
    [registry registerPrototype:operationNodeView
                for:KFDOperationNode];
    // Setup graph and graph controller
    graph = [KFDGraph graph];
    
     graphViewController = [[KFDGraphViewController alloc] init];
    [graphViewController setNodeViewRegistry:registry];
    [graphViewController setRepresentedObject:graph];
    
     graphView = [graphViewController view];
    [graphView setFrame:CPRectMake(0,0,CPRectGetWidth([contentView bounds]),CPRectGetHeight([contentView bounds]))];
    [graphView setAutoresizingMask:(CPViewWidthSizable | CPViewHeightSizable)];
    [contentView addSubview:graphView];
    
    
    
    console.debug("Registry");
    console.debug(registry);
    
    rat1 = [KFDSubjectNode nodeWithName:"Rat1"];
    [graph addNode:rat1];
    fed1 = [KFDOperationNode nodeWithName:"Fed 5cc glucose"];
    [graph addNode:fed1];
    fedRat1 = [KFDSubjectNode nodeWithName:"Rat1 Fed"];
    [graph addNode:fedRat1];
    
    [graph createDirectedEdgeFrom:rat1 to:fed1];
    [graph createDirectedEdgeFrom:fed1 to:fedRat1];

    
    
    
    // At this point, the graph should have two nodes, and 
    //  the graph view should show them with the above
    //  registered nodeviews.
    
    // var nodeViewDecorator = [CPBox boxEnclosingView:nodeView];
    // [nodeViewDecorator setBorderType:CPLineBorder];
    // [nodeViewDecorator setBorderWidth:5];
    // [nodeViewDecorator setCornerRadius:20.0];
    // [nodeViewDecorator setFillColor:[CPColor grayColor]];
    // console.log(nodeViewDecorator);
    
}

- (void)awakeFromCib
{
    // This is called when the cib is done loading.
    // You can implement this method on any object instantiated from a Cib.
    // It's a useful hook for setting up current UI values, and other things. 
    
    // In this case, we want the window from Cib to become our full browser window
    [theWindow setFullBridge:YES];
}

- (void)newNode:(id)sender
{
    var name = prompt("Node Name:");
    if(name)
    {
        var node = [KFDSubjectNode nodeWithName:name];
        [graph addNode:node];
    }
}

@end
