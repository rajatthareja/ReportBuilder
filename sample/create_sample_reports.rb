require '../lib/report_builder'

ReportBuilder.configure do |config|
  config.json_path = '../testing/fixtures/json_reports'
  config.report_path = '../sample/report'
  config.report_title = 'My Test Results'
  config.color = 'blue'
  config.additional_info = {Browser: 'browser', Environment: 'environment', MoreInfo: 'more info'}
end

ReportBuilder.build_report

ReportBuilder.configure do |config|
  config.json_path = config.json_path = {
      'Group A' => ['../testing/fixtures/json_reports/report.json', '../testing/fixtures/json_reports/report1.json'],
      'Group B' => ['../testing/fixtures/json_reports/report2.json', '../testing/fixtures/json_reports/report3.json'],
      'Group C' => ['../testing/fixtures/json_reports/report4.json']}
  config.report_path = '../sample/group_report'
  config.report_title = 'My Test Results'
  config.voice_commands = true
  config.color = 'deep-purple'
  config.additional_info = {Browser: 'browser', Environment: 'environment', MoreInfo: 'more info'}
end

ReportBuilder.build_report
