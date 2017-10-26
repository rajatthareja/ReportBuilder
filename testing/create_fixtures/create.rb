require '../../lib/report_builder'

ReportBuilder.build_report(report_title: 'Test Results',
                           input_path: '../fixtures/json_reports',
                           include_images: false,
                           report_path: '../fixtures/combined',
                           report_types: [:html, :json, :retry],
                           additional_info: { Environment: 'POC' })
