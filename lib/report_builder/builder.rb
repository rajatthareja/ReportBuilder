require 'json'
require 'erb'
require 'pathname'
require 'base64'
require 'ostruct'

require 'report_builder/core-ext/hash'

module ReportBuilder

  ##
  # ReportBuilder Main class
  #
  class Builder

    ##
    # ReportBuilder Main method
    #
    def build_report
      options = ReportBuilder.options

      groups = get_groups options[:input_path]

      json_report_path = options[:json_report_path] || options[:report_path]
      if options[:report_types].include? 'JSON'
        File.open(json_report_path + '.json', 'w') do |file|
          file.write JSON.pretty_generate(groups.size > 1 ? groups : groups.first['features'])
        end
      end

      if options[:additional_css] and Pathname.new(options[:additional_css]).file?
        options[:additional_css] = File.read(options[:additional_css])
      end

      if options[:additional_js] and Pathname.new(options[:additional_js]).file?
        options[:additional_js] = File.read(options[:additional_js])
      end

      html_report_path = options[:html_report_path] || options[:report_path]
      if options[:report_types].include? 'HTML'
        File.open(html_report_path + '.html', 'w') do |file|
          file.write get(groups.size > 1 ? 'group_report' : 'report').result(binding).gsub('  ', '').gsub("\n\n", '')
        end
      end

      retry_report_path = options[:retry_report_path] || options[:report_path]
      if options[:report_types].include? 'RETRY'
        File.open(retry_report_path + '.retry', 'w') do |file|
          groups.each do |group|
            group['features'].each do |feature|
              if feature['status'] == 'broken'
                feature['elements'].each do |scenario|
                  file.puts "#{feature['uri']}:#{scenario['line']}" if scenario['status'] == 'failed'
                end
              end
            end
          end
        end
      end
      [json_report_path, html_report_path, retry_report_path]
    end

    private

    def get(template)
      @erb ||= {}
      @erb[template] ||= ERB.new(File.read(File.dirname(__FILE__) + '/../../template/' + template + '.erb'), nil, nil, '_' + template)
    end

    def get_groups(input_path)
      groups = []
      if input_path.is_a? Hash
        input_path.each do |group_name, group_path|
          files = get_files group_path
          puts "Error:: No file(s) found at #{group_path}" if files.empty?
          groups << {'name' => group_name, 'features' => get_features(files)} rescue next
        end
        raise 'Error:: Invalid Input File(s). Please provide valid cucumber JSON output file(s)' if groups.empty?
      else
        files = get_files input_path
        raise "Error:: No file(s) found at #{input_path}" if files.empty?
        groups << {'features' => get_features(files)} # rescue raise('Error:: Invalid Input File(s). Please provide valid cucumber JSON output file(s)')
      end
      groups
    end

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
      files.each_with_object([]) do |file, features|
        data = File.read(file)
        next if data.empty?
        begin
          features << JSON.parse(data)
        rescue StandardError
          puts 'Warning:: Invalid Input File ' + file
          next
        end
      end.flatten.group_by do |feature|
        feature['uri'] + feature['id'] + feature['line'].to_s
      end.values.each_with_object([]) do |group, features|
        features << group.first.except('elements').merge('elements' => group.map {|feature| feature['elements']}.flatten)
      end.sort_by! do |feature|
        feature['name']
      end.each do |feature|
        feature['name'] = ERB::Util.html_escape feature['name']
        if feature['elements'][0]['type'] == 'background'
          (0..feature['elements'].size-1).step(2) do |i|
            feature['elements'][i]['steps'] ||= []
            feature['elements'][i]['steps'].each {|step| step['name'] += (' (' + feature['elements'][i]['keyword'] + ')')}
            if feature['elements'][i+1]
              feature['elements'][i+1]['steps'] = feature['elements'][i]['steps'] + feature['elements'][i+1]['steps']
              feature['elements'][i+1]['before'] = feature['elements'][i]['before'] if feature['elements'][i]['before']
            end
          end
          feature['elements'].reject! do |element|
            element['type'] == 'background'
          end
        end
        feature['elements'].each do |scenario|
          scenario['name'] = ERB::Util.html_escape scenario['name']
          scenario['before'] ||= []
          scenario['before'].each do |before|
            before['result']['duration'] ||= 0
            if before['embeddings']
              before['embeddings'].map! do |embedding|
                decode_embedding(embedding)
              end
            end
            before.merge! 'status' => before['result']['status'], 'duration' => before['result']['duration']
          end
          scenario['steps'] ||= []
          scenario['steps'].each do |step|
            step['name'] = ERB::Util.html_escape step['name']
            step['result']['duration'] ||= 0
            duration = step['result']['duration']
            status = step['result']['status']
            if step['after']
              step['after'].each do |after|
                after['result']['duration'] ||= 0
                duration += after['result']['duration']
                status = 'failed' if after['result']['status'] == 'failed'
                if after['embeddings']
                  after['embeddings'].map! do |embedding|
                    decode_embedding(embedding)
                  end
                end
                after.merge! 'status' => after['result']['status'], 'duration' => after['result']['duration']
              end
            end
            if step['embeddings']
              step['embeddings'].map! do |embedding|
                decode_embedding(embedding)
              end
            end
            step.merge! 'status' => status, 'duration' => duration
          end
          scenario['after'] ||= []
          scenario['after'].each do |after|
            after['result']['duration'] ||= 0
            if after['embeddings']
              after['embeddings'].map! do |embedding|
                decode_embedding(embedding)
              end
            end
            after.merge! 'status' => after['result']['status'], 'duration' => after['result']['duration']
          end
          scenario.merge! 'status' => scenario_status(scenario), 'duration' => total_time(scenario['before']) + total_time(scenario['steps']) + total_time(scenario['after'])
        end
        feature['elements'] = feature['elements'].group_by do |scenario|
          scenario['id'] + scenario['line'].to_s
        end.values.map do |scenario_group|
          the_scenario = scenario_group.find do |scenario|
            scenario['status'] == 'passed'
          end || scenario_group.first
          if scenario_group.size > 1
            the_scenario['name'] += " (x#{scenario_group.size})"
          end
          the_scenario
        end
        feature.merge! 'status' => feature_status(feature), 'duration' => total_time(feature['elements'])
      end
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

    def decode_image(data)
      base64 = %r{^([A-Za-z0-9+\/]{4})*([A-Za-z0-9+\/]{4}|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{2}==)$}
      if data =~ base64
        data_base64 = Base64.urlsafe_decode64(data).gsub(%r{^data:image\/(png|gif|jpg|jpeg)\;base64,}, '') rescue data
        if data_base64 =~ base64
          data_base64
        else
          data
        end
      else
        ''
      end
    end

    def decode_text(data)
      Base64.urlsafe_decode64 data rescue ''
    end

    def decode_embedding(embedding)
      if embedding['mime_type'] =~ /^image\/(png|gif|jpg|jpeg)/
        embedding['data'] = decode_image(embedding['data'])
      elsif embedding['mime_type'] =~ /^text\/(plain|html)/
        embedding['data'] = decode_text(embedding['data'])
      end
      embedding
    end

    def total_time(data)
      total_time = 0
      data.each {|item| total_time += item['duration']}
      total_time
    end

    def duration(ms)
      s = ms.to_f/1000000000
      m, s = s.divmod(60)
      if m > 59
        h, m = m.divmod(60)
        "#{h}h #{m}m #{'%.2f' % s}s"
      elsif m > 0
        "#{m}m #{'%.2f' % s}s"
      else
        "#{'%.3f' % s}s"
      end
    end
  end
end
