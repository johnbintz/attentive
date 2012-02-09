require "attentive/version"

module Attentive
  autoload :Server, 'attentive/server'

  class << self
    attr_accessor :title
  end

  def self.configure
    yield self
  end

  def self.root
    Pathname(File.expand_path('../..', __FILE__))
  end
end
