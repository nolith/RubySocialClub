$: << File.expand_path('../../lib/', __FILE__)

require 'RubySocialClub'
require 'RubySocialClub/rake_tasks'

ruby_source 'sources'

task :default => [:sources, :irb_sources]