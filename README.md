# ReportBuilder
Ruby gem to merge Cucumber JSON reports and build single HTML Test Report

## Installation

```bash
gem install report_builder
```

## Usage

### Code Examples:

```ruby
    require 'report_builder'

   # 1
    ReportBuilder.build_report('path/of/json/files/dir')

   # 2
    ReportBuilder.build_report('path/of/json/file.json', my_test_report)

   # 3
    ReportBuilder.build_report([
            'path/of/json/file1.json',
            'path/of/json/file2.json',
            'path/of/json/files/dir/'
            ])

   # 4
    ReportBuilder.build_report()

   # 5
    ReportBuilder::COLOR[:passed] = '#ffffff'
    ReportBuilder.build_report()
```

### Command Example:

```bash
     report_builder 'path/of/json/files/dir' 'report_file'
```

### Rake Example:

```ruby
   # Add in Rakefile
      require 'report_builder.rake'
   # Then run rake task report_builder
```

```bash
   rake report_builder ['path/of/json/files/dir','report_file']
```

## Contributing

We're open to any contribution. It has to be tested properly though.

## Maintainer

[Rajat Thareja](http://www.rajatthareja.com)

## License

Copyright (c) 2016 rajatthareja [MIT LICENSE](LICENSE)