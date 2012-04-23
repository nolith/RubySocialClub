# encoding: utf-8
require 'rexml/document'
require 'syntax/convertors/html'

module RubySocialClub

  # TODO: to refactor
  class Convertor
    include REXML

    attr_accessor :source_file

    def initialize(src)
      @source_file=src
      clear
    end

    def clear
      @code_html = nil
      @html_latex = nil
    end

    def to_html
      return @code_html unless @code_html.nil?

      code= File.read(@source_file)

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
      lines.map! { | line | "\xa4{#{line.gsub(/^\s*/) { | m | "\\RubyIndent{#{m.gsub(/\t/, '  ').length}}" }}}\xa4" }
      @html_latex = lines.join("\n")
    end


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