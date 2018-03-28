require_relative 'report_builder/builder'

##
# ReportBuilder Main module
#
module ReportBuilder

  ##
  # ReportBuilder options
  #
  def self.options
    @options ||= {
      input_path: Dir.pwd,
      report_types: [:html],
      report_title: 'Test Results',
      include_images: true,
      voice_commands: false,
      additional_info: {},
      report_path: 'test_report',
      color: 'brown'
    }
  end

  ##
  # Configure ReportBuilder
  #
  # Example:
  #
  #     ReportBuilder.configure do |config|
  #       config.input_path = 'cucumber_sample/logs'
  #       config.report_path = 'my_test_report'
  #       config.report_types = [:RETRY, :HTML]
  #       config.report_title = 'My Test Results'
  #       config.include_images = true
  #       config.voice_commands = true
  #       config.additional_info = {Browser: 'Chrome', Environment: 'Stage 5'}
  #     end
  #
  def self.configure
    options
    more_options = OpenStruct.new
    yield more_options if block_given?
    @options.merge! more_options.marshal_dump
  end

  ##
  # Build Report
  #
  # @param [Hash] more_options override the default and configured options.
  #
  # Example:
  #
  #     options = {
  #       json_path:    'cucumber_sample/logs',
  #       report_path:  'my_test_report',
  #       report_types: ['retry', 'html'],
  #       report_title: 'My Test Results',
  #       include_images: true,
  #       voice_commands: true,
  #       color: 'deep-purple',
  #       additional_info: {'browser' => 'Chrome', 'environment' => 'Stage 5'}
  #     }
  #
  #     ReportBuilder.build_report options
  #
  def self.build_report(more_options = {})
    options
    if more_options.is_a? String
      @options[:input_path] = more_options
    elsif more_options.is_a? Hash
      @options.merge! more_options
    end
    @options[:input_path] = @options[:json_path] if @options[:json_path]
    @options[:report_types] = [@options[:report_types]] unless @options[:report_types].is_a? Array
    @options[:report_types].map!(&:to_s).map!(&:upcase)
    Builder.new.build_report
  end

  ##
  # Set Report Builder input json files path / array of json files or path / hash of json files or path
  #
  # @param [String/Array/Hash] json_path input json files path / array of json files or path / hash of json files or path
  #
  # Example:
  #
  #     ReportBuilder.json_path = 'my_project/cucumber_json'
  #
  def self.json_path=(json_path)
    options
    @options[:input_path] = json_path
  end

  ##
  # Returns Report Builder input json files path / array of json files or path / hash of json files or path
  #
  # @return [String/Array/Hash] json_path input json files path / array of json files or path / hash of json files or path
  #
  def self.json_path
    options[:input_path]
  end

  ##
  # Set Report Builder input json files path / array of json files or path / hash of json files or path
  #
  # @param [String/Array/Hash] input_path input json files path / array of json files or path / hash of json files or path
  #
  # Example:
  #
  #     ReportBuilder.input_path = 'my_project/cucumber_json'
  #
  def self.input_path=(input_path)
    options
    @options[:input_path] = input_path
  end

  ##
  # Returns Report Builder input json files path / array of json files or path / hash of json files or path
  #
  # @return [String/Array/Hash] input_path input json files path / array of json files or path / hash of json files or path
  #
  def self.input_path
    options[:input_path]
  end

  ##
  # Set Report Builder report_types :json, :html, :retry (output file types)
  #
  # @param [Array] report_types :json, :html, :retry (output file types)
  #
  # Example:
  #
  #     ReportBuilder.report_types = [:html, :retry]
  #
  def self.report_types=(report_types)
    options
    @options[:report_types] = report_types.is_a? Array ? report_types : [report_types]
  end

  ##
  # Returns Report Builder report_types :json, :html, :retry (output file types)
  #
  # @return [Array] report_types :json, :html, :retry (output file types)
  #
  def self.report_types
    options[:report_types]
  end

  ##
  # Set Report Builder HTML report title
  #
  # @param [String] report_title HTML report title
  #
  # Example:
  #
  #     ReportBuilder.report_title = 'My Report'
  #
  def self.report_title=(report_title)
    options
    @options[:report_title] = report_title if report_title.is_a? String
  end

  ##
  # Returns Report Builder HTML report title
  #
  # @return [String] report_title HTML report title
  #
  def self.report_title
    options[:report_title]
  end

  ##
  # Set Report Builder include or excluding embedded images
  #
  # @param [Boolean] include_images include or excluding embedded images
  #
  # Example:
  #
  #     ReportBuilder.include_images = false
  #
  def self.include_images=(include_images)
    options
    @options[:include_images] = include_images if !!include_images == include_images
  end

  ##
  # Returns Report Builder include or excluding embedded images
  #
  # @return [Boolean] include_images include or excluding embedded images
  #
  def self.include_images
    options[:include_images]
  end

  ##
  # Set Report Builder enable or disable voice commands
  #
  # @param [Boolean] voice_commands enable or disable voice commands
  #
  # Example:
  #
  #     ReportBuilder.voice_commands = true
  #
  def self.voice_commands=(voice_commands)
    options
    @options[:voice_commands] = voice_commands if !!voice_commands == voice_commands
  end

  ##
  # Returns Report Builder enable or disable voice commands
  #
  # @return [Boolean] voice_commands enable or disable voice commands
  #
  def self.voice_commands
    options[:voice_commands]
  end

  ##
  # Set Report Builder additional info for report summary
  #
  # @param [Hash] additional_info additional info for report summary
  #
  # Example:
  #
  #     ReportBuilder.additional_info = {'Environment' => 'Abc Environment', 'Browser' => 'Chrome'}
  #
  def self.additional_info=(additional_info)
    options
    @options[:additional_info] = additional_info if additional_info.is_a? Hash
  end

  ##
  # Returns Report Builder additional info for report summary
  #
  # @return [Hash] additional_info additional info for report summary
  #
  def self.additional_info
    options[:additional_info]
  end

  ##
  # Set Report Builder reports output file path with file name without extension
  #
  # @param [String] report_path reports output file path with file name without extension
  #
  # Example:
  #
  #     ReportBuilder.report_path = 'reports/report'
  #
  def self.report_path=(report_path)
    options
    options[:report_path] = report_path if report_path.is_a? String
  end

  ##
  # Returns Report Builder reports output file path with file name without extension
  #
  # @return [String] report_path reports output file path with file name without extension
  #
  def self.report_path
    options[:report_path]
  end

  ##
  # Set Report Builder json report output file path with file name without extension
  #
  # @param [String] json_report_path json report output file path with file name without extension
  #
  # Example:
  #
  #     ReportBuilder.json_report_path = 'reports/report'
  #
  def self.json_report_path=(json_report_path)
    options
    @options[:json_report_path] = json_report_path if json_report_path.is_a? String
  end

  ##
  # Returns Report Builder json report output file path with file name without extension
  #
  # @return [String] json_report_path json report output file path with file name without extension
  #
  def self.json_report_path
    options[:json_report_path] || options[:report_path]
  end

  ##
  # Set Report Builder html report output file path with file name without extension
  #
  # @param [String] html_report_path html report output file path with file name without extension
  #
  # Example:
  #
  #     ReportBuilder.html_report_path = 'reports/report'
  #
  def self.html_report_path=(html_report_path)
    options
    @options[:html_report_path] = html_report_path if html_report_path.is_a? String
  end

  ##
  # Returns Report Builder html report output file path with file name without extension
  #
  # @return [String] html_report_path html report output file path with file name without extension
  #
  def self.html_report_path
    options[:html_report_path] || options[:report_path]
  end

  ##
  # Set Report Builder retry report output file path with file name without extension
  #
  # @param [String] retry_report_path retry report output file path with file name without extension
  #
  # Example:
  #
  #     ReportBuilder.retry_report_path = 'reports/report'
  #
  def self.retry_report_path=(retry_report_path)
    options
    @options[:retry_report_path] = retry_report_path if retry_report_path.is_a? String
  end

  ##
  # Returns Report Builder retry report output file path with file name without extension
  #
  # @return [String] retry_report_path retry report output file path with file name without extension
  #
  def self.retry_report_path
    options[:retry_report_path] || options[:report_path]
  end

  ##
  # Set Report Builder additional CSS string or CSS file path or CSS file url for customizing html report
  #
  # @param [String] additional_css additional CSS string or CSS file path or CSS file url for customizing html report
  #
  # Example:
  #
  #     ReportBuilder.additional_css = 'css/style.css'
  #
  def self.additional_css=(additional_css)
    options
    @options[:additional_css] = additional_css if additional_css.is_a? String
  end

  ##
  # Returns Report Builder additional CSS string or CSS file path or CSS file url for customizing html report
  #
  # @return [String] additional_css additional CSS string or CSS file path or CSS file url for customizing html report
  #
  def self.additional_css
    options[:additional_css]
  end

  ##
  # Set Report Builder additional JS string or JS file path or JS file url for customizing html report
  #
  # @param [String] additional_js additional JS string or JS file path or JS file url for customizing html report
  #
  # Example:
  #
  #     ReportBuilder.json_report_path = 'js/script.js'
  #
  def self.additional_js=(additional_js)
    options
    @options[:additional_js=] = additional_js if additional_js.is_a? String
  end

  ##
  # Returns Report Builder additional JS string or JS file path or JS file url for customizing html report
  #
  # @return [String] additional_js additional JS string or JS file path or JS file url for customizing html report
  #
  def self.additional_js
    options[:additional_js]
  end

  ##
  # Set Report Builder report color, Ex: indigo, cyan, purple, grey, lime etc.
  #
  # @param [String] color report color, Ex: indigo, cyan, purple, grey, lime etc.
  #
  # Example:
  #
  #     ReportBuilder.color = 'purple'
  #
  def self.color=(color)
    options
    @options[:color] = color if color.is_a? String
  end

  ##
  # Returns Report Builder report color, Ex: indigo, cyan, purple, grey, lime etc.
  #
  # @return [String] color report color, Ex: indigo, cyan, purple, grey, lime etc.
  #
  def self.color
    options[:color]
  end

  ##
  # Set Report Builder Options
  #
  # @param [String] option
  # @param [String] value
  #
  # Example:
  #
  #     ReportBuilder.set('title', 'My Features')
  #
  def self.set_option(option, value)
    options
    @options[option.to_sym] = value
  end

  ##
  # Set Report Builder Options
  #
  # @param [String] option
  # @param [String] value
  #
  # Example:
  #
  #     ReportBuilder.set('title', 'My Features')
  #
  def self.set(option, value)
    set_option(option, value)
  end
end
