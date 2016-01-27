desc 'Rake task to build report'
task :report_builder, [:file_or_dir, :output_file_name] do |t, args|
  args.with_defaults(:file_or_dir => nil, :output_file_name => 'test_report')
  require 'report_builder.rake'
  ReportBuilder.build_report args.file_or_dir, args.output_file_name
end