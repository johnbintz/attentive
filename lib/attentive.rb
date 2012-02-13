require "attentive/version"

module Attentive
  autoload :Server, 'attentive/server'

  class << self
    attr_accessor :title, :has_presentation

    def has_presentation?
      @has_presentation == true
    end

    def middleware
      @middleware ||= []
    end
  end

  def self.configure
    yield self

    Attentive.has_presentation = true
  end

  def self.root
    Pathname(File.expand_path('../..', __FILE__))
  end

  class NoPresentationError < StandardError ; end
end

