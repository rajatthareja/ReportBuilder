require 'json'
require 'erb'
require 'pathname'
require 'base64'

require 'report_builder/core-ext/hash'

module ReportBuilder
  class Builder

    attr_accessor :options

    def build_report(opts = nil)
      options = self.options || default_options.marshal_dump
      options.merge! opts if opts.is_a? Hash

      raise 'Error:: Invalid report_types. Use: [:json, :html]' unless options[:report_types].is_a? Array

      options[:report_types].map!(&:to_s).map!(&:upcase)

      files = get_files options[:json_path]
      raise "Error:: No file(s) found at #{options[:json_path]}" if files.empty?

      features = get_features(files) rescue raise('Error:: Invalid Input File(s). Please provide valid cucumber JSON output file(s)')

      json_report_path = options[:json_report_path] || options[:report_path]
      File.open(json_report_path + '.json', 'w') do |file|
        file.write JSON.pretty_generate features
      end if options[:report_types].include? 'JSON'

      html_report_path = options[:html_report_path] || options[:report_path]
      File.open(html_report_path + '.html', 'w:UTF-8') do |file|
        file.write ERB.new(File.read(File.dirname(__FILE__) + '/../../template/html_report.erb')).result(binding).gsub('  ', '').gsub("\n\n", '')
      end if options[:report_types].include? 'HTML'

      retry_report_path = options[:retry_report_path] || options[:report_path]
      File.open(retry_report_path + '.retry', 'w:UTF-8') do |file|
        features.each do |feature|
          if feature['status'] == 'broken'
            feature['elements'].each {|scenario| file.puts "#{feature['uri']}:#{scenario['line']}" if scenario['status'] == 'failed'}
          end
        end
      end if options[:report_types].include? 'RETRY'
      [json_report_path, html_report_path, retry_report_path]
    end

    def default_options
      OpenStruct.new(
          json_path: Dir.pwd, # [String] / [Array] Input json file, array of json files/path or json files path, (Default current directory)
          report_path: 'test_report', # [String] Output file path with name
          report_types: [:html], # [Array] Output file types to build, [:json, :html] or ['html', 'json']
          report_title: 'Test Results', # [String] Report and html title
          include_images: true, # [Boolean] Set false to reducing the size of HTML report, by excluding embedded images
          additional_info: {} # [Hash] Additional info for report summary
      )
    end

    def decode(data)
      Base64.decode64(data) rescue data
    end

    private

    def get_files(path)
      if path.is_a?(String) and Pathname.new(path).exist?
        if Pathname.new(path).directory?
          Dir.glob("#{path}/*.json")
        else
          [path]
        end
      elsif path.is_a? Array
        path.map do |file|
          if Pathname.new(file).exist?
            if Pathname.new(file).directory?
              Dir.glob("#{file}/*.json")
            else
              file
            end
          else
            []
          end
        end.flatten
      else
        []
      end.uniq
    end

    def get_features(files)
      files.each_with_object([]) {|file, features|
        data = File.read(file)
        next if data.empty?
        features << JSON.parse(data) rescue next
      }.flatten.group_by {|feature|
        feature['uri']+feature['id']+feature['line'].to_s
      }.values.each_with_object([]) {|group, features|
        features << group.first.except('elements').merge('elements' => group.map {|feature| feature['elements']}.flatten)
      }.sort_by! {|feature| feature['name']}.each {|feature|
        if feature['elements'][0]['type'] == 'background'
          (0..feature['elements'].size-1).step(2) do |i|
            feature['elements'][i]['steps'] ||= []
            feature['elements'][i]['steps'].each {|step| step['name']+=(' ('+feature['elements'][i]['keyword']+')')}
            feature['elements'][i+1]['steps'] = feature['elements'][i]['steps'] + feature['elements'][i+1]['steps']
            feature['elements'][i+1]['before'] = feature['elements'][i]['before'] if feature['elements'][i]['before']
          end
          feature['elements'].reject! {|element| element['type'] == 'background'}
        end
        feature['elements'].each {|scenario|
          scenario['before'] ||= []
          scenario['before'].each {|before|
            before['result']['duration'] ||= 0
            before.merge! 'status' => before['result']['status'], 'duration' => before['result']['duration']
          }
          scenario['steps'] ||= []
          scenario['steps'].each {|step|
            step['result']['duration'] ||= 0
            duration = step['result']['duration']
            status = step['result']['status']
            step['after'].each {|after|
              after['result']['duration'] ||= 0
              duration += after['result']['duration']
              status = 'failed' if after['result']['status'] == 'failed'
              after.merge! 'status' => after['result']['status'], 'duration' => after['result']['duration']
            } if step['after']
            step.merge! 'status' => status, 'duration' => duration
          }
          scenario['after'] ||= []
          scenario['after'].each {|after|
            after['result']['duration'] ||= 0
            after.merge! 'status' => after['result']['status'], 'duration' => after['result']['duration']
          }
          scenario.merge! 'status' => scenario_status(scenario), 'duration' => total_time(scenario['before']) + total_time(scenario['steps']) + total_time(scenario['after'])
        }
        feature.merge! 'status' => feature_status(feature), 'duration' => total_time(feature['elements'])
      }
    end

    def feature_status(feature)
      feature_status = 'working'
      feature['elements'].each do |scenario|
        status = scenario['status']
        return 'broken' if status == 'failed'
        feature_status = 'incomplete' if %w(undefined pending).include?(status)
      end
      feature_status
    end

    def scenario_status(scenario)
      (scenario['before'] + scenario['steps'] + scenario['after']).each do |step|
        status = step['status']
        return status unless status == 'passed'
      end
      'passed'
    end

    def total_time(data)
      total_time = 0
      data.each {|item| total_time += item['duration']}
      total_time
    end

    def duration(seconds)
      seconds = seconds.to_f/1000000000
      m, s = seconds.divmod(60)
      "#{m}m #{'%.3f' % s}s"
    end
  end
end
