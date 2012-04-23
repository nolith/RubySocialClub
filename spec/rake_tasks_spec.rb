require "spec_helper"
require "rake"
require 'FileUtils'

describe "app rake tasks" do
  TMP_FOLDER = File.join('..','tmp')
  TMP_SOURCE_DIR = File.join TMP_FOLDER, 'sources'

  before do
    FileUtils.rm_rf(TMP_FOLDER) if Dir.exist? TMP_FOLDER
    FileUtils.cp_r('files/.', TMP_FOLDER)

    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require File.join("tmp", "rakefile")
    Rake::Task.define_task(:environment)
  end

  describe "rake default" do
    before do
      @task_name = "default"
      #YAML.stub!(:load_file).and_return([])
    end
    it "should have 'sources' and 'irb_sources' as a prereq" do
      @rake[@task_name].prerequisites.should include("sources")
      @rake[@task_name].prerequisites.should include("irb_sources")
    end
    it "should load 'config/options.yml'" do
      YAML.should_receive(:load_file).with("config/options.yml").and_return([])
      @rake[@task_name].invoke
    end
    it "should generate a tex file foreach rb file" do
      @rake[@task_name].invoke
      Dir[File.join(TMP_SOURCE_DIR, "*.tex")]
      Dir[File.join(TMP_SOURCE_DIR, "*.tex")].size.should be ==  Dir[File.join(TMP_SOURCE_DIR, "*.rb")].size
    end
  end
end