# ReportBuilder

[![Gem Version](https://badge.fury.io/rb/report_builder.svg)](https://badge.fury.io/rb/report_builder) 
[![Build status](https://travis-ci.org/rajatthareja/ReportBuilder.svg?branch=master)](https://travis-ci.org/rajatthareja/ReportBuilder) 
[![Join the chat at https://gitter.im/rajatthareja/ReportBuilder](https://badges.gitter.im/rajatthareja/ReportBuilder.svg)](https://gitter.im/rajatthareja/ReportBuilder?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Ruby gem to merge Cucumber JSON reports and build mobile-friendly HTML Test Report, JSON report and retry file.

**[View sample report](http://reportbuilder.rajatthareja.com)**

## Installation

```bash

gem install report_builder

```

## Information

* RDoc documentation [available on RubyDoc.info](http://www.rubydoc.info/gems/report_builder)
* Source code [available on GitHub](http://github.com/rajatthareja/ReportBuilder)

## Usage

**Note:** Works with cucumber(>= 2.1.0) test results in JSON format.

### Config Options:

| Option                  | Type               | Default             | Values                                                                                   |
|-------------------------|--------------------|---------------------|------------------------------------------------------------------------------------------|
| json_path / input_path  | [String] / [Array] | (current directory) | input json files path / array of json files or path                                      |
| report_path             | [String]           | 'test_report'       | reports output file path with file name without extension                                |
| json_report_path        | [String]           | (report_path)       | json report output file path with file name without extension                            |
| html_report_path        | [String]           | (report_path)       | html report output file path with file name without extension                            |
| retry_report_path       | [String]           | (report_path)       | retry report output file path with file name without extension                           |
| report_types            | [Array]            | [:html]             | :json, :html, :retry (output file types)                                                 |
| report_title            | [String]           | 'Test Results'      | report and html title                                                                    |
| include_images          | [Boolean]          | true                | true / false (If false, the size of HTML report is reduced by excluding embedded images) |
| additional_info         | [Hash]             | {}                  | additional info for report summary                                                       |
| additional_css          | [String]           | nil                 | additional CSS string or CSS file path or CSS file url for customizing html report       |
| additional_js           | [String]           | nil                 | additional JS string or JS file path or JS file url for customizing html report           |

### Code Examples:

```ruby

     require 'report_builder'
    
    # Ex 1:
    ReportBuilder.configure do |config|
      config.json_path = 'cucumber_sample/logs'
      config.report_path = 'my_test_report'
      config.report_types = [:json, :html]
      config.report_title = 'My Test Results'
      config.include_images = false
      config.additional_info = {browser: 'Chrome', environment: 'Stage 5'}
    end
    
    ReportBuilder.build_report
    
    # Ex 2:
    options = {
       json_path:    'cucumber_sample/logs',
       report_path:  'my_test_report',
       report_types: ['json', 'html'],
       report_title: 'My Test Results',
       include_images: false,
       additional_info: {'browser' => 'Chrome', 'environment' => 'Stage 5'}
     }
    
    ReportBuilder.build_report options
        
```

### CLI Options:

| Option              | Values          | Explanation                                                                        |
|---------------------|-----------------|------------------------------------------------------------------------------------|
| -s, --source        | x,y,z           | List of input json path or files                                                   |
| -o, --out           | [PATH]NAME      | Reports path with name without extension                                           |
| --json_out          | [PATH]NAME      | JSON report path with name without extension                                       |
| --html_out          | [PATH]NAME      | HTML report path with name without extension                                       |
| --retry_out         | [PATH]NAME      | Retry report path with name without extension                                      |
| -f, --format        | x,y,z           | List of report format - html,json,retry                                            |
| --[no-]images       |                 | Reduce HTML report size by excluding embedded images                               |
| -T, --title         | TITLE           | Report title                                                                       |
| -I, --info          | a:x,b:y,c:z     | List of additional info about test - key:value                                     |
| --css               | STRING/PATH/URL | Additional CSS string or CSS file path or CSS file url for customizing html report |
| --js                | STRING/PATH/URL | Additional JS string or JS file path or JS file url for customizing html report    |
| -h, --help          |                 | Show available command line switches                                               |
| -v, --version       |                 | Show gem version                                                                   |

### CLI Example:

```bash

     report_builder
     report_builder -s 'path/of/json/files/dir'
     report_builder -s 'path/of/json/files/dir' -o my_report_file

```

### Rake Example:

Add in Rakefile

```ruby

    require 'report_builder'
    load 'report_builder.rake'

```

Then run rake task report_builder

```bash

    rake report_builder
    rake report_builder['path/of/json/files/dir']
    rake report_builder['path/of/json/files/dir','report_file']

```

## Contributing

We're open to any contribution. It has to be tested properly though.

## Collaborators

* [Rajat Thareja](https://github.com/rajatthareja)
* [Justin Commu](https://github.com/tk8817)
* [Eric Kessler](https://github.com/enkessler)
* [Jeff Morgan](https://github.com/cheezy)

## License

Copyright (c) 2017 [MIT LICENSE](LICENSE)
