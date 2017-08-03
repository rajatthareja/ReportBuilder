require 'report_builder/builder'


module ReportBuilder
  
  #
  # Ex: ReportBuilder.configure do |config|
  #       config.json_path = 'cucumber_sample/logs'
  #       config.report_path = 'my_test_report'
  #       config.report_types = [:JSON, :HTML]
  #       config.report_tabs = [:Overview, :Features, :Scenarios, :Errors]
  #       config.report_title = 'My Test Results'
  #       config.compress_images = true
  #       config.additional_info = {Browser: 'Chrome', Environment: 'Stage 5'}
  #      end
  #
  def self.configure
    defaults = builder.default_options
    yield defaults if block_given?
    builder.options = defaults.marshal_dump
  end

  #
  # @param [Hash] options override the default and configured options.
  #
  # Ex: options = {
  #       json_path:    'cucumber_sample/logs',
  #       report_path:  'my_test_report',
  #       report_types: ['json', 'html'],
  #       report_tabs:  [ 'overview', 'features', 'scenarios', 'errors'],
  #       report_title: 'My Test Results',
  #       compress_images: false,
  #       additional_info: {'browser' => 'Chrome', 'environment' => 'Stage 5'}
  #     }
  #
  #     ReportBuilder.build_report options
  #
  def self.build_report(options = nil)
    builder.build_report(options)
  end

  def self.builder
    @builder ||= Builder.new
  end

end
