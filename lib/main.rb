 # will generate a mind map of the current environment

  class File
    def self.open_mm(*args)
      io=File.open(*args)
      io.write("<map version=\"mm0.1\">\n")
      yield io
      io.write("</map>\n")
      io.close()
    end
    def child(options={})
      parameters=[]
      options.each {|option,value|
        parameters.push("#{option.to_s.upcase}=\"#{value}\"")
      }

      self.puts("<node CREATED=\"#{Time.now.to_i}#{rand(899)+100}\" ID=\"scenario_#{options[:text].gsub(/[\.\ ]/,"_")}#{rand(3000)}\" MODIFIED=\"#{Time.now.to_i}#{rand(999)}\"  #{parameters.join(" ")}\/>\n")
    end

    def parent_node(options={})
      parameters=[]
      options.each {|option,value|
        parameters.push("#{option.to_s.upcase}=\"#{value}\"")
      }
      self.write("<node CREATED=\"#{Time.now.to_i}#{rand(899)+100}\" ID=\"scenario_#{options[:text].gsub(/[\.\ ]/,"_")}#{rand(3000)}\" MODIFIED=\"#{Time.now.to_i}#{rand(999)}\" #{parameters.join(" ")}>\n")
      yield self
      self.write("</node>")
    end

   end

  File.open_mm("test.mm","w") {|mm|
    mm.write("<!-- generated with the ruby mindmap gem-->\n")
    mm.parent_node(:text=>"test") {|pn|
      pn.parent_node(:text=>"test1.2",:position=>"right") {|ppn|
        ppn.child(:text=>"test1.2.1")
        pn.child(:text=>"test1.2.2")
      }
    }

  }