require 'rubygems'
require 'erb'
require 'cucumber/formatter/ordered_xml_markup'
require 'cucumber/formatter/duration'
require 'cucumber/formatter/io'
require 'cucumber/formatter/summary'

module Cucumber
  module Formatter
    class Morph
  		include ERB::Util # for the #h method
  		include Duration
  		include Io
  		include Summary

      def initialize(step_mother, path_or_io, options)
        @io = ensure_io(path_or_io, "html")
        @step_mother = step_mother
        @options = options
        @buffer = {}
        @builder = create_builder(@io)
        @feature_number = 0
        @scenario_number = 0
        @step_number = 0
        @header_red = nil
      end

      def embed(file, mime_type)
        case(mime_type)
        when /^image\/(png|gif|jpg|jpeg)/
          embed_image(file)
        end
      end

      def embed_image(file)
        id = file.hash
        @builder.span(:class => 'embed') do |pre|
          pre << %{<a href="" onclick="img=document.getElementById('#{id}'); img.style.display = (img.style.display == 'none' ? 'block' : 'none');return false">Screenshot</a><br>&nbsp;
          <img id="#{id}" style="display: none" src="#{file}"/>}
        end
      end


      def before_features(features)
        @step_count = get_step_count(features)

        @builder.declare!(
          :DOCTYPE,
          :html
        )

        @builder << '<html lang="en">'
          @builder.head do
            @builder.meta(:content => 'text/html;charset=utf-8')
            @builder.title 'mCloud Features Progress Report'
            inline_css
      		  google_js
            inline_js
          end
        @builder << '<body>'
        @builder.div :id => 'status-labels' do |div|
          [:failed, :passed, :undefined, :pending, :skipped].each do |status|
            div.span(:class => "#{status_css_class(status)} #{status}") do |span|
              span.text! status_text(status)
            end
          end
        end

        @builder.script do |script|
          script << %s{
            $(document).ready(function(){
              MM.labelFeatures();
              MM.showStats('#{summary}');
              MM.showTOC();
            });
          }
        end
        @builder << "<!-- Step count #{@step_count}-->"
        @builder << '<div class="container">'
        @builder.div(:id => 'cucumber-header') do |header|
          header.div(:id => 'label') do
            header.h1('mCloud Features')
          end
          header.p "Last updated: #{Time.now.utc}"

          header.div do |legend|
            legend.h2 "Legend"
            legend.table :id => 'legend', :class => 'table-condensed' do |table|
              [:passed, :failed, :undefined, :pending, :skipped].each do |status|
                table.tr do |tr|
                  tr.td do |td|
                    td.span(:class => "#{status_css_class(status)} #{status}") do |span|
                      span.text! status_text(status)
                    end
                  end
                  tr.td do |td|
                    td << case status
                          when :passed
                            "The feature is fully implemented and validated."
                          when :failed
                            "The feature has one or more steps that failed."
                          when :undefined
                            "Undefined. The feature has one or more steps that don't have an underlying validator."
                          when :pending
                            "Pending. The feature's underlying validator is still being built."
                          when :skipped
                            "Skipped. One or more steps of the feature was skipped."
                          end
                  end
                end
              end
            end
          end

          header.div  do |row|
            row.h2 "Table of Contents"
            row.div :id => "toc"
          end
        end

        @builder << "<div id='features'>"
      end

      def after_features(features)
        summary = scenario_summary(@step_mother) {|status_count, status| status_count }
        @builder << '</div>'
        @builder << '</div>'
        @builder << '</body>'
        @builder << '</html>'
      end

      def before_feature(feature)
        @exceptions = []
        @builder << '<div class="feature">'
      end

      def after_feature(feature)
        @feature_number += 1
        @builder << '</div>'
      end

      def before_comment(comment)
        @builder << '<pre class="comment">'
      end

      def after_comment(comment)
        @builder << '</pre>'
      end

      def comment_line(comment_line)
        @builder.text!(comment_line)
        @builder.br
      end

      def after_tags(tags)
        @tag_spacer = nil
      end

      def tag_name(tag_name)
				@current_tag = tag_name
      end

      def feature_name(keyword, name)
        lines = name.split(/\r?\n/)
        return if lines.empty?
        @builder.a :class => 'bookmark', :name => "feature_#{@feature_number}" do |a|
          a.h2 do |h2|
            h2.text!('Feature: ')
            h2.span(lines[0], :class => 'feature-name')
          end
        end
        @builder.p(:class => 'narrative') do
          lines[1..-1].each do |line|
            if line.strip == ''
              @builder.br
              @builder.br
            else
              @builder.text!(line)
            end
          end
        end
      end

      def before_background(background)
        @in_background = true
        @builder << '<div class="background">'
      end

      def after_background(background)
        @in_background = nil
        @builder << '</div>'
      end

      def background_name(keyword, name, file_colon_line, source_indent)
        @listing_background = true
        lines = name.split(/\r?\n/)
        @builder.h3 do |h3|
          @builder.span('Background: ', :class => 'keyword')
          @builder.span(lines[0], :class => 'feature-name')
        end

        return unless lines[1]

        @builder.p(:class => 'narrative') do
          lines[1..-1].each do |line|
            if line.strip == ''
              @builder.br
              @builder.br
            else
              @builder.text!(line)
            end
          end
        end
      end

      def before_feature_element(feature_element)
        @scenario_number+=1
        @scenario_red = false
        @scenario_outline = (feature_element.class == Ast::ScenarioOutline)
        css_class = {
          Ast::Scenario        => 'scenario',
          Ast::ScenarioOutline => 'scenario outline'
        }[feature_element.class]
        @builder << "<div class='#{css_class}' id='scenario_#{@scenario_number}'>"
      end

      def after_feature_element(feature_element)
        @builder << '</div>'
        @open_step_list = true
        @scenario_outline = nil
      end

      def scenario_name(keyword, name, file_colon_line, source_indent)
        @listing_background = false

        lines = name.split(/\r?\n/)
        @builder.h3 do |h3|
          @builder.span("#{keyword}: ", :class => 'keyword')
          @builder.span(lines[0], :class => 'feature-name')
        end

        return unless lines[1]

        @builder.p(:class => 'narrative') do
          lines[1..-1].each do |line|
            if line.strip == ''
              @builder.br
              @builder.br
            else
              @builder.text!(line)
            end
          end
        end
      end

      def before_outline_table(outline_table)
        @outline_row = 0
        @scenario_outline = nil
        @builder << '<table class="table table-bordered">'
      end

      def after_outline_table(outline_table)
        @builder << '</table>'
        @outline_row = nil
      end

      def before_examples(examples)
        @is_example = true
        @builder << '<div class="examples">'
      end

      def after_examples(examples)
        @is_example = nil
        @builder << '</div>'
      end

      def examples_name(keyword, name)
        # @builder.h4 do
        #   @builder.span(keyword, :class => 'keyword')
        #   @builder.text!(' ')
        #   @builder.span(name, :class => 'val')
        # end
        lines = name.split(/\r?\n/)
        @builder.h3 do |h3|
          @builder.span("#{keyword}: ", :class => 'keyword')
          @builder.span(lines[0], :class => 'feature-name')
        end

        return unless lines[1]

        @builder.p(:class => 'narrative') do
          lines[1..-1].each do |line|
            if line.strip == ''
              @builder.br
              @builder.br
            else
              @builder.text!(line)
            end
          end
        end
      end

      def before_steps(steps)
        @builder << '<ol>'
      end

      def after_steps(steps)
        @builder << '</ol>'
      end

      def before_step(step)
        @step_id = step.dom_id
        @step_number += 1
        @step = step
      end

      def after_step(step)
        move_progress
      end

      def before_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        @step_match = step_match
        @hide_this_step = false
        if exception
          if @exceptions.include?(exception)
            @hide_this_step = true
            return
          end
          @exceptions << exception
        end
        if status != :failed && @in_background ^ background
          @hide_this_step = true
          return
        end
        @status = status
        return if @hide_this_step
        @builder << "<li id='#{@step_id}' class='step #{status}'>"
      end

      def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        return if @hide_this_step
        @builder << '</li>'
      end

      def step_name(keyword, step_match, status, source_indent, background)
        @step_matches ||= []
        background_in_scenario = background && !@listing_background
        @skip_step = @step_matches.index(step_match) || background_in_scenario
        @step_matches << step_match

        unless @skip_step
          build_step(keyword, step_match, status)
        end
      end

      def exception(exception, status)
        # build_exception_detail(exception)
      end

      def extra_failure_content(file_colon_line)
        @snippet_extractor ||= SnippetExtractor.new
        "<pre class=\"ruby\"><code>#{@snippet_extractor.snippet(file_colon_line)}</code></pre>"
      end

      def before_multiline_arg(multiline_arg)
        return if @hide_this_step || @skip_step
        if Ast::Table === multiline_arg
          @builder << '<table class="table table-bordered">'
        end
      end

      def after_multiline_arg(multiline_arg)
        return if @hide_this_step || @skip_step
        if Ast::Table === multiline_arg
          @builder << '</table>'
        end
      end

      def py_string(string)
        return if @hide_this_step
        @builder.pre(:class => 'val') do |pre|
          @builder << string.gsub("\n", '&#x000A;')
        end
      end


      def before_table_row(table_row)
        @row_id = table_row.dom_id
        @col_index = 0
        return if @hide_this_step
        @builder << "<tr class='step' id='#{@row_id}'>"
      end

      def after_table_row(table_row)
        return if @hide_this_step
        @builder << '</tr>'
        # if table_row.exception
        #   @builder.td(:colspan => @col_index.to_s, :class => 'failed') do
        #   end
        # end
        if @outline_row
          @outline_row += 1
        end
        @step_number += 1
        move_progress
      end

      def table_cell_value(value, status)
        return if @hide_this_step

        @cell_type = @outline_row == 0 ? :th : :td
        attributes = {:id => "#{@row_id}_#{@col_index}", :class => 'step'}
        attributes[:class] += " #{status}" if status
        build_cell(@cell_type, value, attributes, status)
        set_scenario_color(status)
        @col_index += 1
      end

      def announce(announcement)
        @builder.pre(announcement, :class => 'announcement')
      end

      protected

      # NOTE that this also gets called after each example in scenario outline
      def set_scenario_color(status)
        # if @is_example
        # else
        #   case status
        #   when :undefined
        #     @builder.script do |script|
        #       script.text! "markAsUndefined('scenario_#{@scenario_number}');"
        #     end
        #   end
        #   if status == :undefined || status == :pending || status == :skipped
        #       @builder.script do
        #         @builder.text!("makeBlack('cucumber-header');") unless @header_red
        #         @builder.text!("makeBlack('scenario_#{@scenario_number}');") unless @scenario_red
        #       end
        #   end
        # end

        # if status == :failed
        #     @builder.script do
        #       @builder.text!("makeRed('cucumber-header');") unless @header_red
        #       @header_red = true
        #       @builder.text!("makeRed('scenario_#{@scenario_number}');") unless @scenario_red
        #       @scenario_red = true
        #     end
        #   end
        end

        def get_step_count(features)
          count = 0
          features = features.instance_variable_get("@features")
          features.each do |feature|
            #get background steps
            if feature.instance_variable_get("@background")
              background = feature.instance_variable_get("@background").instance_variable_get("@steps").instance_variable_get("@steps")
              count += background.size unless background.nil?
            end
            #get scenarios
            feature.instance_variable_get("@feature_elements").each do |scenario|
              #get steps
              steps = scenario.instance_variable_get("@steps").instance_variable_get("@steps")
			  unless steps.nil?
				  count += steps.size unless steps.nil?

				  #get example table
				  examples = scenario.instance_variable_get("@examples_array")
				  unless examples.nil?
					examples.each do |example|
					  example_matrix = example.instance_variable_get("@outline_table").instance_variable_get("@cell_matrix")
					  count += example_matrix.size unless example_matrix.nil?
					end
				  end

				  #get multiline step tables
				  steps.each do |step|
					multi_arg = step.instance_variable_get("@multiline_arg")
					next if multi_arg.nil?
					matrix = multi_arg.instance_variable_get("@cell_matrix")
					count += matrix.size unless matrix.nil?
				  end
				end
            end
          end
          return count
        end

        def build_step(keyword, step_match, status)
          step_name = step_match.format_args(lambda{|param| %{#{param}}})
          @builder.div do |div|
            div.span(keyword, :class => 'keyword') unless keyword.strip == '*'
            div.text!(' ')
            div.span(:class => 'step val') do |name|
              name << h(step_name).gsub(/&lt;(\w+)&gt;/, '<code>\1</code>')
            end
            div.span(:class => status_css_class(status)) do |span|
              span.text! status_text(status)
            end
          end
        end

        def status_css_class(status)
          css = 'label label-'
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
            @scenario_outline ? '' : 'S'
          when :pending
            'P'
          else
            ''
          end
        end

        def build_cell(cell_type, value, attributes, status)
          @builder.__send__(cell_type, attributes) do
            @builder.div do |div|
              div.span(value,:class => 'step param')
              div.span(:class => status_css_class(status)) do |span|
                span.text! status_text(status)
              end
            end
          end
        end

        def inline_css
          dir = Dir.open(File.dirname(__FILE__))
          dir.entries.select { |e| e.match /.+\.css/ }.each do |f|
            @builder.style(:type => 'text/css') do
              @builder << File.read(File.dirname(__FILE__) + "/#{f}")
            end
          end
        end

    		def google_js
          # @builder.script(:type => 'text/javascript', :src => 'http://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.min.js') do
          #   @builder << ' '
          # end
    		end

        def inline_js
          dir = Dir.open(File.dirname(__FILE__))
          dir.entries.select { |e| e.match /.+\.js/ }.each do |f|
            @builder.script do |script|
              script << File.read(File.dirname(__FILE__) + "/#{f}")
            end
          end
        end

        def move_progress
          # @builder << " <script type=\"text/javascript\">moveProgressBar('#{percent_done}');</script>"
        end

        def percent_done
          result = 100.0
          if @step_count != 0
            result = ((@step_number).to_f / @step_count.to_f * 1000).to_i / 10.0
          end
          result
        end

        def backtrace_line(line)
          line.gsub(/^([^:]*\.(?:rb|feature|haml)):(\d*)/) do
            if ENV['TM_PROJECT_DIRECTORY']
              "<a href=\"txmt://open?url=file://#{File.expand_path($1)}&line=#{$2}\">#{$1}:#{$2}</a> "
            else
              line
            end
          end
        end

        def print_stat_string(features)
          # string = String.new
          # string << dump_count(@step_mother.scenarios.length, "scenario")
          # scenario_count = print_status_counts{|status| @step_mother.scenarios(status)}
          # string << scenario_count if scenario_count
          # string << "<br />"
          # string << dump_count(@step_mother.steps.length, "step")
          # step_count = print_status_counts{|status| @step_mother.steps(status)}
          # string << step_count if step_count
        end

        def print_status_counts
          counts = [:failed, :skipped, :undefined, :pending, :passed].map do |status|
            elements = yield status
            elements.any? ? "#{elements.length} #{status.to_s}" : nil
          end.compact
          return " (#{counts.join(', ')})" if counts.any?
        end

        def dump_count(count, what, state=nil)
          [count, state, "#{what}#{count == 1 ? '' : 's'}"].compact.join(" ")
        end

        def create_builder(io)
          OrderedXmlMarkup.new(:target => io, :indent => 2)
        end
    end
  end
end


class SnippetExtractor #:nodoc:
  class NullConverter; def convert(code, pre); code; end; end #:nodoc:
  begin; require 'syntax/convertors/html'; @@converter = Syntax::Convertors::HTML.for_syntax "ruby"; rescue LoadError => e; @@converter = NullConverter.new; end

  def snippet(error)
    raw_code, line = snippet_for(error[0])
    highlighted = @@converter.convert(raw_code, false)
    highlighted << "\n<span class=\"comment\"># gem install syntax to get syntax highlighting</span>" if @@converter.is_a?(NullConverter)
    post_process(highlighted, line)
  end

  def snippet_for(error_line)
    if error_line =~ /(.*):(\d+)/
      file = $1
      line = $2.to_i
      [lines_around(file, line), line]
    else
      return snippet_for()
      ["# Couldn't get snippet for #{error_line}", 1]
    end
  end

  def lines_around(file, line)
    if File.file?(file)
      lines = File.open(file).read.split("\n")
      min = [0, line-3].max
      max = [line+1, lines.length-1].min
      selected_lines = []
      selected_lines.join("\n")
      lines[min..max].join("\n")
    else
      "# Couldn't get snippet for #{file}"
    end
  end

  def post_process(highlighted, offending_line)
    new_lines = []
    highlighted.split("\n").each_with_index do |line, i|
      new_line = "<span class=\"linenum\">#{offending_line+i-2}</span>#{line}"
      new_line = "<span class=\"offending\">#{new_line}</span>" if i == 2
      new_lines << new_line
    end
    new_lines.join("\n")
  end

end
