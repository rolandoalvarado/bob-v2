module Cucumber
module Formatter
module Bob
module TemplateHelpers

  #==================================================
  # Template helper methods
  #==================================================

  def all_tags(feature_or_element)
    feature_or_element[:tags] || []
  end

  def asset_tags(prefix = '')
    tags = ""
    ['javascripts', 'stylesheets'].each do |asset_type|
      Dir.open(File.join(@report_dir, asset_type)).entries.sort{|a, b| a <=> b }.each do |asset_file_name|
        next if /^\..*$/ =~ asset_file_name
        case asset_type
        when 'img'
          tags << "\n<img src='#{ prefix }img/#{ asset_file_name }'/>"
        when 'javascripts'
          tags << "\n<script type='text/javascript' src='#{ prefix }javascripts/#{ asset_file_name }'></script>"
        when 'stylesheets'
          tags << "\n<link rel='stylesheet' type='text/css' href='#{ prefix }stylesheets/#{ asset_file_name }'/>"
        end
      end
    end
    tags
  end

  def build_bookmark(category, feature)
    "#{category}-#{feature[:name].parameterize}"
  end

  def build_id(feature, element, step, index)
    "#{ feature }#{ element }#{ step }#{ index }".parameterize
  end

  def compute_statistics
    return if @stats

    @stats = {}
    @stats[:total_completed_features] = 0
    @stats[:total_features] = 0
    @stats[:total_undefined_features] = 0

    @results.each do |category_name, features|
      features.each do |feature|

        case get_feature_status(feature)
        when :passed
          @stats[:total_completed_features] += 1
        when :undefined
          @stats[:total_undefined_features] += 1
        end

        @stats[:total_features] += 1
      end
    end
  end

  def feature_status_text(feature)
    status_text( get_status(feature) )
  end

  def get_feature_status(feature)
    @statuses ||= {}
    return @statuses[feature[:name]] unless @statuses[feature[:name]].nil?
    return :undefined if feature[:elements].nil?

    status = nil

    feature[:elements].each do |element|
      if is_scenario_outline?(element)
        # Go through the examples instead of the steps
        element[:examples].each do |examples|
          (1...examples[:rows].length).each do |index|
            examples[:rows][index].each do |cell|
              status = cell[:status] unless cell[:status] == :passed
              break if status
            end
            break if status
          end
        end
      else
        # Go through the steps
        element[:steps].each do |step|
          status = step[:status] unless step[:status] == :passed
          break if status
        end
      end

      break if status
    end

    status ||= :passed

    @statuses[feature[:name]] = status
    status
  end

  def has_jira_tags?(feature_or_element)
    return !jira_tags(feature_or_element).nil? &&
           !jira_tags(feature_or_element).empty?
  end

  def is_scenario_outline?(element)
    !element[:examples].nil?
  end

  def jira_issue_link_or_text(tag)
    tag.gsub! /^@jira-/, ''
    if tag =~ /^\S-\d+/
      "<a href='https://issues.morphlabs.com/browse/#{tag}' target='__jira__'>#{tag}</a>"
    else
      tag
    end
  end

  def jira_tags(feature_or_element)
    return [] unless feature_or_element[:tags]

    feature_or_element[:tags].select { |tag| tag =~ /^@jira-/ }
  end

  def label_type(status)
    "label-#{ status_class_name(status) }"
  end

  def link_to_feature_file(feature_file)
    underscored_name = feature_file[:name].split.join('_').downcase.gsub(/[^A-Za-z]/, '_')
    "<a href='feature_files/#{ underscored_name }.html' target='main' class='#{ status_class_name(get_feature_status(feature_file)) }'>#{ feature_file[:name] }</a>"
  end

  def non_jira_tags(feature_or_element)
    tags = feature_or_element[:tags] || []
    tags.select { |tag| tag.match(/^@jira-/).nil? }
  end

  def status_class_name(status)
    case status
    when :undefined
      'undefined'
    when :passed
      'passed'
    when :failed
      'failed'
    when :pending
      'pending'
    else
      'skipped'
    end
  end

  def status_text(status)
    case status
    when :undefined
      'U'
    when :passed
      'OK'
    when :failed
      'F'
    when :skipped
      'S'
    when :pending
      'P'
    else
      ''
    end
  end

  def total_completed_features
    compute_statistics
    @stats[:total_completed_features]
  end

  def total_features
    compute_statistics
    @stats[:total_features]
  end

  def total_undefined_features
    compute_statistics
    @stats[:total_undefined_features]
  end

  def web_client_url
    CloudConfiguration::ConfigFile::web_client_url
  end

end # module TemplateHelpers
end # module Bob
end # module Formatter
end # module Cucumber