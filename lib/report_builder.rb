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
  # ReportBuilder.build_report()
  # ReportBuilder.build_report('path/of/json/files/dir')
  # ReportBuilder.build_report('path/of/json/files/dir', 'my_test_report_name', [:json])
  # ReportBuilder.build_report('path/of/json/files/dir', 'my_test_report_name', ['json'])
  # ReportBuilder.build_report('path/of/json/files/dir', 'my_test_report_name', [:json, 'html'])
  # ReportBuilder.build_report('path/of/json/files/dir', 'my_test_report_name', [:json, :html], [:overview, :features, :scenarios, :errors])
  #
  #
  # ReportBuilder.build_report('path/of/json/cucumber.json')
  #
  #
  # ReportBuilder.build_report([
  #                                'path/of/json/cucumber1.json',
  #                                'path/of/json/cucumber2.json',
  #                                'path/of/json/files/dir/'
  #                            ])
  #
  #
  # For changing colors in report
  # ReportBuilder::COLOR[:passed] = '#ffffff'
  # ReportBuilder::COLOR[:failed] = '#000000'
  #
  # For embedding images uniquely (use when building report with scenarios tab)
  # ReportBuilder::COMPRESS = true
  #

  # colors corresponding to status
  COLOR = {
      passed: '#90ed7d',
      working: '#90ed7d',
      failed: '#f45b5b',
      broken: '#f45b5b',
      undefined: '#e4d354',
      unknown: '#e4d354',
      pending: '#f7a35c',
      skipped: '#7cb5ec',
      output: '#007fff'
  }

  COMPRESS = false

# @param [Object] file_or_dir Input json file, Default: nil (current directory), Options: array of json files/path or json files path
# @param [String] output_file_name Output file name, Default: test_report
# @param [Array] output_file_type Output file type, Default: [:html], Options: [:json] or [:json, :html] or ['html', 'json']
# @param [Array] tabs Tabs to build, Default: [:overview, :features, :errors], Options: [:overview, :features, :scenarios, :errors] or ['overview', 'features', 'scenarios', 'errors']
  def self.build_report(file_or_dir = nil, output_file_name = 'test_report', output_file_type = [:html], tabs = [:overview, :features, :errors])

    input = files file_or_dir
    all_features = features input rescue (raise 'ReportBuilderParsingError')

    output_file_type.map!(&:to_s).map!(&:upcase)

    File.open(output_file_name + '.json', 'w') do |file|
      file.write JSON.pretty_generate all_features
      puts "JSON test report generated: '#{output_file_name}.json'"
    end if output_file_type.include? 'JSON'

    all_scenarios = scenarios all_features
    all_steps = steps all_scenarios
    total_time = total_time all_features
    feature_data = data all_features
    scenario_data = data all_scenarios
    step_data = data all_steps

    File.open(output_file_name + '.html', 'w:UTF-8') do |file|
      @builder = Builder::XmlMarkup.new(:target => file, :indent => 0)
      @builder.declare!(:DOCTYPE, :html)
      @builder << '<html>'

      @builder.head do
        @builder.meta(charset: 'UTF-8')
        @builder.title 'Test Results'

        @builder.style(:type => 'text/css') do
          @builder << File.read(File.dirname(__FILE__) + '/../vendor/assets/stylesheets/jquery-ui.min.css')
          COLOR.each do |color|
            @builder << ".#{color[0].to_s}{background:#{color[1]};color:#434348;padding:2px}"
          end
          @builder << '.summary{border: 1px solid #c5c5c5;border-radius:4px;text-align:right;background:#f1f1f1;color:#434348;padding:4px}'
          @builder << '.data_table{border-collapse: collapse;} .data_table td{padding: 5px; border: 1px solid #ddd;}'
        end

        @builder.script(:type => 'text/javascript') do
          %w(jquery-min jquery-ui.min highcharts highcharts-3d).each do |js|
            @builder << File.read(File.dirname(__FILE__) + '/../vendor/assets/javascripts/' + js + '.js')
          end
          @builder << '$(function(){$("#results").tabs();});'
          @builder << "$(function(){$('#features').accordion({collapsible: true, heightStyle: 'content', active: false, icons: false});});"
          (0..all_scenarios.size).each do |n|
            @builder << "$(function(){$('#scenario#{n}').accordion({collapsible: true, heightStyle: 'content', active: false, icons: false});});"
          end
          @builder << "$(function(){$('#status').accordion({collapsible: true, heightStyle: 'content', active: false, icons: false});});"
          scenario_data.each do |data|
            @builder << "$(function(){$('##{data[:name]}').accordion({collapsible: true, heightStyle: 'content', active: false, icons: false});});"
          end
        end
      end

      @builder << '<body>'

      @builder.h4(:class => 'summary') do
        @builder << all_features.size.to_s + ' feature ('
        feature_data.each do |data|
          @builder << ' ' + data[:count].to_s + ' ' + data[:name]
        end
        @builder << ') ~ ' + all_scenarios.size.to_s + ' scenario ('
        scenario_data.each do |data|
          @builder << ' ' + data[:count].to_s + ' ' + data[:name]
        end
        @builder << ') ~ ' + all_steps.size.to_s + ' step ('
        step_data.each do |data|
          @builder << ' ' + data[:count].to_s + ' ' + data[:name]
        end
        @builder << ') ~ ' + duration(total_time).to_s
      end

      @builder.div(:id => 'results') do
        tabs.map!(&:to_s).map!(&:downcase)
        build_menu tabs

        @builder.div(:id => 'overviewTab') do
          @builder << "<div id='featurePieChart'></div>"
          @builder << "<div id='scenarioPieChart'></div>"
          @builder << "<div id='stepPieChart'></div>"
        end if tabs.include? 'overview'

        @builder.div(:id => 'featuresTab') do
          @builder.div(:id => 'features') do
            all_features.each_with_index do |feature, n|
              @builder.h3 do
                @builder.span(:class => feature['status']) do
                  @builder << "<strong>#{feature['keyword']}</strong> #{feature['name']} (#{duration(feature['duration'])})"
                end
              end
              @builder.div do
                @builder.div(:id => "scenario#{n}") do
                  feature['elements'].each{|scenario| build_scenario scenario}
                end
              end
            end
          end
          @builder << "<div id='featureTabPieChart'></div>"
        end if tabs.include? 'features'

        @builder.div(:id => 'scenariosTab') do
          @builder.div(:id => 'status') do
            all_scenarios.group_by{|scenario| scenario['status']}.each do |data|
              @builder.h3 do
                @builder.span(:class => data[0]) do
                  @builder << "<strong>#{data[0].capitalize} scenarios (Count: #{data[1].size})</strong>"
                end
              end
              @builder.div do
                @builder.div(:id => data[0]) do
                  data[1].each{|scenario| build_scenario scenario}
                end
              end
            end
          end
          @builder << "<div id='scenarioTabPieChart'></div>"
        end if tabs.include? 'scenarios'

        @builder.div(:id => 'errorsTab') do
          @builder.ol do
            all_scenarios.each{|scenario| build_error_list scenario}
          end
        end if tabs.include? 'errors'
      end

      @builder.script(:type => 'text/javascript') do
        @builder << pie_chart_js('featurePieChart', 'Features', feature_data) if tabs.include? 'overview'
        @builder << donut_js('featureTabPieChart', 'Features', feature_data) if tabs.include? 'features'
        @builder << pie_chart_js('scenarioPieChart', 'Scenarios', scenario_data) if tabs.include? 'overview'
        @builder << donut_js('scenarioTabPieChart', 'Scenarios', scenario_data) if tabs.include? 'scenarios'
        @builder << pie_chart_js('stepPieChart', 'Steps', step_data) if tabs.include? 'overview'
      end

      @builder << '</body>'
      @builder << '</html>'

      puts "HTML test report generated: '#{output_file_name}.html'"
    end if output_file_type.include? 'HTML'

    [total_time, feature_data, scenario_data, step_data]
  end

  def self.build_menu(tabs)
    @builder.ul do
      tabs.each do |tab|
        @builder.li do
          @builder.a(:href => "##{tab}Tab") do
            @builder << tab.capitalize
          end
        end
      end
    end
  end

  def self.build_scenario(scenario)
    @builder.h3 do
      @builder.span(:class => scenario['status']) do
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
    @builder.span(:class => step['status']) do
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
    @builder << '<br/>'
  end

  def self.build_data_table(rows)
    @builder.table(:class => 'data_table') do
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
      @builder << "<br/><span style='color:#{COLOR[:output]}'>#{output.gsub("\n",'</br>').gsub("\t",'&nbsp;&nbsp;').gsub(' ','&nbsp;')}</span>"
    end if outputs.is_a?(Array)
  end

  def self.build_step_error(step)
    if step['status'] == 'failed' && step['result']['error_message']
      @builder << "<br/><strong style=color:#{COLOR[:failed]}>Error: </strong>"
      error = step['result']['error_message'].split("\n")
      @builder.span(:style => "color:#{COLOR[:failed]}") do
        error[0..-3].each do |line|
          @builder << line + '<br/>'
        end
      end
      @builder << "<strong>SD: </strong>#{error[-2]} <br/>"
      @builder << "<strong>FF: </strong>#{error[-1]}"
    end
  end

  def self.build_hook_error(hook)
    if hook['status'] == 'failed'
      @builder << "<br/><strong style=color:#{COLOR[:failed]}>Error: </strong>"
      error = hook['result']['error_message'].split("\n")
      @builder.span(:style => "color:#{COLOR[:failed]}") do
        error[0..-2].each do |line|
          @builder << line + '<br/>'
        end
      end
      @builder << "<strong>Hook: </strong>#{error[-1]}<br/>"
    end
  end

  def self.build_step_hook_error(hook, scenario_keyword)
    if hook['result']['error_message']
      @builder << "<br/><strong style=color:#{COLOR[:failed]}>Error: </strong>"
      error = hook['result']['error_message'].split("\n")
      @builder.span(:style => "color:#{COLOR[:failed]}") do
        (scenario_keyword == 'Scenario Outline' ? error[0..-6] : error[0..-4]).each do |line|
          @builder << line + '<br/>'
        end
      end
      @builder << "<strong>Hook: </strong>#{scenario_keyword == 'Scenario Outline' ? error[-5] : error[-3]} <br/>"
      @builder << "<strong>FF: </strong>#{error[-2]}"
    end
  end

  def self.build_embedding(embeddings)
    @embedding_count ||= 0
    embeddings.each do |embedding|
      id = "embedding_#{@embedding_count}"
      if embedding['mime_type'] =~ /^image\/(png|gif|jpg|jpeg)/
        @builder.span(:class => 'image') do
          @builder << '<br/>'
          @builder.a(:href => '', :style => 'text-decoration: none;', :onclick => "img=document.getElementById('#{id}');img.style.display = (img.style.display == 'none' ? 'block' : 'none');return false") do
            @builder.span(:style => "color: #{COLOR[:output]}; font-weight: bold; border-bottom: 1px solid #{COLOR[:output]};") do
              @builder << 'Screenshot'
            end
          end
          @builder << '<br/>'
          COMPRESS ? build_unique_image(embedding, id) : build_image(embedding,id) rescue puts 'Image embedding failed!'
        end
      elsif embedding['mime_type'] =~ /^text\/plain/
        @builder.span(:class => 'link') do
          @builder << '<br/>'
          src = Base64.decode64(embedding['data'])
          @builder.a(:id => id, :style => 'text-decoration: none;', :href => src, :title => 'Link') do
            @builder.span(:style => "color: #{COLOR[:output]}; font-weight: bold; border-bottom: 1px solid #{COLOR[:output]};") do
              @builder << src
            end
          end
          @builder << '<br/>'
        end rescue puts('Link embedding skipped!')
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
      @builder.style(:type => 'text/css') do
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
        @builder.span(:style => "color:#{COLOR[:failed]}") do
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
          @builder.span(:style => "color:#{COLOR[:failed]}") do
            (scenario['keyword'] == 'Scenario Outline' ? error[0..-6] : error[0..-4]).each do |line|
              @builder << line + '<br/>'
            end
          end
          @builder << "<strong>Hook: </strong>#{scenario['keyword'] == 'Scenario Outline' ? error[-5] : error[-3]} <br/>"
          @builder << "<strong>FF: </strong>#{error[-2]} <br/><hr/>"
        end
      end if step['after']
      next unless step['status'] == 'failed' && step['result']['error_message']
      @builder.li do
        error = step['result']['error_message'].split("\n")
        @builder.span(:style => "color:#{COLOR[:failed]}") do
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
        @builder.span(:style => "color:#{COLOR[:failed]}") do
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
    }.each{|feature|
      feature['elements'].each { |scenario|
        scenario['before'] ||= []
        scenario['before'].each { |before|
          before['result']['duration'] ||= 0
          before.merge! 'status' => before['result']['status'], 'duration' => before['result']['duration']
        }
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
      feature_status = 'unknown' if %w(undefined pending).include?(status)
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
                       :build_unique_image, :build_image
end