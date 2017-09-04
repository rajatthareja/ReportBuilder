require "#{File.dirname(__FILE__)}/spec_helper"

describe ReportBuilder do

  it 'correctly combines multiple JSON reports into a single json report' do
    input_1_path = "#{TEST_FIXTURES_DIRECTORY}/partial_json_1.json"
    input_2_path = "#{TEST_FIXTURES_DIRECTORY}/partial_json_2.json"
    input_3_path = "#{TEST_FIXTURES_DIRECTORY}/partial_json_3.json"
    output_location = Tempfile.new('new_report').path

    ReportBuilder.build_report(report_types: [:json], json_path: [input_1_path, input_2_path, input_3_path], report_path: output_location)

    combined_report = File.read("#{output_location}.json")
    expected_report = File.read("#{TEST_FIXTURES_DIRECTORY}/combined_json.json")


    expect(JSON.parse(combined_report)).to eq(JSON.parse(expected_report))
  end

  it 'correctly combines multiple JSON reports into a single retry' do
    input_1_path = "#{TEST_FIXTURES_DIRECTORY}/partial_json_1.json"
    input_2_path = "#{TEST_FIXTURES_DIRECTORY}/partial_json_2.json"
    input_3_path = "#{TEST_FIXTURES_DIRECTORY}/partial_json_3.json"
    output_location = Tempfile.new('new_report').path

    ReportBuilder.build_report(report_types: [:retry], json_path: [input_1_path, input_2_path, input_3_path], report_path: output_location)

    combined_report = File.read("#{output_location}.retry")
    expected_report = File.read("#{TEST_FIXTURES_DIRECTORY}/combined.retry")


    expect(combined_report).to eq(expected_report)
  end

  it 'produces the report without change during my refactoring' do
    output_location = Tempfile.new('new_report').path
    options = {
        json_path: "#{TEST_FIXTURES_DIRECTORY}/junit_reports/**",
        report_path: output_location,
        report_types: ['html'],
        report_tabs: ['overview', 'features', 'scenarios', 'errors'],
        report_title: 'Test Results',
        compress_images: false,
        additional_info: {'environment' => 'POC'}
    }

    ReportBuilder.build_report options
    generated_report = File.read("#{output_location}.html")
    expected_report = File.read("#{TEST_FIXTURES_DIRECTORY}/original.html")

    expect(generated_report).to eq(expected_report)

  end

end
