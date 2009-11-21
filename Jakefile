/*
 * Jakefile
 * YEDDiagram
 *
 * Created by You on November 20, 2009.
 * Copyright 2009, Your Company All rights reserved.
 */

var ENV = require("system").env,
    FILE = require("file"),
    task = require("jake").task,
    FileList = require("jake").FileList,
    app = require("cappuccino/jake").app,
    configuration = ENV["CONFIG"] || ENV["CONFIGURATION"] || ENV["c"] || "Debug";

app ("YEDDiagram", function(task)
{
    task.setBuildIntermediatesPath(FILE.join("Build", "YEDDiagram.build", configuration));
    task.setBuildPath(FILE.join("Build", configuration));

    task.setProductName("YEDDiagram");
    task.setIdentifier("com.yourcompany.YEDDiagram");
    task.setVersion("1.0");
    task.setAuthor("Your Company");
    task.setEmail("feedback @nospam@ yourcompany.com");
    task.setSummary("YEDDiagram");
    task.setSources(new FileList("**/*.j"));
    task.setResources(new FileList("Resources/*"));
    task.setIndexFilePath("index.html");
    task.setInfoPlistPath("Info.plist");

    if (configuration === "Debug")
        task.setCompilerFlags("-DDEBUG -g");
    else
        task.setCompilerFlags("-O");
});

task ("default", ["YEDDiagram"]);
