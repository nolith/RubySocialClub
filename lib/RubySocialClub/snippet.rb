

=begin
This class splits all the rb files into snippet files.

A file like this

  #!/usr/bin/ruby

  #############<hello_world>#############

  #!/usr/bin/ruby

  3.times {puts 'Hello World'}

  #############<hello_method>#############

  #!/usr/bin/ruby

  def ciao(nome)
    puts "Ciao #{nome}"
  end

  ciao('Mario')

  #############<hello_puts>#############

  puts "Cosa è puts?"
  puts("un semplice metodo")

Will produces 3 files. hello_world.rb, hello_method.rb and hello_puts.rb
=end
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

  def self.snippettize_dir(src='.', out='snippets')
    Dir[File.join(src, '*.rb')].each do | filename |
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
            output = Snippet.new(File.join(out, $1))
          elsif output
            output.print(line)
          end
        end
        output.close if output
      end
    end
  end
end


