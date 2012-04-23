# encoding: utf-8

require 'RubySocialClub/convertor'
require 'FileUtils'

module RubySocialClub
  describe "Convertor" do

    def rb_file_convert_and_check(file, parse_xmp = false)
      c = RubySocialClub::Convertor.new(file, parse_xmp)
      latex = c.to_latex
      latex.should_not be_nil
      latex.encoding.should be(Encoding::UTF_8)
      #"\xa4".should include(RubySocialClub::Convertor::SEPARATOR)
      latex.split("\n").each do |line|
        puts "Checkin line #{line}"
        line[0].should == RubySocialClub::Convertor::SEPARATOR
        line[-1].should == RubySocialClub::Convertor::SEPARATOR
      end
      latex
    end

    TMP_FOLDER = File.join('..','tmp')
    TMP_SOURCE_DIR = File.join TMP_FOLDER, 'sources'
    before :each do
      FileUtils.rm_rf(TMP_FOLDER) if Dir.exist? TMP_FOLDER
      FileUtils.cp_r('files/.', TMP_FOLDER)
    end

    it "should convert normal ruby file to latex source" do
      file = File.join(TMP_SOURCE_DIR, 'object.rb')
      rb_file_convert_and_check(file)
    end

    it "should convert irb ruby session to latex source" do
      file = File.join(TMP_SOURCE_DIR, 'object.rb')
      irb_xml = RubySocialClub::Convertor.prepare_irb_session file
      #puts irb_xml
      xmp_file = File.join(TMP_FOLDER, 'session.xmp.rb')
      File.open(xmp_file, 'w') { |f| f << irb_xml }
      latex = rb_file_convert_and_check(xmp_file, true)
      #puts latex
      latex.split("\n").each do |line|
        if(line.include? '\XMPresult')
          line.should match /\\XMPresult\{.+\}/
        end
      end
    end

  end
end
