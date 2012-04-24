# encoding: utf-8

require 'rake'
require 'rake/clean'

require 'RubySocialClub/convertor'

#CLEAN.include('*.o')
#CLOBBER.include('hello')
#
#task :default => ["hello"]
#
#SRC = FileList['*.c']
#OBJ = SRC.ext('o')
#
#rule '.o' => '.c' do |t|
#  sh "cc -c -o #{t.name} #{t.source}"
#end
#
#file "hello" => OBJ do
#  sh "cc -o hello #{OBJ}"
#end
#
## File dependencies go here ...
#file 'main.o' => ['main.c', 'greet.h']
#file 'greet.o' => ['greet.c']

rule '.xmp' => '.rb' do |t|
  tmp = RubySocialClub::Convertor.prepare_irb_session t.source
  File.open(t.name, 'w') { |f| f << tmp }
end

rule '.out' => '.rb' do |t|
  sh "bundle exec ruby #{t.source} > #{t.name} 2>&1 ; true"
end

rule '.tex' => '.rb' do |t|
  puts "#{t.source} -> #{t.name}"
  c = RubySocialClub::Convertor.new(t.source)
  latex = c.to_latex
  File.open(t.name, 'w') { |f| f << latex }
end

def ruby_source(src)

  src_files = FileList[File.join(src, '*.rb')]
  tex_files = src_files.ext('tex')
  irb_tex_files = src_files.ext('xmp.tex')
  output_files = src_files.ext('out')

  CLEAN.include(File.join(src, '*.tex'))
  CLEAN.include(File.join(src, '*.xmp'))
  CLEAN.include(File.join(src, '*.out'))

  desc "Generates all the source examples"
  task :sources => tex_files

  desc "Generates all the IRB source examples"
  task :irb_sources => irb_tex_files

  desc "Executes all the source examples"
  task :output => output_files

  src_files.ext('xmp').each do |xmp_file|
    xmp_tex = xmp_file.clone
    xmp_tex[-3..-1] = 'xmp.tex'

    file xmp_tex => xmp_file do |t|
      src = t.prerequisites[0]
      puts "#{src} -> #{t.name}"
      c = RubySocialClub::Convertor.new(src, true)
      latex = c.to_latex
      File.open(t.name, 'w') { |f| f << latex }       
    end
  end
end
