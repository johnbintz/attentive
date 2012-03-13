require 'guard'
require 'guard/guard'

require 'flowerbox'

class ::Guard::FlowerboxUnit < ::Guard::Guard
  def run_all
    ::Flowerbox.run('spec/javascripts')
  end

  def run_on_change(files)
    run_all
  end
end

class ::Guard::FlowerboxIntegration < ::Guard::Guard
  def run_all
    ::Flowerbox.run('js-features')
  end

  def run_on_change(files)
    run_all
  end
end

guard 'flowerbox-unit' do
  watch(%r{^spec/javascripts})
end

guard 'flowerbox-integration' do
  watch(%r{^js-features})
end

