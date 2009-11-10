
require 'objective-j'
require 'objective-j/bundletask'

if !ENV['CONFIG']
    ENV['CONFIG'] = 'Debug'
end

ObjectiveJ::BundleTask.new(:YEDDiagram) do |t|
    t.name          = 'YEDDiagram'
    t.identifier    = 'com.yourcompany.YEDDiagram'
    t.version       = '1.0'
    t.author        = 'Your Company'
    t.email         = 'feedback @nospam@ yourcompany.com'
    t.summary       = 'YEDDiagram'
    t.sources       = FileList['*.j']
    t.resources     = FileList['Resources/*']
    t.index_file    = 'index.html'
    t.info_plist    = 'Info.plist'
    t.build_path    = File.join('Build', ENV['CONFIG'], 'YEDDiagram')
    t.flag          = '-DDEBUG' if ENV['CONFIG'] == 'Debug'
    t.flag          = '-O' if ENV['CONFIG'] == 'Release'
end

task :default => [:YEDDiagram]
