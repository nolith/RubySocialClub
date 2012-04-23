# Fixme: Implement close on GC.
#        How is that done?
class Snippet
  def initialize(filename)
    @filename = filename
    @content = []
  end

  def print(line)
    @content << line
  end

  def strip
    @content.pop until /[\S]/ =~ @content[-1]
    @content.shift until /[\S]/ =~  @content[0]
  end

  def close
    strip
    text = @content.join('')
    if (not File.exist?(@filename+'.rb')) or (File.read(@filename + '.rb') != text)
      puts "Rewriting #{@filename}.rb"
      File.open(@filename + '.rb', 'w') do | file |
        file.print(text)
      end
    else
      puts "Skipped #{@filename}.rb because it was the same"
    end
  end
end

Dir['*.rb'].each do | filename |
  puts "Splitting #{filename}"
  File.open(filename) do | file |
    output = nil
    file.each do | line |
			line.encode!('UTF-8', 'UTF-8', :invalid => :replace)
      if /^\s*\#+<\/>\#*\s*$/ =~ line 
        output.close if output
        output = nil
      elsif /^\s*\#+<(.*)>\#*\s*$/ =~ line 
        output.close if output
        output = nil
        output = Snippet.new("snippets/#{$1}")
      elsif output
        output.print(line)
      end
    end
    output.close if output
  end
end
