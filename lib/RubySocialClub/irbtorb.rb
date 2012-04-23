irb = []
output = []

$stdin.read.split("\n").each do | line |
  case line
  when /^[>?]> (.*?)\s*$/
    if output.length > 0
      irb << [:output, output.join("\n")]
      output = []
    end
    irb << [:input, $1]
  when /^(.*?)=> (.*?)\s*$/
    irb << [:result, "\t=result=>> #{$2}\n"]
    o = $1
    output << '#OUTPUT:' + o unless o =~ /^\S*$/
    if output.length > 0
      irb << [:output, output.join('')]
      output = []
    end
  else
    output << "#OUTPUT:#{line}\n"
  end
end

irb.each_index do | i |
  irb[i][1] << "\n" if (irb[i][0] == :input) and (irb[i+1]) and (irb[i+1][0] != :result)  
end

print irb.map{|type, text| text}.join("")
