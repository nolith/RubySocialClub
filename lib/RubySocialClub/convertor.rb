# encoding: utf-8
require 'rexml/document'
require 'syntax/convertors/html'

module RubySocialClub

  # TODO: to refactor
  class Convertor
    include REXML

    SEPARATOR = "\u00a4".freeze

    attr_accessor :source_file

    def self.prepare_irb_session(file)
      tmp = `cat #{file} | bundle exec irb -f --noreadline --prompt-mode xmp`
      tmp.gsub!(/\s*#NO=OUTPUT.*?==>/m, "\n ==>")
      tmp.gsub!(/\s*#NO=RESULT\n\s*==>\s*.*?\n/m, "\n")
      tmp.gsub!(/\s*\n\s*==>\s*/m, "\t\"thisistheresult_bwdye\"\t")
    end

    def initialize(src, parse_xmp = false)
      @source_file=src
      @parse_xmp = parse_xmp
      clear
    end

    def clear
      @code_html = nil
      @html_latex = nil
    end

    def to_html
      return @code_html unless @code_html.nil?

      code= File.read(@source_file) #, :encoding => 'ISO_8859_15')

      convertor = Syntax::Convertors::HTML.for_syntax "ruby"
      @code_html = convertor.convert( code )
    end

    def to_latex
      return @html_latex unless @html_latex.nil?

      text = to_html

      file = Document.new text
      body = file.elements['//pre[1]']

      first = true

      r = ''
      body.each do | e |
        if e.is_a?Text
          t = e.to_s
          t = t[1..-1] if first
          first = false
          r << latexize(t)
        else
          first = false
          text = e.get_text.to_s
          r << text.split("\n",-1).map do | t |
            if e.attributes['class'] == 'string'
              codes = "\\codestring"
              tmp = e.map do |ee|
                if ee.is_a?Text
                  latexize(ee.to_s)
                else
                  eet = ee.get_text.to_s
                  pref = remap(ee.attributes['class'])
                  "#{pref}#{'{' unless pref.nil?}#{latexize(eet)}#{'}' unless pref.nil?}"
                end
              end.join
              codes + "{" + tmp + "}"
            elsif (latexize(t) !~ /^\s*$/)
              pref = remap(e.attributes['class'])
              "#{pref}#{'{' if pref != ""}#{latexize(t)}#{'}' if pref != ""}"
            else
              ''
            end
          end.join("\n")
        end
      end

      lines = r.split("\n")
      lines.map! { | line | "#{SEPARATOR}{#{line.gsub(/^\s*/) { | m | "\\RubyIndent{#{m.gsub(/\t/, '  ').length}}" }}}#{SEPARATOR}" }
      @html_latex = lines.join("\n")
      if @parse_xmp
        result_to_latex
      else
        @html_latex
      end
    end


    def result_to_latex
      @html_latex.gsub!(/\t"\\codestring\{thisistheresult\\_bwdye\}"\t(.*)#{Regexp.quote(SEPARATOR)}$/,
                        "\t\\XMPresult{\\1}#{SEPARATOR}")
      @html_latex.gsub!(/\\codekeyword\{class\t\}"thisistheresult\\_bwdye"\t(.*)#{Regexp.quote(SEPARATOR)}$/,
                        "class\t\\XMPresult{\\1}#{SEPARATOR}")
    end
    protected :result_to_latex

    def latexize(str)
      str.gsub(%r!\\|\^|\$|&lt;|&gt;|&amp;|&quot;|#|\{|\}|"|~|_|%| |&!) do | match |
        case match
          when '\\' then '\ensuremath{\backslash}'
          when '^' then '\ensuremath{\hat{\ }}'
          when '$' then '\$'
          when '&lt;' then '<'
          when '&gt;' then '>'
          when '&amp;' then '\&'
          when '&quot;' then '"'
          when '#' then '\#'
          when '{' then '\{'
          when '}' then '\}'
          when '"' then '"'
          when '~' then '\textasciitilde{}'
          when '_' then '\_'
          when '%' then '\%'
          when ' ' then '\ '
          when '&' then '\&'
        end
      end.gsub('<<', '<{}<').gsub('>>', '>{}>')
    end
    protected :latexize

    def remap(string)
      prefisso = "\\code"
      suff = case string
               when "comment"
                 "comment"
               when "method"
                 "functionname"
               when "attribute"
                 "variablename"
               when "punct"
                 nil
               when "constant"
                 "variablename"
               when "number"
                 "type"
               when "ident"
                 nil
               when "symbol"
                 "type"
               when "global"
                 "variablename"
               when "string"
                 "string"
               when "keyword"
                 "keyword"
               else       #esistono anche excape ed expr
                 nil
             end

      return prefisso + suff unless suff.nil?
      return ""
    end
    protected :remap

  end
end