require '../../lib/report_builder'

ReportBuilder.build_report(input_path: '../fixtures/json_reports',
                           include_images: false,
                           report_path: '../fixtures/combined_r1',
                           additional_info: { Environment: 'POC' })
