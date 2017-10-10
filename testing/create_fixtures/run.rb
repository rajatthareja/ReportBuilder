require  '../../lib/report_builder'

ReportBuilder.configure do |config|
  config.json_path = '../fixtures/json_reports'
  config.report_path = '../../docs/index'
  config.report_types = [:html]
  config.report_title = 'My Test Results'
  config.include_images = true
  config.additional_info = {Browser: 'browser', Environment: 'environment', MoreInfo: 'more info'}
end

ReportBuilder.build_report

ReportBuilder.build_report({   report_title: 'Test Results',
                               include_images: false,
                               report_path: '../fixtures/combined',
                               report_types: [:html, :json, :retry],
                               additional_info: {Environment: 'POC'}
                           })
