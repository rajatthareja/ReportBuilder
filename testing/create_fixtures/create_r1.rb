require '../../lib/report_builder'

ReportBuilder.build_report(input_path: '../fixtures/json_reports',
                           include_images: false,
                           report_path: '../fixtures/combined_r1',
                           additional_info: { Environment: 'POC' })

ReportBuilder.build_report(input_path: { 'Group A' => ['../fixtures/json_reports/report.json', '../fixtures/json_reports/report2.json'],
                                         'Group B' => ['../fixtures/json_reports/report3.json', '../fixtures/json_reports/report4.json'] },
                           include_images: false,
                           report_path: '../fixtures/combined_g_r1',
                           additional_info: { Environment: 'POC' })
