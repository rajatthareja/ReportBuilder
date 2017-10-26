require '../../lib/report_builder'

ReportBuilder.configure do |config|
  config.json_path = '../fixtures/json_reports'
  # config.json_path = {"group1" => '../fixtures/json_reports', "group2" => '../fixtures/json_reports'}
  config.report_path = '../../docs/index'
  config.report_types = [:html]
  config.report_title = 'My Test Results'
  config.additional_info = {Browser: 'browser', Environment: 'environment', MoreInfo: 'more info'}
end

ReportBuilder.build_report
