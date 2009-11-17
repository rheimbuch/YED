/*
 * AppController.j
 * YEDDiagram
 *
 * Created by You on October 27, 2009.
 * Copyright 2009, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "YEDEdgeView.j"
@import "YEDGraph.j"
@import "YEDGraphViewController.j"
@import "YEDNode.j"
@import "YEDNodeView.j"
@import "YEDNodeViewRegistry.j"
@import "YEDOperationNode.j"
@import "YEDSubjectNode.j"


CPLogRegister(CPLogConsole);

@implementation AppController : CPObject
{
    CPWindow    theWindow; //this "outlet" is connected automatically by the Cib
    CPView      contentView;
    CPView      sideView;
    CPView      canvasView;
    YEDNodeViewRegistry registry;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
    // [[YEDEditorView sharedEditor] setBackgroundColor:[CPColor blueColor]];
    // Setup default Node Views
    CPLog.trace("Setting up view registry");
    registry = [YEDNodeViewRegistry registry];
    var subjectNodeView = [[YEDNodeView alloc] initWithFrame:CPRectMake(0,0,150,50)];
    [subjectNodeView setBorderWidth:4.0];
    [subjectNodeView setBorderColor:[CPColor redColor]];
    [subjectNodeView setCornerRadius:10];
    [subjectNodeView setFillColor:[CPColor whiteColor]];
    [registry registerPrototype:subjectNodeView
                for:YEDSubjectNode];
    
    var operationNodeView = [[YEDNodeView alloc] initWithFrame:CPRectMake(0,0,100,80)];
    [operationNodeView setBorderWidth:3.0];
    [operationNodeView setBorderColor:[CPColor greenColor]];
    [operationNodeView setCornerRadius:0];
    [operationNodeView setFillColor:[CPColor whiteColor]];
    [registry registerPrototype:operationNodeView
                for:YEDOperationNode];
    // Setup graph and graph controller
    graph = [YEDGraph graph];
    
     graphViewController = [[YEDGraphViewController alloc] init];
    [graphViewController setNodeViewRegistry:registry];
    [graphViewController setRepresentedObject:graph];
    
    var selectionManager = [[YEDSelectionManager alloc] init];
    [selectionManager setDelegate:graphViewController];
    
    var canvasScroll = [[CPScrollView alloc] initWithFrame:CGRectMakeCopy([canvasView bounds])];
    [canvasScroll setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [canvasScroll setAutohidesScrollers:YES];
    [canvasView addSubview:canvasScroll];
    
     graphView = [graphViewController view];
    [graphView setFrame:CPRectMake(0,0,1000,1000)];
    // [graphView setAutoresizingMask:(CPViewWidthSizable | CPViewHeightSizable)];
    [canvasScroll setDocumentView:graphView];
    
    
    
    console.debug("Registry");
    console.debug(registry);
    
    rat1 = [YEDSubjectNode nodeWithName:"Rat1"];
    [graph addNode:rat1];
    fed1 = [YEDOperationNode nodeWithName:"Fed 5cc glucose"];
    [graph addNode:fed1];
    fedRat1 = [YEDSubjectNode nodeWithName:"Rat1 Fed"];
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
        var node = [YEDSubjectNode nodeWithName:name];
        [graph addNode:node];
    }
}

@end
