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
    
    # @param [Object] file_or_dir Input json file, Default nil (current directory),  array of json files or path, json files path
    # @param [String] output_file_name Output file name, Default test_report
    # @param [Array] output_file_type Output file type, Default [:html], Options [:json] and [:json, :html] or ['html', 'json']
    # @param [Array] tabs Tabs to build, by default [:overview, :features, :errors], Options [:overview, :features, :scenarios, :errors] or ['overview', 'features', 'scenarios', 'errors']

    # 1 
    ReportBuilder.build_report()
    ReportBuilder.build_report('path/of/json/files/dir')
    ReportBuilder.build_report('path/of/json/files/dir', 'my_test_report_name', [:json])
    ReportBuilder.build_report('path/of/json/files/dir', 'my_test_report_name', ['json'])
    ReportBuilder.build_report('path/of/json/files/dir', 'my_test_report_name', [:json, 'html'])
    ReportBuilder.build_report('path/of/json/files/dir', 'my_test_report_name', [:json, :html], [:overview, :features, :scenarios, :errors])

    # 2
    ReportBuilder.build_report('path/of/json/cucumber.json')

    # 3
    ReportBuilder.build_report([
            'path/of/json/cucumber1.json',
            'path/of/json/cucumber2.json',
            'path/of/json/files/dir/'
            ])

    # 4
    ReportBuilder::COLOR[:passed] = '#ffffff'
    ReportBuilder::COLOR[:failed] = '#000000'
    ReportBuilder.build_report()
    
    # 5
    ReportBuilder::COMPRESS = true
    ReportBuilder.build_report 'parallel_cucumber_sample', 'sample_report_dev', [:json, :html], [:overview, :features, :scenarios, :errors]
    
```

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