# ReportBuilder

[![Gem Version](https://badge.fury.io/rb/report_builder.svg)](https://badge.fury.io/rb/report_builder) 
[![Join the chat at https://gitter.im/rajatthareja/ReportBuilder](https://badges.gitter.im/rajatthareja/ReportBuilder.svg)](https://gitter.im/rajatthareja/ReportBuilder?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Ruby gem to merge Cucumber JSON reports and build mobile friendly HTML Test Report, JSON report and retry file.

[View sample report](http://reportbuilder.rajatthareja.com/)

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

| Option | Type | Default | Values |
|--------|------|---------|--------|
| json_path | [String] / [Array] | (current directory) | json files path / array of json files or path |
| report_path | [String] | 'test_report' | output file path with file name without extension |
| report_types | [Array] | [:html] | :json, :html, :retry (output file types) |
| report_title | [String] | 'Test Results' | report and html title |
| include_images | [Boolean] | true | true / false (If false, the size of HTML report is reduced by excluding embedded images) |
| additional_info | [Hash] | {} | additional info for report summary |
| custom_stylesheet | [String] | nil | pass custom stylesheet link to overwrite default materialize styles |

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

| Option              | Values      | Explanation                                                       |
|---------------------|-------------|-------------------------------------------------------------------|
| -s, --source        | x,y,z       | List of json path or files                                        |
| -o, --out           | [PATH]NAME  | Report path with name without extension                           |
| --json_out          | [PATH]NAME  | Same as the -o option but will only apply the json report format  |
| --html_out          | [PATH]NAME  | Same as the -o option but will only apply the html report format  |
| --retry_out         | [PATH]NAME  | Same as the -o option but will only apply the retry report format |
| -f, --format        | x,y,z       | List of report format - html,json,retry                           |
| --[no-]images       |             | Reduce HTML report size by excluding embedded images              |
| -T, --title         | TITLE       | Report title                                                      |
| -I, --info          | a:x,b:y,c:z | List of additional info about test - key:value                    |
| -h, --help          |             | Show available command line switches                              |
| -v, --version       |             | Show gem version                                                  |
| --custom_stylesheet |             | Custom stylesheet for overwriting materialize stylesheet          |

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
