# ReportBuilder

[![Gem Version](https://img.shields.io/gem/v/report_builder.svg)](https://badge.fury.io/rb/report_builder) 
[![Build status](https://travis-ci.org/rajatthareja/ReportBuilder.svg?branch=master)](https://travis-ci.org/rajatthareja/ReportBuilder)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/s5jx2ji3wdg294u6/branch/master?svg=true)](https://ci.appveyor.com/project/rajatthareja/reportbuilder)
[![Join the chat at https://gitter.im/rajatthareja/ReportBuilder](https://badges.gitter.im/rajatthareja/ReportBuilder.svg)](https://gitter.im/rajatthareja/ReportBuilder?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Ruby gem to merge Cucumber JSON reports and build mobile-friendly HTML Test Report, JSON report and retry file.

## Sample Reports

**[Features Report](https://reportbuilder.rajatthareja.com/sample/report.html)**

**[Grouped Features Report](https://reportbuilder.rajatthareja.com/sample/group_report.html)**

## Installation

```bash

gem install report_builder

```

## Information

* RDoc documentation [available on RubyDoc.info](http://www.rubydoc.info/gems/report_builder)
* Source code [available on GitHub](https://github.com/rajatthareja/ReportBuilder)

## Usage

**Note:** Works with cucumber(>= 2.1.0) test results in JSON format.

### Config Options:

| Option               | Type                    | Default             | Values                                                                                   |
|----------------------|-------------------------|---------------------|------------------------------------------------------------------------------------------|
| json_path/input_path | [String]/[Array]/[Hash] | (current directory) | input json files path / array of json files or path / hash of json files or path         |
| report_path          | [String]                | 'test_report'       | reports output file path with file name without extension                                |
| json_report_path     | [String]                | (report_path)       | json report output file path with file name without extension                            |
| html_report_path     | [String]                | (report_path)       | html report output file path with file name without extension                            |
| retry_report_path    | [String]                | (report_path)       | retry report output file path with file name without extension                           |
| report_types         | [Array]                 | [:html]             | :json, :html, :retry (output file types)                                                 |
| report_title         | [String]                | 'Test Results'      | report and html title                                                                    |
| include_images       | [Boolean]               | true                | true / false (If false, the size of HTML report is reduced by excluding embedded images) |
| voice_commands       | [Boolean]               | false               | true / false (Enable voice commands for easy navigation and search)                      |
| additional_info      | [Hash]                  | {}                  | additional info for report summary                                                       |
| additional_css       | [String]                | nil                 | additional CSS string or CSS file path or CSS file url for customizing html report       |
| additional_js        | [String]                | nil                 | additional JS string or JS file path or JS file url for customizing html report          |
| color                | [String]                | brown               | report color, Ex: indigo, cyan, purple, grey, lime etc.                                  |

### Code Examples:

```ruby

     require 'report_builder'
    
    # Ex 1:
    ReportBuilder.configure do |config|
      config.input_path = 'results/cucumber_json'
      config.report_path = 'my_test_report'
      config.report_types = [:retry, :html]
      config.report_title = 'My Test Results'
      config.additional_info = {browser: 'Chrome', environment: 'Stage 5'}
    end
    
    ReportBuilder.build_report
    
    # Ex 2:
    ReportBuilder.input_path = 'results/cucumber_json'
    ReportBuilder.report_path = 'my_test_report'
    ReportBuilder.report_types = [:retry, :html]
    ReportBuilder.report_title = 'My Test Results'
    ReportBuilder.additional_info = {Browser: 'Chrome', Environment: 'Stage 5'}
    
    ReportBuilder.build_report
    
    # Ex 3:
    options = {
       input_path: 'results/cucumber_json',
       report_path: 'my_test_report',
       report_types: ['retry', 'html'],
       report_title: 'My Test Results',
       additional_info: {'Browser' => 'Chrome', 'Environment' => 'Stage 5'}
     }
    
    ReportBuilder.build_report options
    
    # Ex 4:
    ReportBuilder.input_path = 'results/cucumber_json'
    
    ReportBuilder.configure do |config|
      config.report_path = 'my_test_report'
      config.report_types = [:json, :html]
    end
    
   options = {
       report_title: 'My Test Results'
   }
   
   ReportBuilder.build_report options
        
```

### Grouped Features Report Example:

```ruby

ReportBuilder.configure do |config|
     config.input_path = {
      'Group A' => ['path/of/json/files/dir1', 'path/of/json/files/dir2'],
      'Group B' => ['path/of/json/file1', 'path/of/json/file2'],
      'Group C' => 'path/of/json/files/dir'}
  end

ReportBuilder.build_report

```


### CLI Options:

| Option                | Values       | Explanation                                                                        |
|-----------------------|--------------|------------------------------------------------------------------------------------|
| -s, --source          | x,y,z        | List of input json path or files                                                   |
| -o, --out             | [PATH]NAME   | Reports path with name without extension                                           |
| --json_out            | [PATH]NAME   | JSON report path with name without extension                                       |
| --html_out            | [PATH]NAME   | HTML report path with name without extension                                       |
| --retry_out           | [PATH]NAME   | Retry report path with name without extension                                      |
| -f, --format          | x,y,z        | List of report format - html,json,retry                                            |
| --[no-]images         |              | Reduce HTML report size by excluding embedded images                               |
| -T, --title           | TITLE        | Report title                                                                       |
| -c, --color           | COLOR        | Report color                                                                       |
| -I, --info            | a:x,b:y,c:z  | List of additional info about test - key:value                                     |
| --css                 | CSS/PATH/URL | Additional CSS string or CSS file path or CSS file url for customizing html report |
| --js                  | JS/PATH/URL  | Additional JS string or JS file path or JS file url for customizing html report    |
| -vc, --voice_commands |              | Enable voice commands for easy navigation and search                               |
| -h, --help            |              | Show available command line switches                                               |
| -v, --version         |              | Show gem version                                                                   |

### CLI Example:

```bash

     report_builder
     report_builder -s 'path/of/json/files/dir'
     report_builder -s 'path/of/json/files/dir' -o my_report_file

```

### Hook Example:

```ruby

require 'report_builder'
    
at_exit do
  ReportBuilder.configure do |config|
    config.input_path = 'results/cucumber_json'
    config.report_path = 'results/report'
  end
  ReportBuilder.build_report
end

```

### Voice Commands:
Use voice commands for easy navigation and search
* show ( overview, features, summary, errors )
* search { Keywords }

## Report Builder Java API
[Report Builder Java](https://reportbuilderjava.rajatthareja.com)

## Contributing

We're open to any contribution. It has to be tested properly though.

## Collaborators

* [Rajat Thareja](https://rajatthareja.com)
* [Justin Commu](https://github.com/tk8817)
* [Eric Kessler](https://github.com/enkessler)
* [Jeff Morgan](https://github.com/cheezy)

## License

Copyright (c) 2017 [MIT LICENSE](LICENSE)
