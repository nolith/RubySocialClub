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

rule '.tex' => '.rb' do |t|
  puts "#{t.source} -> #{t.name}"
  c = RubySocialClub::Convertor.new(t.source)
  latex = c.to_latex
  File.open(t.name, 'w') { |f| f << latex }
end

rule '.xmp.tex' => '.xmp' do |t|
  puts "#{t.source} -> #{t.name}"
  c = RubySocialClub::Convertor.new(t.source, true)
  latex = c.to_latex
  File.open(t.name, 'w') { |f| f << latex }
end

def ruby_source(src)

  src_files = FileList[File.join(src, '*.rb')]
  tex_files = src_files.ext('tex')
  irb_tex_files = src_files.ext('xmp.tex')

  CLEAN.include(File.join(src, '*.tex'))
  CLEAN.include(File.join(src, '*.xmp'))

  desc "Generates all the source examples"
  task :sources => tex_files

  desc "Generates all the IRB source examples"
  task :irb_sources => irb_tex_files
end