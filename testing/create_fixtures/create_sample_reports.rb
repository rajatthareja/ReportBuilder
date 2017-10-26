require '../../lib/report_builder'

ReportBuilder.configure do |config|
  config.json_path = '../fixtures/json_reports'
  config.report_path = '../../sample/report'
  config.report_types = [:html]
  config.report_title = 'My Test Results'
  config.additional_info = {Browser: 'browser', Environment: 'environment', MoreInfo: 'more info'}
end

ReportBuilder.build_report

ReportBuilder.configure do |config|
  config.json_path = config.json_path = {
      'Group Abc' => ['../fixtures/json_reports/report.json', '../fixtures/json_reports/report1.json', '../fixtures/json_reports/report2.json'],
      'Group Xyz' => ['../fixtures/json_reports/report3.json', '../fixtures/json_reports/report4.json']}
  config.report_path = '../../sample/group_report'
end

ReportBuilder.build_report
