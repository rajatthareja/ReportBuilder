# ReportBuilder
Ruby gem to merge Cucumber JSON reports and build single HTML Test Report

# Installation

gem install report_builder


# Usage

Examples:

    ReportBuilder.build_report('path/of/json/files/dir')
    ReportBuilder.build_report('path/of/json/file.json')

  ReportBuilder.build_report(['path/of/json/file1.json','path/of/json/file2.json','path/of/json/files/dir/'])

    ReportBuilder.build_report()
  

    ReportBuilder::COLOR[:passed] = '#ffffff'
    ReportBuilder.build_report()
