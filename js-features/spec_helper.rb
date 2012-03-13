Flowerbox.configure do |c|
  c.test_with :cucumber
  c.run_with :chrome

  c.asset_paths << "lib/assets/javascripts"
  c.spec_patterns << "**/*.js*"
  c.spec_patterns << "*.js*"
  c.spec_patterns << "**/*.feature"
  c.spec_patterns << "*.feature"

  c.report_with :verbose
end

