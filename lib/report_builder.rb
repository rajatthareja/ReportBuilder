require_relative 'report_builder/builder'

##
# ReportBuilder Main module
#
module ReportBuilder
  ##
  # Configure ReportBuilder
  #
  # Example:
  #
  #     ReportBuilder.configure do |config|
  #       config.json_path = 'cucumber_sample/logs'
  #       config.report_path = 'my_test_report'
  #       config.report_types = [:JSON, :HTML]
  #       config.report_title = 'My Test Results'
  #       config.include_images = true
  #       config.voice_commands = true
  #       config.additional_info = {Browser: 'Chrome', Environment: 'Stage 5'}
  #     end
  #
  def self.configure
    defaults = builder.default_options
    yield defaults if block_given?
    builder.options = defaults.marshal_dump
  end

  ##
  # Set single option
  #
  # @param [String] option
  # @param [Object] value
  #
  # Example:
  #
  #     ReportBuilder.set_option('include_images', false)
  #
  def self.set_option(option, value)
    builder.options ||= builder.default_options.marshal_dump
    builder.options[option] = value
  end

  ##
  # Build Report
  #
  # @param [Hash] options override the default and configured options.
  #
  # Example:
  #
  #     options = {
  #       json_path:    'cucumber_sample/logs',
  #       report_path:  'my_test_report',
  #       report_types: ['json', 'html'],
  #       report_title: 'My Test Results',
  #       include_images: true,
  #       voice_commands: true,
  #       color: 'deep-purple',
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
