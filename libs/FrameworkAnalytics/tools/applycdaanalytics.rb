#!/usr/bin/ruby

#config goes here:
cwd = Dir.pwd
filestomatch = File.join("**", "*.{h,m,mm}")
files = Dir.glob(filestomatch)
files=files-["libs/FrameworkAnalytics/cdaAnalytics.h"]-["libs/FrameworkAnalytics/cdaAnalytics.m"]-["libs/FrameworkAnalyticsGoogleWrapper/cdaAnalyticsGoogleTracker.h"]-["libs/FrameworkAnalyticsGoogleWrapper/cdaAnalyticsGoogleTracker.m"]-["libs/FrameworkAnalyticsFlurryWrapper/cdaAnalyticsFlurryTracker.h"]-["libs/FrameworkAnalyticsFlurryWrapper/cdaAnalyticsFlurryTracker.m"]

filepaths=[]
files.each do |file|
  filepaths << File.join(cwd,file)
end

totallines = 0
modifiedFiles = 0

def parseFile(filepath)
  contents=""
  filecontent=[]
  flurrylines=[]
  cat=[]
  event=[]
  label=[]
  linenumber=0
  flurryliteralCount=0
  errorCount = 0
  
  f = File.open(filepath, "r") 
  f.each_line do |line|
    require 'iconv' unless String.method_defined?(:encode)
    if String.method_defined?(:encode)
      line.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
      line.encode!('UTF-8', 'UTF-16')
    else
      ic = Iconv.new('UTF-8', 'UTF-8//IGNORE')
      line = ic.iconv(line)
    end
    
    matchError = false;
    e = ""
    l = ""
    c = ""
    if m = line.match(/\[FlurryAnalytics logEvent:(.+)\s+withParameters:/)
      print("matched raw event cat: #{$1}\n")
      x= $1.strip()
      c = x;
    else
      matchError = true
    end
    if !matchError 
      if m = line.match(/dictionaryWithObjectsAndKeys:(.+),\s*nil\]\];/)
        print("matched event action+label: #{$1}\n")
        a = $1.split(',')
        l = a[a.length-1].strip()
        x = ""
        #if there are more than 2 comma seperated values we take the last one as the label and join all the ones before back as the action!
        if a.length > 2
          (0..a.length-2).each do |i|
            if i > 0
              x += ','
            end
            x += a[i]
          end
        else
          x = a[0]
        end
        e = x.strip()
      else
        matchError = true
        p "\nERROR: parse error at line: #{linenumber}\n"
        errorCount+=1
      end
    end
    
    if m = line.match(/\[FlurryAnalytics logEvent:(@\".*\")\s*\];/)
      flurryliteralCount+=1
      line.gsub!(/\[FlurryAnalytics logEvent:(@\".*\")\s*\];/, "[[cdaAnalytics sharedInstance] trackEvent:#{$1.strip()}];")
      p "#{filepath}:#{linenumber} => #{line}"
      filecontent << line
    end
    
    if !matchError
      unless c.eql?("") && e.eql?("") && l.eql?("")
        cat << c
        event << e
        label << l
        flurrylines << linenumber
      end
    end
    filecontent << line
    linenumber+=1
  end
  f.close
  
  #removeing the old analytics code and replacing with new
  ci = 0
  flurrylines.each do |c|
    filecontent[c].gsub!(/\[FlurryAnalytics logEvent:.+/, "[[cdaAnalytics sharedInstance] trackEvent:#{event[ci]} inCategory:#{cat[ci]} withLabel:#{label[ci]} andValue:-1];")
    if m = filecontent[c+1].match(/NSError \*error;/)
      p "ga found!! removing..."
      (1..9).each do |i|
        filecontent[c+i] = ""
      end
    end
    p "#{filepath}:#{c+1} => #{filecontent[c]}"
    ci += 1
  end
  
  if flurrylines.length + flurryliteralCount > 0
    filecontent.each do |line|
       contents += line;
    end
    unless ARGV[0].eql?("apply")
      print "dry run on: #{filepath}\n"
    else
      f = File.open(filepath, "w+") 
      f.puts contents
      f.close
      print "real run on: #{filepath}"
    end
  end
  return flurrylines.length + flurryliteralCount
end

filepaths.each do |file|
  p "parsing file #{file} ..."
  lines = parseFile(file)
  if lines > 0
    totallines += lines
    modifiedFiles += 1
  end
  p "done parsing #{file}"
end
#p "number of parse errors: #{errorCount}"                                              
p "number of files modified: #{modifiedFiles}"
p "total lines replaced: #{totallines}"


