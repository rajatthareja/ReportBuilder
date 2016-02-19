desc 'Rake task to build report'
task :report_builder, [:json_path, :report_path, :report_types, :report_tabs, :compress_images] do |t, args|
  args.with_defaults(:json_path => nil, :report_path => 'test_report', :report_types => [:html], :report_tabs => [:overview, :features, :errors], :compress_images => false)
  options = {:json_path => args.json_path, :report_path => args.report_path, :report_types => args.report_types, :report_tabs => args.report_tabs, :compress_images => args.compress_images}
  ReportBuilder.build_report options
end