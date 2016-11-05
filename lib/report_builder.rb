require 'json'
require 'builder'
require 'base64'

# Add except method to Hash
class Hash
  def except(*keys)
    dup.except!(*keys)
  end

  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end
end

# Main report builder class
class ReportBuilder

# report_builder:
#
# ReportBuilder.configure do |config|
#   config.json_path = 'cucumber_sample/logs'
#   config.report_path = 'my_test_report'
#   config.report_types = [:json, :html]
#   config.report_tabs = [:overview, :features, :scenarios, :errors]
#   config.report_title = 'My Test Results'
#   config.compress_images = false
#   config.additional_info = {browser: 'Chrome', environment: 'Stage 5'}
# end
#
# ReportBuilder.build_report
#

  # colors corresponding to status
  COLOR = {
      passed: '#90ed7d',
      working: '#90ed7d',
      failed: '#f45b5b',
      broken: '#f45b5b',
      undefined: '#e4d354',
      incomplete: '#e7a35c',
      pending: '#f7a35c',
      skipped: '#7cb5ec',
      output: '#007fff'
  }

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
    default_options = OpenStruct.new(
        json_path:       nil,                    # [String] / [Array] Input json file, array of json files/path or json files path, (Default current directory)
        report_path:     'test_report',          # [String] Output file path with name
        report_types:    [:html],                # [Array] Output file types to build, [:json, :html] or ['html', 'json']
        report_tabs:     [:overview, :features], # [Array] Tabs to build, [:overview, :features, :scenarios, :errors] or ['overview', 'features', 'scenarios', 'errors']
        report_title:    'Test Results',         # [String] Report and html title
        compress_images: false,                  # [Boolean] Set true to reducing the size of HTML report, Note: If true, takes more time to build report
        additional_info: {}                      # [Hash] Additional info for report summary
    )
    yield default_options if block_given?
    @options = default_options.marshal_dump
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

    configure unless @options
    @options.merge! options if options.is_a? Hash

    raise 'Error: Invalid report_types Use: [:json, :html]' unless @options[:report_types].is_a? Array
    raise 'Error: Invalid report_tabs Use: [:overview, :features, :scenarios, :errors]' unless @options[:report_tabs].is_a? Array

    @options[:report_types].map!(&:to_s).map!(&:upcase)
    @options[:report_tabs].map!(&:to_s).map!(&:downcase)

    input = files @options[:json_path]
    all_features = features input rescue (raise 'ReportBuilderParsingError')

    File.open(@options[:report_path] + '.json', 'w') do |file|
      file.write JSON.pretty_generate all_features
      puts "JSON test report generated: '#{@options[:report_path]}.json'"
    end if @options[:report_types].include? 'JSON'

    all_scenarios = scenarios all_features
    all_steps = steps all_scenarios
    all_tags = tags all_scenarios
    total_time = total_time all_features
    feature_data = data all_features
    scenario_data = data all_scenarios
    step_data = data all_steps

    File.open(@options[:report_path] + '.html', 'w:UTF-8') do |file|
      @builder = Builder::XmlMarkup.new(target: file, indent: 0)
      @builder.declare!(:DOCTYPE, :html)
      @builder << '<html>'

      @builder.head do
        @builder.meta(charset: 'UTF-8')
        @builder.title @options[:report_title]

        @builder.style(type: 'text/css') do
          @builder << File.read(File.dirname(__FILE__) + '/../vendor/assets/stylesheets/jquery-ui.min.css')
          COLOR.each do |color|
            @builder << ".#{color[0].to_s}{background:#{color[1]};color:#434348;padding:2px}"
          end
          @builder << '.summary{margin-bottom:4px;border: 1px solid #c5c5c5;border-radius:4px;background:#f1f1f1;color:#434348;padding:4px;overflow:hidden;vertical-align:bottom;}'
          @builder << '.summary .results{text-align:right;float:right;}'
          @builder << '.summary .info{text-align:left;float:left;}'
          @builder << '.data_table{border-collapse: collapse;} .data_table td{padding: 5px; border: 1px solid #ddd;}'
          @builder << '.ui-tooltip{background: black; color: white; font-size: 12px; padding: 2px 4px; border-radius: 20px; box-shadow: 0 0 7px black;}'
        end

        @builder.script(type: 'text/javascript') do
          %w(jquery-min jquery-ui.min highcharts highcharts-3d).each do |js|
            @builder << File.read(File.dirname(__FILE__) + '/../vendor/assets/javascripts/' + js + '.js')
          end
          @builder << '$(function(){$("#results").tabs();});'
          @builder << "$(function(){$('#features').accordion({collapsible: true, heightStyle: 'content', active: false, icons: false});});"
          (0..all_features.size).each do |n|
            @builder << "$(function(){$('#feature#{n}').accordion({collapsible: true, heightStyle: 'content', active: false, icons: false});});"
          end
          @builder << "$(function(){$('#status').accordion({collapsible: true, heightStyle: 'content', active: false, icons: false});});"
          scenario_data.each do |data|
            @builder << "$(function(){$('##{data[:name]}').accordion({collapsible: true, heightStyle: 'content', active: false, icons: false});});"
          end
          @builder << '$(function() {$(document).tooltip({track: true});});'
        end
      end

      @builder << '<body>'

      @builder.div(class: 'summary') do
        @builder.span(class: 'info') do
          info = @options[:additional_info].empty?
          @builder << '<br/>&nbsp;&nbsp;&nbsp;' if info
          @builder.span(style: "font-size:#{info ? 36 : 18 }px;font-weight: bold;") do
            @builder << @options[:report_title]
          end
          @options[:additional_info].each do |l|
            @builder << '<br/>' + l[0].to_s.capitalize + ' : ' + l[1].to_s
          end
        end if @options[:additional_info].is_a? Hash
        @builder.span(class: 'results') do
          s = all_features.size
          @builder << s.to_s + " feature#{'s' if s > 1} ("
          feature_data.each do |data|
            @builder << ' ' + data[:count].to_s + ' ' + data[:name]
          end
          s = all_scenarios.size
          @builder << ')<br/>' + s.to_s + " scenario#{'s' if s > 1} ("
          scenario_data.each do |data|
            @builder << ' ' + data[:count].to_s + ' ' + data[:name]
          end
          s = all_steps.size
          @builder << ')<br/>' + s.to_s + " step#{'s' if s > 1} ("
          step_data.each do |data|
            @builder << ' ' + data[:count].to_s + ' ' + data[:name]
          end
          @builder << ')<br/>&#128336; ' + duration(total_time).to_s
        end
      end

      @builder.div(id: 'results') do
        build_menu @options[:report_tabs]

        @builder.div(id: 'overviewTab') do
          @builder << "<div id='featurePieChart' style=\"float:left;width:33%\"></div>"
          @builder << "<div id='scenarioPieChart' style=\"display:inline-block;width:33%\"></div>"
          @builder << "<div id='stepPieChart' style=\"float:right;width:33%\"></div>"
        end if @options[:report_tabs].include? 'overview'

        @builder.div(id: 'featuresTab') do
          build_tags_drop_down(all_tags)
          @builder.div(id: 'features') do
            all_features.each_with_index do |feature, n|
              @builder.h3(style: "background:#{COLOR[feature['status'].to_sym]}") do
                @builder.span(class: feature['status']) do
                  @builder << "<strong>#{feature['keyword']}</strong> #{feature['name']} (#{duration(feature['duration'])})"
                end
              end
              @builder.div do
                @builder.div(id: "feature#{n}") do
                  feature['elements'].each{|scenario| build_scenario scenario}
                end
              end
            end
          end
          @builder << "<div id='featureTabPieChart'></div>"
        end if @options[:report_tabs].include? 'features'

        @builder.div(id: 'scenariosTab') do
          build_tags_drop_down(all_tags)
          @builder.div(id: 'status') do
            all_scenarios.group_by{|scenario| scenario['status']}.each do |data|
              @builder.h3(style: "background:#{COLOR[data[0].to_sym]}") do
                @builder.span(class: data[0]) do
                  @builder << "<strong>#{data[0].capitalize} scenarios (Count: <span id='count'>#{data[1].size}</span>)</strong>"
                end
              end
              @builder.div do
                @builder.div(id: data[0]) do
                  data[1].sort_by{|scenario| scenario['name']}.each{|scenario| build_scenario scenario}
                end
              end
            end
          end
          @builder << "<div id='scenarioTabPieChart'></div>"
        end if @options[:report_tabs].include? 'scenarios'

        @builder.div(id: 'errorsTab') do
          @builder.ol do
            all_scenarios.each{|scenario| build_error_list scenario}
          end
        end if @options[:report_tabs].include? 'errors'
      end

      @builder.script(type: 'text/javascript') do
        @builder << pie_chart_js('featurePieChart', 'Features', feature_data) if @options[:report_tabs].include? 'overview'
        @builder << donut_js('featureTabPieChart', 'Features', feature_data) if @options[:report_tabs].include? 'features'
        @builder << pie_chart_js('scenarioPieChart', 'Scenarios', scenario_data) if @options[:report_tabs].include? 'overview'
        @builder << donut_js('scenarioTabPieChart', 'Scenarios', scenario_data) if @options[:report_tabs].include? 'scenarios'
        @builder << pie_chart_js('stepPieChart', 'Steps', step_data) if @options[:report_tabs].include? 'overview'
        unless all_tags.empty?
          @builder << '$("#featuresTab .select-tags").change(function(){
                $("#featuresTab .scenario-all").hide().next().hide().parent().hide().parent().hide().prev().hide();
                $("#featuresTab ." + $(this).val()).show().parent().show().parent().prev().show();});' if @options[:report_tabs].include? 'features'
          @builder << '$("#scenariosTab .select-tags").change(function(){var val = $(this).val();$("#scenariosTab .scenario-all").hide().next().hide();
                $("#scenariosTab ." + val).show();$("#scenariosTab #count").each(function(){status = $(this).parent().parent().prop("className");
                count = $("#scenariosTab #" + status + " ." + val).length;countElement = $("#scenariosTab ." + status + " #count");
                countElement.parent().parent().parent().show();if(count==0){countElement.parent().parent().parent().hide().next().hide();}
                countElement.html(count);});});' if @options[:report_tabs].include? 'scenarios'
        end
      end

      @builder << '</body>'
      @builder << '</html>'

      puts "HTML test report generated: '#{@options[:report_path]}.html'"
    end if @options[:report_types].include? 'HTML'

    [total_time, feature_data, scenario_data, step_data]
  end

  def self.build_menu(tabs)
    @builder.ul do
      tabs.each do |tab|
        @builder.li do
          @builder.a(href: "##{tab}Tab") do
            @builder << tab.capitalize
          end
        end
      end
    end
  end

  def self.build_scenario(scenario)
    tags = (scenario['tags'] ? scenario['tags'].map{|tag| tag['name']}.join(' ') : '')
    @builder.h3(style: "background:#{COLOR[scenario['status'].to_sym]}", title: tags, class: 'scenario-all ' + tags.gsub('@','tag-')) do
      @builder.span(class: scenario['status']) do
        @builder << "<strong>#{scenario['keyword']}</strong> #{scenario['name']} (#{duration(scenario['duration'])})"
      end
    end
    @builder.div do
      scenario['before'].each do |before|
        build_hook_error before
      end
      scenario['steps'].each do |step|
        build_step step, scenario['keyword']
      end
      scenario['after'].each do |after|
        build_output after['output']
        build_hook_error after
        build_embedding after['embeddings']
      end
    end
  end

  def self.build_step(step, scenario_keyword)
    @builder.div(class: step['status']) do
      @builder << "<strong>#{step['keyword']}</strong> #{step['name']} (#{duration(step['duration'])})"
    end
    build_data_table step['rows']
    build_output step['output']
    build_step_error step
    build_embedding step['embeddings']
    step['after'].each do |after|
      build_output after['output']
      build_step_hook_error after, scenario_keyword
      build_embedding after['embeddings']
    end if step['after']
  end

  def self.build_data_table(rows)
    @builder.table(class: 'data_table', style: 'margin: 10px') do
      rows.each do |row|
        @builder.tr do
          row['cells'].each do |cell|
            @builder << "<td> #{cell} </td>"
          end
        end
      end
    end if rows.is_a? Array
  end

  def self.build_output(outputs)
    outputs.each do |output|
      @builder << "<span style='color:#{COLOR[:output]}'>#{output.gsub("\n",'</br>').gsub("\t",'&nbsp;&nbsp;').gsub(' ','&nbsp;')}</span><br/>"
    end if outputs.is_a?(Array)
  end

  def self.build_tags_drop_down(tags)
    @builder.div(style: 'text-align:center;padding:5px;') do
      @builder << '<strong>Tag: </strong>'
      @builder.select(class: 'select-tags') do
        @builder.option(value: 'scenario-all') do
          @builder << 'All'
        end
        tags.sort.each do |tag|
          @builder.option(value: tag.gsub('@','tag-')) do
            @builder << tag
          end
        end
      end
    end if tags.is_a?(Array)
  end

  def self.build_step_error(step)
    if step['status'] == 'failed' && step['result']['error_message']
      @builder << "<strong style=color:#{COLOR[:failed]}>Error: </strong>"
      error = step['result']['error_message'].split("\n")
      @builder.span(style: "color:#{COLOR[:failed]}") do
        error[0..-3].each do |line|
          @builder << line + '<br/>'
        end
      end
      @builder << "<strong>SD: </strong>#{error[-2]} <br/>"
      @builder << "<strong>FF: </strong>#{error[-1]}<br/>"
    end
  end

  def self.build_hook_error(hook)
    if hook['status'] == 'failed'
      @builder << "<strong style=color:#{COLOR[:failed]}>Error: </strong>"
      error = hook['result']['error_message'].split("\n")
      @builder.span(style: "color:#{COLOR[:failed]}") do
        error[0..-2].each do |line|
          @builder << line + '<br/>'
        end
      end
      @builder << "<strong>Hook: </strong>#{error[-1]}<br/>"
    end
  end

  def self.build_step_hook_error(hook, scenario_keyword)
    if hook['result']['error_message']
      @builder << "<strong style=color:#{COLOR[:failed]}>Error: </strong>"
      error = hook['result']['error_message'].split("\n")
      @builder.span(style: "color:#{COLOR[:failed]}") do
        (scenario_keyword == 'Scenario Outline' ? error[0..-8] : error[0..-5]).each do |line|
          @builder << line + '<br/>'
        end
      end
      @builder << "<strong>Hook: </strong>#{scenario_keyword == 'Scenario Outline' ? error[-7] : error[-4]} <br/>"
      @builder << "<strong>FF: </strong>#{error[-2]}<br/>"
    end
  end

  def self.build_embedding(embeddings)
    @embedding_count ||= 0
    embeddings.each do |embedding|
      src = Base64.decode64(embedding['data'])
      id = "embedding_#{@embedding_count}"
      if embedding['mime_type'] =~ /^image\/(png|gif|jpg|jpeg)/
        begin
          @builder.span(class: 'image') do
            @builder.a(href: '', style: 'text-decoration: none;', onclick: "img=document.getElementById('#{id}');img.style.display = (img.style.display == 'none' ? 'block' : 'none');return false") do
              @builder.span(style: "color: #{COLOR[:output]}; font-weight: bold; border-bottom: 1px solid #{COLOR[:output]};") do
                @builder << "Screenshot ##{@embedding_count}"
              end
            end
            @builder << '<br/>'
            @options[:compress_images] ? build_unique_image(embedding, id) : build_image(embedding,id)
          end
        rescue => e
          puts 'Image embedding failed!'
          puts [e.class, e.message, e.backtrace[0..10].join("\n")].join("\n")
        end
      elsif embedding['mime_type'] =~ /^text\/plain/
        begin
          if src.include?('|||')
            title, link = src.split('|||')
            @builder.span(class: 'link') do
              @builder.a(id: id, style: 'text-decoration: none;', href: link, title: title) do
                @builder.span(style: "color: #{COLOR[:output]}; font-weight: bold; border-bottom: 1px solid #{COLOR[:output]};") do
                  @builder << title
                end
              end
              @builder << '<br/>'
            end
          else
            @builder.span(class: 'info') do
              @builder << src
              @builder << '<br/>'
            end
          end
        rescue => e
          puts('Link embedding skipped!')
          puts [e.class, e.message, e.backtrace[0..10].join("\n")].join("\n")
        end
      end
      @embedding_count += 1
    end if embeddings.is_a?(Array)
  end

  def self.build_unique_image(image, id)
    @images ||= []
    index = @images.find_index image
    if index
      klass = "image_#{index}"
    else
      @images << image
      klass = "image_#{@images.size - 1}"
      @builder.style(type: 'text/css') do
        begin
          src = Base64.decode64(image['data'])
          src = 'data:' + image['mime_type'] + ';base64,' + src unless src =~ /^data:image\/(png|gif|jpg|jpeg);base64,/
          @builder << "img.#{klass} {content: url(#{src});}"
        rescue
          src = image['data']
          src = 'data:' + image['mime_type'] + ';base64,' + src unless src =~ /^data:image\/(png|gif|jpg|jpeg);base64,/
          @builder << "img.#{klass} {content: url(#{src});}"
        end
      end
    end
    @builder << %{<img id='#{id}' class='#{klass}' style='display: none; border: 1px solid #{COLOR[:output]};' />}
  end

  def self.build_image(image, id)
    begin
      src = Base64.decode64(image['data'])
      src = 'data:' + image['mime_type'] + ';base64,' + src unless src =~ /^data:image\/(png|gif|jpg|jpeg);base64,/
      @builder << %{<img id='#{id}' style='display: none; border: 1px solid #{COLOR[:output]};' src='#{src}'/>}
    rescue
      src = image['data']
      src = 'data:' + image['mime_type'] + ';base64,' + src unless src =~ /^data:image\/(png|gif|jpg|jpeg);base64,/
      @builder << %{<img id='#{id}' style='display: none; border: 1px solid #{COLOR[:output]};' src='#{src}'/>}
    end
  end

  def self.build_error_list(scenario)
    scenario['before'].each do |before|
      next unless before['status'] == 'failed'
      @builder.li do
        error = before['result']['error_message'].split("\n")
        @builder.span(style: "color:#{COLOR[:failed]}") do
          error[0..-2].each do |line|
            @builder << line + '<br/>'
          end
        end
        @builder << "<strong>Hook: </strong>#{error[-1]} <br/>"
        @builder << "<strong>Scenario: </strong>#{scenario['name']} <br/><hr/>"
      end
    end
    scenario['steps'].each do |step|
      step['after'].each do |after|
        next unless after['status'] == 'failed'
        @builder.li do
          error = after['result']['error_message'].split("\n")
          @builder.span(style: "color:#{COLOR[:failed]}") do
            (scenario['keyword'] == 'Scenario Outline' ? error[0..-8] : error[0..-5]).each do |line|
              @builder << line + '<br/>'
            end
          end
          @builder << "<strong>Hook: </strong>#{scenario['keyword'] == 'Scenario Outline' ? error[-7] : error[-4]} <br/>"
          @builder << "<strong>FF: </strong>#{error[-2]} <br/><hr/>"
        end
      end if step['after']
      next unless step['status'] == 'failed' && step['result']['error_message']
      @builder.li do
        error = step['result']['error_message'].split("\n")
        @builder.span(style: "color:#{COLOR[:failed]}") do
          error[0..-3].each do |line|
            @builder << line + '<br/>'
          end
        end
        @builder << "<strong>SD: </strong>#{error[-2]} <br/>"
        @builder << "<strong>FF: </strong>#{error[-1]} <br/><hr/>"
      end
    end
    scenario['after'].each do |after|
      next unless after['status'] == 'failed'
      @builder.li do
        error = after['result']['error_message'].split("\n")
        @builder.span(style: "color:#{COLOR[:failed]}") do
          error[0..-2].each do |line|
            @builder << line + '<br/>'
          end
        end
        @builder << "<strong>Hook: </strong>#{error[-1]} <br/>"
        @builder << "<strong>Scenario: </strong>#{scenario['name']} <br/><hr/>"
      end
    end
  end

  def self.features(files)
    files.each_with_object([]) { |file, features|
      data = File.read(file)
      next if data.empty?
      features << JSON.parse(data)
    }.flatten.group_by { |feature|
      feature['uri']+feature['id']+feature['line'].to_s
    }.values.each_with_object([]) { |group, features|
      features << group.first.except('elements').merge('elements' => group.map{|feature| feature['elements']}.flatten)
    }.sort_by!{|feature| feature['name']}.each{|feature|
      if feature['elements'][0]['type'] == 'background'
        (0..feature['elements'].size-1).step(2) do |i|
          feature['elements'][i]['steps'] ||= []
          feature['elements'][i]['steps'].each{|step| step['name']+=(' ('+feature['elements'][i]['keyword']+')')}
          feature['elements'][i+1]['steps'] = feature['elements'][i]['steps'] + feature['elements'][i+1]['steps']
          feature['elements'][i+1]['before'] = feature['elements'][i]['before'] if feature['elements'][i]['before']
        end
        feature['elements'].reject!{|element| element['type'] == 'background'}
      end
      feature['elements'].each { |scenario|
        scenario['before'] ||= []
        scenario['before'].each { |before|
          before['result']['duration'] ||= 0
          before.merge! 'status' => before['result']['status'], 'duration' => before['result']['duration']
        }
        scenario['steps'] ||= []
        scenario['steps'].each { |step|
          step['result']['duration'] ||= 0
          duration = step['result']['duration']
          status = step['result']['status']
          step['after'].each { |after|
            after['result']['duration'] ||= 0
            duration += after['result']['duration']
            status = 'failed' if after['result']['status'] == 'failed'
            after.merge! 'status' => after['result']['status'], 'duration' => after['result']['duration']
          } if step['after']
          step.merge! 'status' => status, 'duration' => duration
        }
        scenario['after'] ||= []
        scenario['after'].each { |after|
          after['result']['duration'] ||= 0
          after.merge! 'status' => after['result']['status'], 'duration' => after['result']['duration']
        }
        scenario.merge! 'status' => scenario_status(scenario), 'duration' => total_time(scenario['before']) + total_time(scenario['steps']) + total_time(scenario['after'])
      }
      feature.merge! 'status' => feature_status(feature), 'duration' => total_time(feature['elements'])
    }
  end

  def self.feature_status(feature)
    feature_status = 'working'
    feature['elements'].each do |scenario|
      status = scenario['status']
      return 'broken' if status == 'failed'
      feature_status = 'incomplete' if %w(undefined pending).include?(status)
    end
    feature_status
  end

  def self.scenarios(features)
    features.map do |feature|
      feature['elements']
    end.flatten
  end

  def self.scenario_status(scenario)
    (scenario['before'] + scenario['steps'] + scenario['after']).each do |step|
      status = step['status']
      return status unless status == 'passed'
    end
    'passed'
  end

  def self.steps(scenarios)
    scenarios.map do |scenario|
      scenario['steps']
    end.flatten
  end

  def self.tags(scenarios)
    scenarios.map do |scenario|
      scenario['tags'] ? scenario['tags'].map{|t| t['name']} : []
    end.flatten.uniq
  end

  def self.files(path)
    files = if path.is_a? String
              (path =~ /\.json$/) ? [path] : Dir.glob("#{path}/*.json")
            elsif path.nil?
              Dir.glob('*.json')
            elsif path.is_a? Array
              path.map do |file|
                (file =~ /\.json$/) ? file : Dir.glob("#{file}/*.json")
              end.flatten
            else
              raise 'InvalidInput'
            end
    raise 'InvalidOrNoInputFile' if files.empty?
    files.uniq
  end

  def self.data(all_data)
    all_data.group_by{|db| db['status']}.map do |data|
      {name: data[0],
       count: data[1].size,
       color: COLOR[data[0].to_sym]}
    end
  end

  def self.total_time(data)
    total_time = 0
    data.each{|item| total_time += item['duration']}
    total_time
  end

  def self.duration(seconds)
    seconds = seconds.to_f/1000000000
    m, s = seconds.divmod(60)
    "#{m}m #{'%.3f' % s}s"
  end

  def self.pie_chart_js(id, title, data)
    data = data.each_with_object('') do |h, s|
      s << "{name: '#{h[:name].capitalize}'"
      s << ",y: #{h[:count]}"
      s << ',sliced: true' if h[:sliced]
      s << ',selected: true' if h[:selected]
      s << ",color: '#{h[:color]}'" if h[:color]
      s << '},'
    end.chop
    "$(function (){$('##{id}').highcharts({credits: {enabled: false}, chart: {type: 'pie',
     options3d: {enabled: true, alpha: 45, beta: 0}}, title: {text: '#{title}'},
     tooltip: {pointFormat: 'Count: <b>{point.y}</b><br/>Percentage: <b>{point.percentage:.1f}%</b>'},
     plotOptions: {pie: {allowPointSelect: true, cursor: 'pointer', depth: 35, dataLabels: {enabled: true,
     format: '{point.name}'}}}, series: [{type: 'pie', name: 'Results', data: [#{data}]}]});});"
  end

  def self.donut_js(id, title, data)
    data = data.each_with_object('') do |h, s|
      s << "{name: '#{h[:name].capitalize}'"
      s << ",y: #{h[:count]}"
      s << ',sliced: true' if h[:sliced]
      s << ',selected: true' if h[:selected]
      s << ",color: '#{h[:color]}'" if h[:color]
      s << '},'
    end.chop
    "$(function (){$('##{id}').highcharts({credits: {enabled: false},
     chart: {plotBackgroundColor: null, plotBorderWidth: 0, plotShadow: false, width: $(document).width()-80},
     title: {text: '#{title}', align: 'center', verticalAlign: 'middle', y: 40},
     tooltip: {pointFormat: 'Count: <b>{point.y}</b><br/>Percentage: <b>{point.percentage:.1f}%</b>'},
     plotOptions: {pie: {dataLabels: {enabled: true, distance: -50,
     style: {fontWeight: 'bold', color: 'white', textShadow: '0px 1px 2px black'}},
     startAngle: -90, endAngle: 90, center: ['50%', '75%']}},
     series: [{type: 'pie', innerSize: '50%', name: 'Results', data: [#{data}]}]});});"
  end

  private_class_method :donut_js, :pie_chart_js, :files,
                       :features, :feature_status,
                       :scenarios, :scenario_status, :steps,
                       :data, :duration, :total_time,
                       :build_scenario, :build_step,
                       :build_menu, :build_output, :build_embedding,
                       :build_error_list, :build_step_error,
                       :build_hook_error, :build_step_hook_error,
                       :build_unique_image, :build_image,
                       :build_data_table, :tags, :build_tags_drop_down
end
