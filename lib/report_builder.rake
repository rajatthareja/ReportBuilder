desc 'Sample rake task to build report'
task :report_builder, [:json_path, :report_path] do |t, args|
  args.with_defaults(:json_path => nil, :report_path => 'test_report')
  options = {:json_path => args.json_path, :report_path => args.report_path}
  ReportBuilder.build_report options
end