# ReportBuilder
[![Gem Version](https://badge.fury.io/rb/report_builder.svg)](https://badge.fury.io/rb/report_builder)

Ruby gem to merge Cucumber JSON reports and build single HTML Test Report

## Installation

```bash
gem install report_builder
```

## Information

* RDoc documentation [available on RubyDoc.info](http://www.rubydoc.info/gems/report_builder)
* Source code [available on GitHub](http://github.com/rajatthareja/ReportBuilder)
* Sample report [available here](http://www.rajatthareja.com/reportbuilder/sample.html)

## Usage

**Note:** Works with cucumber(>= 2.1.0) test results in JSON format.

### Code Examples:

```ruby

     require 'report_builder'
    
    # Ex 1:
    ReportBuilder.configure do |config|
      config.json_path = 'cucumber_sample/logs'
      config.report_path = 'sample_report'
      config.report_types = [:json, :html]
      config.report_tabs = [:overview, :features, :scenarios, :errors]
      config.compress_images = false
    end
    
    ReportBuilder.build_report
    
    # Ex 2:
    options = {
       json_path:    'cucumber_sample/logs',
       report_path:  'sample_report',
       report_types: ['json', 'html'],
       report_tabs:  [ 'overview', 'features', 'scenarios', 'errors']
       compress_images: false
     }
    
    ReportBuilder.build_report options
        
```

### Config Options:

| Option | Type | Default | Values |
|--------|------|---------|--------|
| json_path | [String] / [Array] | (current directory) | json files path / array of json files or path |
| report_path | [String] | 'test_report' | output file path with file name without extension |
| report_types | [Array] | [:html] | :json, :html (output file types) |
| report_tabs | [Array] | [:overview, :features, :errors] | :overview, :features, :scenarios, :errors (tabs to build) |
| compress_images | [Boolean] | false | true / false (If true, the size of HTML report is reduced but takes more time to build report) |

### Command Example:

```bash
     report_builder
     report_builder 'path/of/json/files/dir'
     report_builder 'path/of/json/files/dir' 'report_file'
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
   rake report_builder ['path/of/json/files/dir']
   rake report_builder ['path/of/json/files/dir','report_file']
```

## Contributing

 We're open to any contribution. It has to be tested properly though.

## Maintainer

[Rajat Thareja](http://www.rajatthareja.com)

## License

Copyright (c) 2016 [MIT LICENSE](LICENSE)
