require 'sprockets'
require 'sprockets-vendor_gems'
require 'sprockets-sass'
require 'compass'
require 'sinatra'
require 'nokogiri'
require 'rdiscount'
require 'pygments'
require 'sinatra/base'

require 'rack/builder'

module Attentive
  class Server < Rack::Builder
    def self.call(env)
      @app ||= Rack::Builder.new do
        map '/assets' do
          env = Sprockets::EnvironmentWithVendoredGems.new
          env.append_path 'assets/javascripts'
          env.append_path 'assets/stylesheets'
          env.append_path Attentive.root.join('vendor/assets/javascripts')
          env.append_path Attentive.root.join('lib/assets/javascripts')
          env.append_path Attentive.root.join('lib/assets/stylesheets')

          run env
        end

        map '/' do
          run Attentive::Sinatra
        end
      end

      @app.call(env)
    end
  end

  class Sinatra < Sinatra::Base
    set :logging, true

    helpers do
      def trim_lines(code)
        code.lines.collect(&:strip).join("\n")
      end

      def slides
        highlights = []

        output = Dir['presentation/*.html'].sort.collect do |file|
          xml = Nokogiri::XML("<doc>#{File.read(file)}</doc>")

          xml.search('slide').collect do |node|
            classes = %w{slide}

            if style = node.attributes['style']
              style.to_s.split(' ').each { |s| classes << "style-#{s}" }
            end

            node.search('code').collect do |code|
              highlighted_code = Pygments.highlight(code.inner_text.strip, :lexer => code.attributes['lang'].to_s)

              code.add_next_sibling("{highlight#{highlights.length}}")

              code.remove

              highlights << highlighted_code
            end

            content = node.inner_html

            content = case node.attributes['content'].to_s
            when 'html'
              content
            else
              RDiscount.new(trim_lines(content)).to_html
            end

            %{<div class="#{classes.join(' ')}"><div class="content">#{content}</div></div>}
          end.join
        end.join

        highlights.each_with_index do |highlight, index|
          output.gsub!("{highlight#{index}}", highlight)
        end

        output
      end
    end

    get '/' do
      haml :index, :ugly => true
    end

    set :views, [ File.join(Dir.pwd, 'views'), Attentive.root.join('views')]

    private
    def render(engine, data, options = {}, locals = {}, &block)
      settings.views.each do |view|
        template = "#{data}.#{engine}"

        if File.file?(File.join(view, template))
          return super(engine, data, options.merge(:views => view), locals, &block)
        end
      end
    end
  end
end

