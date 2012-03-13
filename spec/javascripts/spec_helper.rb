Flowerbox.configure do |c|
  c.test_with :jasmine
  c.run_with :node

  c.asset_paths << "lib/assets/javascripts"

  c.report_with :verbose
end

