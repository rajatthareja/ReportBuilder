require "#{File.dirname(__FILE__)}/spec_helper"

describe 'gem executable' do

  describe 'option flags' do

    it 'generates a named json report with --json_out' do
      input_path = "#{TEST_FIXTURES_DIRECTORY}/partial_json_1.json"
      output_directory = ReportBuilder::FileHelper.create_directory
      json_output_location = "#{output_directory}/json_report"

      `ruby #{BIN_DIRECTORY}/report_builder -s #{input_path} -f json --json_out #{json_output_location}`

      files_created = Dir.entries(output_directory)
      files_created.delete('.')
      files_created.delete('..')

      expect(files_created).to match_array(["#{File.basename(json_output_location)}.json"])
    end

    it 'generates a named html report with --html_out' do
      input_path = "#{TEST_FIXTURES_DIRECTORY}/partial_json_1.json"
      output_directory = ReportBuilder::FileHelper.create_directory
      html_output_location = "#{output_directory}/html_report"

      `ruby #{BIN_DIRECTORY}/report_builder -s #{input_path} -f html --html_out #{html_output_location}`

      files_created = Dir.entries(output_directory)
      files_created.delete('.')
      files_created.delete('..')

      expect(files_created).to match_array(["#{File.basename(html_output_location)}.html"])
    end

    it 'generates a named retry report with --retry_out' do
      input_path = "#{TEST_FIXTURES_DIRECTORY}/partial_json_1.json"
      output_directory = ReportBuilder::FileHelper.create_directory
      retry_output_location = "#{output_directory}/retry_report"

      `ruby #{BIN_DIRECTORY}/report_builder -s #{input_path} -f retry --retry_out #{retry_output_location}`

      files_created = Dir.entries(output_directory)
      files_created.delete('.')
      files_created.delete('..')

      expect(files_created).to match_array(["#{File.basename(retry_output_location)}.retry"])
    end

  end

end
