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

def ruby_source(src)

  files = generate_file_lists(src)

  src_files = files[:src]
  tex_files = files[:tex]
  irb_tex_files = files[:irb]
  output_files = files[:output]

  desc "Generates all the source examples"
  task :sources => tex_files

  desc "Generates all the IRB source examples"
  task :irb_sources => irb_tex_files

  desc "Executes all the source examples"
  task :output => output_files

  desc "Generates snippets" 	
  task :snippets do
    snippet_src = RubySocialClub::Snippet.snippettize_dir(src)
    puts "snippets in #{snippet_src}"
    snippet_files = generate_file_lists(snippet_src)
    
    task :snp_all => snippet_files[:tex]
    task :snp_all => snippet_files[:irb]
    task :snp_all => snippet_files[:output]
    Rake::Task[:snp_all].invoke 
  end
  CLEAN.include(File.join(src, 'snippets', '*.rb'))
end

def generate_file_lists(src)
  src_files = FileList[File.join(src, '*.rb')]
  tex_files = src_files.ext('tex')
  irb_tex_files = src_files.ext('xmp.tex')
  output_files = src_files.ext('out')

  CLEAN.include(File.join(src, '*.tex'))
  CLEAN.include(File.join(src, '*.xmp'))
  CLEAN.include(File.join(src, '*.out'))

  generate_task_basedfile_list(src_files, 'xmp') do |t, src|
    tmp = RubySocialClub::Convertor.prepare_irb_session src
    File.open(t.name, 'w:ISO-8859-15') { |f| f << tmp }
  end

  generate_task_basedfile_list(src_files, 'out') do |t, src|
    sh "bundle exec ruby #{src} > #{t.name} 2>&1 ; true"
  end

  generate_task_basedfile_list(src_files, 'tex') do |t, src|
    puts "#{src} -> #{t.name}"
    c = RubySocialClub::Convertor.new(src)
    latex = c.to_latex
    File.open(t.name, 'w:ISO-8859-15') { |f| f << latex }
  end

  generate_task_basedfile_list(src_files.ext('xmp'), 'xmp.tex') do |t, src|
    puts "#{src} -> #{t.name}"
    c = RubySocialClub::Convertor.new(src, true)
    latex = c.to_latex
    File.open(t.name, 'w:ISO-8859-15') { |f| f << latex }       
  end

  { :src => src_files, :tex => tex_files, 
    :irb => irb_tex_files, :output => output_files }
end

def generate_task_basedfile_list(file_list, new_ext)
  file_list.each do |src_file|
    dst_file = src_file.clone
    src_ext_len = File.extname(src_file).length() -1
    dst_file[-src_ext_len..-1] = new_ext
    #puts "Generating rule #{src_file} -> #{dst_file}"
    file dst_file => src_file do |t|
      yield [t, t.prerequisites[0]]       
    end
  end  
end

