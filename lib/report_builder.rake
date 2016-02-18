desc 'Rake task to build report'
task :report_builder, [:file_or_dir, :output_file_name, :output_file_type, :tabs] do |t, args|
  args.with_defaults(:file_or_dir => nil, :output_file_name => 'test_report', :output_file_type => [:html], :tabs => [:overview, :features, :errors])
  ReportBuilder.build_report args.file_or_dir, args.output_file_name, args.output_file_type, args.tabs
end