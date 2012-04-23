# encoding: utf-8
require 'rexml/document'

include REXML

text = $stdin.read

file = Document.new text
body = file.elements['//pre[1]']

class String
  def to_latex
    self.gsub(%r!\\|\^|\$|&lt;|&gt;|&amp;|&quot;|#|\{|\}|"|~|_|%| |&!) do | match |
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
end

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

first = true

r = ''
body.each do | e |
  if e.is_a?Text 
    t = e.to_s 
    t = t[1..-1] if first
    first = false
    r << t.to_latex
  else
    first = false
    text = e.get_text.to_s 
    r << text.split("\n",-1).map do | t | 
      if e.attributes['class'] == 'string' 
        codes = "\\codestring"    
        tmp = e.map do |ee|     
                if ee.is_a?Text 
                  ee.to_s.to_latex
                else    
                  eet = ee.get_text.to_s 
                  pref = remap(ee.attributes['class'])
                  "#{pref}#{'{' unless pref.nil?}#{eet.to_latex}#{'}' unless pref.nil?}" 
                end
        end.join
        codes + "{" + tmp + "}" 
      elsif (t.to_latex !~ /^\s*$/) 
        pref = remap(e.attributes['class'])
        "#{pref}#{'{' if pref != ""}#{t.to_latex}#{'}' if pref != ""}"
      else
         ''
      end
    end.join("\n")
  end
end

lines = r.split("\n")
lines.map! { | line | "\xa4{#{line.gsub(/^\s*/) { | m | "\\RubyIndent{#{m.gsub(/\t/, '  ').length}}" }}}\xa4" }
print lines.join("\n")
