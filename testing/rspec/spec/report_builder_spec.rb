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

    combined_report = File.read("#{output_location}.txt")
    expected_report = File.read("#{TEST_FIXTURES_DIRECTORY}/combined_retry.txt")


    expect(combined_report).to eq(expected_report)
  end

end
