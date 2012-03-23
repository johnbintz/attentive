require 'sprockets'
require 'sprockets-vendor_gems'
require 'sprockets-sass'
require 'compass'
require 'attentive/compass_patches'
require 'sinatra'
require 'nokogiri'
require 'rdiscount'
require 'pygments'
require 'sinatra/base'

require 'rack/builder'

require 'forwardable'

module Attentive
  module Helpers
    def image_path(path, options)
      if resolve(path, options)
        return "/assets/#{path}"
      end

      nil
    end
  end

  class Server < Rack::Builder
    def self.sprockets_env
      @sprockets_env ||= Sprockets::EnvironmentWithVendoredGems.new
    end

    def self.start(options)
      require 'rack'
      require 'pygments'
      require 'coffee_script'
      require 'sass'

      require 'tilt/coffee'

      # make sure pygments is ready before starting a new thread
      Pygments.highlight("attentive")

      Rack::Handler.default.run(Attentive::Server, :Port => options[:port]) do |server|
        trap(:INT) do
          server.shutdown if server.respond_to?(:server)
          server.stop if server.respond_to?(:stop)
        end
      end
    end

    def self.call(env)
      @app ||= Rack::Builder.new do
        map '/assets' do
          env = ::Attentive::Server.sprockets_env
          env.append_path 'assets/javascripts'
          env.append_path 'assets/stylesheets'
          env.append_path 'assets/images'
          env.append_path Attentive.root.join('lib/assets/javascripts')
          env.append_path Attentive.root.join('lib/assets/stylesheets')
          env.context_class.send(:include, ::Attentive::Helpers)

          Tilt::CoffeeScriptTemplate.default_bare = true

          run env
        end

        map '/' do
          Attentive.middleware.each do |opts|
            use(*opts)
          end

          run Attentive::Sinatra
        end
      end

      @app.call(env)
    end
  end

  class Slide
    extend Forwardable

    def_delegators :lines, :<<

    attr_reader :lines

    def initialize(options = {})
      @options = options
      @lines = []
    end

    def classes
      ([ 'slide' ] + (@options[:classes] || []).collect { |klass| "style-#{klass}" }).join(' ')
    end

    def code_output
      new_lines = []

      code_block = nil
      code_language = nil

      lines.each do |line|
        if line[%r{^```}]
          if code_block
            new_lines << Pygments.highlight(code_block.join, :lexer => code_language)
            code_block = nil
          else
            code_block = []

            parts = line.split(' ')

            code_language = case parts.length
            when 1
              'text'
            else
              parts.last
            end
          end
        else
          if code_block
            code_block << line
          else
            new_lines << line
          end
        end
      end

      new_lines
    end

    def markdown_output
      RDiscount.new(code_output.join).to_html
    end

    def to_html
      output =  [ %{<div class="#{classes}"><div class="content">} ]

      output << markdown_output

      output << "</div></div>"

      output.join("\n")
    end
  end

  class Sinatra < Sinatra::Base
    set :logging, true

    helpers do
      def slides
        slides = []

        Dir['presentation/*.slides'].sort.each do |file|
          File.readlines(file).each do |line|
            if line[%r{^!SLIDE}]
              slides << Slide.new(:classes => line.split(' ')[1..-1])
            else
              slides << Slide.new if !slides.last
              slides.last << line
            end
          end
        end

        slides.collect(&:to_html).join
      end
    end

    get %r{/?\d*} do
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

