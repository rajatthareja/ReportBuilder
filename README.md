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

* json_path:

    Default: nil (current directory)
    
    [String] / [Array] Input json file, array of json files/path or json files path

* report_path:     
  
  Default: 'test_report'

  [String] Output file path with name

* report_types:    
    
    Default: [:html]

    [Array] Output file types to build, [:json, :html] or ['html', 'json']

* report_tabs:     

    Default: [:overview, :features, :errors]

    [Array] Tabs to build, [:overview, :features, :scenarios, :errors] or ['overview', 'features', 'scenarios', 'errors']
    
* compress_images 

   Default: false
   
   [Boolean] Set true to reducing the size of HTML report, Note: If true, takes more time to build report
    


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
