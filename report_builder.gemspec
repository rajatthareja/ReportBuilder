Gem::Specification.new do |s|
  s.name        = 'report_builder'
  s.version     = '1.8'
  s.bindir      = 'bin'
  s.summary     = 'ReportBuilder'
  s.description = 'Ruby gem to merge Cucumber JSON reports and build mobile-friendly HTML Test Report, JSON report and retry file.'
  s.post_install_message = 'Happy reporting!'
  s.authors     = ['Rajat Thareja']
  s.email       = 'rajat.thareja.1990@gmail.com'
  s.homepage    = 'https://reportbuilder.rajatthareja.com'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 1.9.3'
  s.requirements << 'Cucumber >= 2.1.0 test results in JSON format'

  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(sample/|css/|js/|pkg/|testing/|coverage/|CNAME|.gitignore|appveyor.yml|.travis.yml|_config.yml|Gemfile|Rakefile|rb.ico)}) }
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files  = s.files.grep(%r{^(testing)/})

  s.add_runtime_dependency 'json', '>= 1.8.1'

  s.add_development_dependency 'rake', '< 13.0'
  s.add_development_dependency 'rspec', '< 4.0'
end
