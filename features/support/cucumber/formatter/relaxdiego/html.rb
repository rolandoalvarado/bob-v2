require 'rubygems'
require 'erb'
require 'cucumber/formatter/ordered_xml_markup'
require 'cucumber/formatter/duration'
require 'cucumber/formatter/io'
require 'cucumber/formatter/summary'
require 'active_support/all'

module Cucumber
  module Formatter
    module Relaxdiego
      class Html

        include ERB::Util # for the #h method
        include Duration
        include Io
        include Summary
        include ActiveSupport::Inflector

        def initialize(step_mother, path_or_io, options)
          @io = ensure_io(path_or_io, "html")
          @total_features = 0
          @processed_features = 0
          @results = {}
          @current_category
          @current_feature
        end

        def before_features(features)
          features.each { |f| @total_features += 1 }
        end

        # Assumes that the .feature file is at least two levels down from
        # the feature directory. e.g. features/somedir/category1/feature_name.feature
        # In the above example, "features" and "somedir" are ignored
        def before_feature(feature)
          @current_category = get_current_category(:path => feature.file, :root_category => @results)
        end

        def feature_name(keyword, name_and_desc)
          name, desc = split_name_and_desc(name_and_desc)
          @current_feature = {:name => name, :description => desc}
          @current_category << @current_feature
        end

        def before_background(background)
          @current_feature[:elements] = [] if @current_feature[:elements].nil?
          @current_feature_element = {}
          @current_feature[:elements] << @current_feature_element
        end

        def background_name(keyword, name_and_desc, file_colon_line, source_indent)
          name, desc = split_name_and_desc(name_and_desc)
          @current_feature_element[:type] = "Background"
          @current_feature_element[:name] = name
          @current_feature_element[:description] = desc
        end

        def after_background(background)
          # Do nothing
        end

        # Called for Scenario and Scenario Outline.
        # May be called for other elements should
        # Cucumber add a new type in future versions.
        def before_feature_element(feature_element)
          @current_feature[:elements] = [] if @current_feature[:elements].nil?
          @current_feature_element = {}
          @current_feature[:elements] << @current_feature_element
        end

        def scenario_name(keyword, name_and_desc, file_colon_line, source_indent)
          name, desc = split_name_and_desc(name_and_desc)
          @current_feature_element[:type] = keyword
          @current_feature_element[:name] = name
          @current_feature_element[:description] = desc
        end

        # Can be called for a Scenario, Scenario Outline, or Background
        def before_steps(steps)
          @current_feature_element[:steps] = []
        end

        # Can be a Scenario, Scenario Outline, or Background step
        def before_step(step)
          # Do nothing
        end

        # Can be a Scenario, Scenario Outline, or Background step
        def before_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
          # Do nothing
        end

        # Can be a Scenario, Scenario Outline, or Background step
        def step_name(keyword, step_match, status, source_indent, is_background)
          @current_step_is_background = is_background
          step_name = step_match.format_args(lambda{|param| %{#{param}}})
          step = { :keyword => keyword.gsub('*','').strip,
                   :status  => status,
                   :name    => h(step_name).gsub(/&lt;(\w+)&gt;/, '<code>\1</code>') }
          @current_step = step
          return if skip_current_step?

          @current_feature_element[:steps] << step
        end

        def after_step(step)
          # Do nothing
        end

        def after_steps(steps)
          # Do nothing
        end

        def after_feature_element(feature_element)
          # Do nothing
        end

        def after_feature(feature)
          @processed_features += 1
          show_progress(@processed_features, @total_features, "features")
        end

        def after_features(features)
          build_html
        end

        #=================================================
        # Other methods called within a feature element
        # These tend to be shared between the three types
        # (Background, Scenario, and Scenario Outline)
        #=================================================

        # Denotes the beginning of a Scenario or Background table
        # Does NOT denote a Scenario Outline table
        # See before_outline_table instead.
        def before_multiline_arg(multiline_arg)
          return if skip_current_step?
          @current_table = []
          @current_step[:table] = @current_table
        end

        def after_multiline_arg(multiline_arg)
          # Do nothing
        end

        def before_examples(examples)
          # Do nothing
        end

        def examples_name(keyword, name_and_desc)
          name, desc = split_name_and_desc(name_and_desc)
          examples = {
            :type => keyword,
            :name => name,
            :description => desc,
            :rows => []
          }
          @current_feature_element[:examples] = examples
        end

        def after_examples(examples)
        end

        # Denotes the beginning of a Scenario Outline table
        # Does NOT denote a Scenario or Background table
        # See before_multiline_arg instead
        def before_outline_table(outline_table)
          @current_table = @current_feature_element[:examples][:rows]
        end

        def after_outline_table(outline_table)
          # Do nothing
        end

        #==================================================
        # Methods involving tables (Examples or Multi-line
        # arguments). May also be called within a step that
        # is part of a background (which gets called for
        # every scenario and scenario outline in a feature)
        # In that case, we want to skip it.
        #==================================================

        def before_table_row(table_row)
          return if skip_current_step?
          @current_row = []
          @current_table << @current_row
        end

        def table_cell_value(value, status)
          return if skip_current_step?
          @current_row << { :value => value, :status => status }
        end

        def after_table_row(table_row)
          # Do nothing
        end

        def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
          # Do nothing
        end

        #==================================================
        # Unused methods
        #==================================================

        def before_comment(comment)
        end

        def comment_line(comment_line)
        end

        def after_comment(comment)
        end

        def before_tags(tags)
        end

        def tag_name(tag_name)
        end

        def after_tags(tags)
        end

        protected

        def build_html
          template = File.open(File.expand_path('../html.erb', __FILE__), 'r')
          erb = ERB.new(template.read)
          @io.write erb.result(binding)
          puts "HTML report saved as #{@io.path}"
        end

        def embed_assets
          inline_assets = ""

          dir = Dir.open(File.dirname(__FILE__))

          dir.entries.select { |e| e.match /.+\.(css|js)/ }.each do |f|
            file = File.read(File.dirname(__FILE__) + "/#{f}")
            type = f.split('.')[f.split('.').length-1]

            inline_assets << (type == 'css' ? "<style type='text/css'>" : "<script>")
            inline_assets << "\n#{file}\n"
            inline_assets << (type == 'css' ? "</style>" : "</script>")
          end

          inline_assets
        end

        def get_current_category(args)
          path = args[:path].split('/')

          # Remove first two directories and the feature filename
          2.times { path.delete_at(0) }
          path.delete_at(path.length - 1)

          current_category = args[:root_category]
          path.each_with_index do |sub_cat, index|
            # If we've reached the end of the path, make the sub-category an array (of features)
            current_category[sub_cat] = (index < path.length-1 ? {} : []) if current_category[sub_cat].nil?
            current_category = current_category[sub_cat]
          end

          current_category
        end

        def show_progress(current, total, what)
          # print "\rProcessed #{current} of #{total} #{what}"
        end

        def skip_current_step?
          @current_step_is_background && @current_feature_element[:type].downcase != "background"
        end

        def split_name_and_desc(name_and_desc)
          lines = name_and_desc.split("\n")
          name = lines.delete_at(0) || ""
          description = ""
          lines.each do |line|
            description << (line.strip == '' ? "<br><br>" : line)
          end
          return name.strip, description.strip
        end

        #==================================================
        # Template helper methods
        #==================================================

        def build_bookmark(category, feature)
          "#{category}-#{feature[:name].parameterize}"
        end

        def feature_label_type(feature)
          label_type( get_status(feature) )
        end

        def feature_status_text(feature)
          status_text( get_status(feature) )
        end

        def get_status(feature)
          @statuses ||= {}
          return @statuses[feature[:name]] unless @statuses[feature[:name]].nil?
          status = nil

          feature[:elements].each do |element|
            element[:steps].each do |step|
              status = step[:status] unless step[:status] == :passed
              break if status
            end
            break if status
          end

          status ||= :passed

          @statuses[feature[:name]] = status
          status
        end

        def is_scenario_outline?(element)
          element[:examples]
        end

        def label_type(status)
          css = "label-"

          case status
          when :undefined
            css << 'warning'
          when :passed
            css << 'success'
          when :failed
            css << 'important'
          when :pending
            css << 'warning'
          else
            css << ''
          end

          css
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

        def compute_statistics
          return if @stats

          @stats = {}
          @stats[:total_completed_features] = 0
          @stats[:total_features] = 0
          @stats[:total_undefined_features] = 0

          @results.each do |category_name, features|
            features.each do |feature|
              @stats[:total_completed_features] += 1 if get_status(feature) == :passed
              @stats[:total_features] += 1
              @stats[:total_undefined_features] += 1 if get_status(feature) == :undefined
            end
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

      end #class Html
    end # module Relaxdiego
  end # module Formatter
end # module Cucumber
