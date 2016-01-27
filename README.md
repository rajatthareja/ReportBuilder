# ReportBuilder
Ruby gem to merge Cucumber JSON reports and build single HTML Test Report

# Installation

gem install report_builder


# Usage

Code Examples:

    require 'report_builder'
    #1
    ReportBuilder.build_report('path/of/json/files/dir')
    #2
    ReportBuilder.build_report('path/of/json/file.json', my_test_report)
    #3
    ReportBuilder.build_report(['path/of/json/file1.json','path/of/json/file2.json','path/of/json/files/dir/'])
    #4
    ReportBuilder.build_report()
    #5
    ReportBuilder::COLOR[:passed] = '#ffffff'
    ReportBuilder.build_report()

Command Example:

        report_builder 'path/of/json/files/dir' 'report_file'
        
Rake Example:

        #In Rakefile
        require 'rake_task/report_builder'
        #Run task using
        report_builder ['path/of/json/files/dir','report_file']
        
