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

  it 'names all reports the same by default' do
    input_path = "#{TEST_FIXTURES_DIRECTORY}/partial_json_1.json"
    output_directory = ReportBuilder::FileHelper.create_directory

    generic_output_location = "#{output_directory}/report"

    ReportBuilder.build_report(report_types: [:json, :html, :retry], json_path: [input_path], report_path: generic_output_location)

    files_created = Dir.entries(output_directory)
    files_created.delete('.')
    files_created.delete('..')

    expect(files_created).to match_array(["#{File.basename(generic_output_location)}.json", "#{File.basename(generic_output_location)}.html", "#{File.basename(generic_output_location)}.retry"])
  end

  it 'can name reports individually' do
    input_path = "#{TEST_FIXTURES_DIRECTORY}/partial_json_1.json"
    output_directory = ReportBuilder::FileHelper.create_directory

    json_output_location = "#{output_directory}/json_report"
    html_output_location = "#{output_directory}/html_report"
    retry_output_location = "#{output_directory}/retry_report"

    ReportBuilder.build_report(report_types: [:json, :html, :retry], json_path: [input_path], json_report_path: json_output_location, html_report_path: html_output_location, retry_report_path: retry_output_location)

    files_created = Dir.entries(output_directory)
    files_created.delete('.')
    files_created.delete('..')

    expect(files_created).to match_array(["#{File.basename(json_output_location)}.json", "#{File.basename(html_output_location)}.html", "#{File.basename(retry_output_location)}.retry"])
  end

  it 'prioritizes specific report names over the general name' do
    input_path = "#{TEST_FIXTURES_DIRECTORY}/partial_json_1.json"
    output_directory = ReportBuilder::FileHelper.create_directory

    generic_output_location = "#{output_directory}/report"
    html_output_location = "#{output_directory}/html_report"

    ReportBuilder.build_report(report_types: [:json, :html, :retry], json_path: [input_path], report_path: generic_output_location, html_report_path: html_output_location)

    files_created = Dir.entries(output_directory)
    files_created.delete('.')
    files_created.delete('..')

    expect(files_created).to match_array(["#{File.basename(generic_output_location)}.json", "#{File.basename(html_output_location)}.html", "#{File.basename(generic_output_location)}.retry"])
  end

  describe 'report configuration' do

    it 'has a default configuration' do
      expect(ReportBuilder.configure).to eq({
                                              json_path: nil,
                                              report_path: 'test_report',
                                              report_types: [:html],
                                              report_tabs: [:overview, :features],
                                              report_title: 'Test Results',
                                              compress_images: false,
                                              additional_info: {}
                                            })
    end


    context 'with specific configuration' do

      let (:source_path) { "#{TEST_FIXTURES_DIRECTORY}/partial_json_1.json" }
      let (:report_directory) { ReportBuilder::FileHelper.create_directory }
      let (:report_file_path) { "#{report_directory}/report" }

      before(:each) do
        ReportBuilder.configure do |configuration|
          configuration.json_path = source_path
          configuration.report_path = report_file_path
          configuration.report_types = [:json, :retry]
        end
      end


      it 'uses the overridden configuration' do
        ReportBuilder.build_report

        files_created = Dir.entries(report_directory)
        files_created.delete('.')
        files_created.delete('..')

        expect(files_created).to match_array(["#{File.basename(report_file_path)}.json", "#{File.basename(report_file_path)}.retry"])
      end

    end

  end

end
