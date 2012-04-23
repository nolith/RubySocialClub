require 'syntax/convertors/html'

if ARGV.size > 0
    code= File.read(ARGV[0])
else
    code= $stdin.read
end

convertor = Syntax::Convertors::HTML.for_syntax "ruby"
@code_html = convertor.convert( code )


if ARGV.size > 0
    fn= "#{File.basename(ARGV[0], File.extname(ARGV[0]))}.html"
    File.open(fn,'w') { |file|  file << @code_html }
else
    puts @code_html
end

