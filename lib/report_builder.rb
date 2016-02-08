require 'json'
require 'builder'

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
  #    ReportBuilder.build_report('path/of/json/files/dir')
  #
  #    ReportBuilder.build_report('path/of/json/file.json')
  #
  #    ReportBuilder.build_report(['path/of/json/file1.json','path/of/json/file2.json','path/of/json/files/dir/'])
  #
  #    ReportBuilder.build_report()
  #
  #    ReportBuilder::COLOR[:passed] = '#ffffff'
  #    ReportBuilder.build_report()


  # colors corresponding to status
  COLOR = {
      passed: '#90ed7d',
      working: '#90ed7d',
      failed: '#f45b5b',
      broken: '#f45b5b',
      undefined: '#e4d354',
      unknown: '#e4d354',
      pending: '#f7a35c',
      skipped: '#7cb5ec'
  }

# @param [Object] file_or_dir  json file, array of json files or path, json files path
# @param [String] output_file_name Output file name, by default test_report
  def self.build_report(file_or_dir = nil, output_file_name = 'test_report')

    input = files file_or_dir
    all_features = features input rescue (raise 'ReportBuilderParsingError')
    all_scenarios = scenarios all_features
    all_steps = steps all_scenarios
    total_time = total_time all_features
    feature_data = data all_features
    scenario_data = data all_scenarios
    step_data = data all_steps

    file = File.open(output_file_name + '.html', 'w:UTF-8')

    builder = Builder::XmlMarkup.new(:target => file, :indent => 0)
    builder.declare!(:DOCTYPE, :html)
    builder << '<html>'

    builder.head do
      builder.meta(charset: 'UTF-8')
      builder.title 'Test Results'

      builder.style(:type => 'text/css') do
        builder << File.read(File.dirname(__FILE__) + '/../vendor/assets/stylesheets/jquery-ui.min.css')
        COLOR.each do |color|
          builder << ".#{color[0].to_s}{background:#{color[1]};color:#434348;padding:2px}"
        end
        builder << '.summary{border: 1px solid #c5c5c5;border-radius:4px;text-align:right;background:#f1f1f1;color:#434348;padding:4px}'
      end

      builder.script(:type => 'text/javascript') do
        %w(jquery-min jquery-ui.min highcharts highcharts-3d).each do |file|
          builder << File.read(File.dirname(__FILE__) + '/../vendor/assets/javascripts/' + file + '.js')
        end
        builder << '$(function(){$("#results").tabs();});'
        builder << "$(function(){$('#features').accordion({collapsible: true, heightStyle: 'content', active: false, icons: false});});"
        (0..all_scenarios.size).each do |n|
          builder << "$(function(){$('#scenario#{n}').accordion({collapsible: true, heightStyle: 'content', active: false, icons: false});});"
        end
        builder << "$(function(){$('#status').accordion({collapsible: true, heightStyle: 'content', active: false, icons: false});});"
        scenario_data.each do |data|
          builder << "$(function(){$('##{data[:name]}').accordion({collapsible: true, heightStyle: 'content', active: false, icons: false});});"
        end
      end
    end

    builder << '<body>'

    builder.h4(:class => 'summary') do
      builder << all_features.size.to_s + ' feature ('
      feature_data.each do |data|
        builder << ' ' + data[:count].to_s + ' ' + data[:name]
      end
      builder << ') ~ ' + all_scenarios.size.to_s + ' scenario ('
      scenario_data.each do |data|
        builder << ' ' + data[:count].to_s + ' ' + data[:name]
      end
      builder << ') ~ ' + all_steps.size.to_s + ' step ('
      step_data.each do |data|
        builder << ' ' + data[:count].to_s + ' ' + data[:name]
      end
      builder << ') ~ ' + duration(total_time).to_s
    end

    builder.div(:id => 'results') do

      builder.ul do
        %w(overview features scenarios errors).each do |tab|
          builder.li do
            builder.a(:href => "##{tab}Tab") do
              builder << tab.capitalize
            end
          end
        end
      end

      builder.div(:id => 'overviewTab') do
        builder << "<div id='featurePieChart'></div>"
        builder << "<div id='scenarioPieChart'></div>"
        builder << "<div id='stepPieChart'></div>"
      end

      builder.div(:id => 'featuresTab') do
        builder.div(:id => 'features') do
          all_features.each_with_index do |feature, n|
            builder.h3 do
              builder.span(:class => feature['status']) do
                builder << "<strong>#{feature['keyword']}</strong> #{feature['name']} (#{feature['status']}) #{duration(feature['duration'])}"
              end
            end
            builder.div do
              builder.div(:id => "scenario#{n}") do
                feature['elements'].each do |scenario|
                  builder.h3 do
                    builder.span(:class => scenario['status']) do
                      builder << "<strong>#{scenario['keyword']}</strong> #{scenario['name']} (#{scenario['status']})  #{duration(scenario['duration'])}"
                    end
                  end
                  builder.div do
                    scenario['steps'].each do |step|
                      builder.span(:class => step['status']) do
                        builder << "<strong>#{step['keyword']}</strong> #{step['name']} (#{step['status']})  #{duration(step['duration'])}"
                      end
                      if step['status'] == 'failed'
                        builder << "<br><strong style=color:#{COLOR[:failed]}>Error: </strong>"
                        error = step['result']['error_message'].split("\n")
                        builder.span(:style => "color:#{COLOR[:failed]}") do
                          error[0..-3].each do |line|
                            builder << line + '<br/>'
                          end
                        end
                        builder << "<strong>SD: </strong>#{error[-2]} <br/>"
                        builder << "<strong>FF: </strong>#{error[-1]}"
                      end
                      builder << '<br/>'
                    end
                  end
                end
              end
            end
          end
        end
        builder << "<div id='featureTabPieChart'></div>"
      end

      builder.div(:id => 'scenariosTab') do
        builder.div(:id => 'status') do
          all_scenarios.group_by{|scenario| scenario['status']}.each do |data|
            builder.h3 do
              builder.sapn(:class => data[0]) do
                builder << "<strong>#{data[0].capitalize} scenarios (Count: #{data[1].size})</strong>"
              end
            end
            builder.div do
              builder.div(:id => data[0]) do
                data[1].each do |scenario|
                  builder.h3 do
                    builder.span(:class => data[0]) do
                      builder << "<strong>#{scenario['keyword']}</strong> #{scenario['name']} (#{data[0]}) #{duration(scenario['duration'])}"
                    end
                  end
                  builder.div do
                    scenario['steps'].each do |step|
                      builder.span(:class => step['status']) do
                        builder << "<strong>#{step['keyword']}</strong> #{step['name']} (#{step['status']}) #{duration(step['duration'])}"
                      end
                      if step['status'] == 'failed'
                        builder << "<br><strong style=color:#{COLOR[:failed]}>Error: </strong>"
                        error = step['result']['error_message'].split("\n")
                        builder.span(:style => "color:#{COLOR[:failed]}") do
                          error[0..-3].each do |line|
                            builder << line + '<br/>'
                          end
                        end
                        builder << "<strong>SD: </strong>#{error[-2]} <br/>"
                        builder << "<strong>FF: </strong>#{error[-1]}"
                      end
                      builder << '<br>'
                    end
                  end
                end
              end
            end
          end
        end
        builder << "<div id='scenarioTabPieChart'></div>"
      end

      builder.div(:id => 'errorsTab') do
        builder.ol do
          all_steps.each do |step|
            next unless step['status'] == 'failed'
            builder.li do
              error = step['result']['error_message'].split("\n")
              builder.span(:style => "color:#{COLOR[:failed]}") do
                error[0..-3].each do |line|
                  builder << line + '<br/>'
                end
              end
              builder << "<strong>SD: </strong>#{error[-2]} <br/>"
              builder << "<strong>FF: </strong>#{error[-1]}"
            end
          end
        end
      end
    end

    builder.script(:type => 'text/javascript') do
      builder << pie_chart_js('featurePieChart', 'Features', feature_data)
      builder << donut_js('featureTabPieChart', 'Features', feature_data)
      builder << pie_chart_js('scenarioPieChart', 'Scenarios', scenario_data)
      builder << donut_js('scenarioTabPieChart', 'Scenarios', scenario_data)
      builder << pie_chart_js('stepPieChart', 'Steps', step_data)
    end

    builder << '</body>'
    builder << '</html>'

    file.close

    puts "Test report generated: '#{output_file_name}.html'"
    [total_time, feature_data, scenario_data, step_data]
  end

  def self.features(files)
    files.each_with_object([]) { |file, features|
      features << JSON.parse(File.read(file))
    }.flatten.group_by { |feature|
      feature['uri']+feature['id']+feature['line'].to_s
    }.values.each_with_object([]) { |group, features|
      features << group.first.except('elements').merge('elements' => group.map{|feature| feature['elements']}.flatten)
    }.each{|feature|
      feature['elements'].each { |scenario|
        scenario['steps'].each { |step|
          step['result']['duration'] ||= 0
          step.merge! 'status' => step['result']['status'], 'duration' => step['result']['duration']
        }
        scenario.merge! 'status' => scenario_status(scenario), 'duration' => total_time(scenario['steps'])
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
    scenario['steps'].each do |step|
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
              Dir.glob("*.json")
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
                       :data, :duration, :total_time
end