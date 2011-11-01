# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'csv'
require_relative 'mindmap'
filename="./data/2011-10-28-data_export.csv"
# analyze flows for patterns. Scan for:
# > zero destination bytes - traffic stopped by firewall
# > zero source bytes - traffiv stopped by firewall
# > constant flow data for bruteforce attacks

# aggregate flow information:
# > traffic per source and destination IP
# > traffic per application
# > traffic per port
ips_count={}
app_count={}
port_count={}
CSV.foreach(filename,:headers=>true){|row|
  row_hash=row.to_hash
  traverse_tree(ips_count,["source",{:count=>["magnitude"]}],row_hash)
  traverse_tree(ips_count,["destination",{:count=>["magnitude"]}],row_hash)
  traverse_tree(app_count,["appName",{:count=>["magnitude"]}],row_hash)
  traverse_tree(port_count,["destinationPort",{:count=>["magnitude"]}],row_hash)
}

top_ips_val=[]
ips_count.values.each {|magnitude_hash|
  magnitude_hash.each {|magnitude,value|
    top_ips_val+=[value]
    top_ips_val=top_ips_val.sort.reverse[0,10] if top_ips_val.length>10
  }
}
top_app_val=[]
app_count.values.each {|magnitude_hash|
  magnitude_hash.each {|magnitude,value|
    top_app_val+=[value]
    top_app_val=top_app_val.sort.reverse[0,10] if top_app_val.length>10
  }
}

top_port_val=[]
port_count.values.each {|magnitude_hash|
  magnitude_hash.each {|magnitude,value|
    top_port_val+=[value]
    top_port_val=top_port_val.sort.reverse[0,10] if top_port_val.length>10
  }
}

top_ips={}
ips_count.each {|ip,magnitude_hash|
  top_ips[ip]=magnitude_hash["magnitude"] if top_ips_val.include?(magnitude_hash["magnitude"])
}

top_apps={}
app_count.each {|app,magnitude_hash|
  top_apps[app]=magnitude_hash["magnitude"] if top_app_val.include?(magnitude_hash["magnitude"])
}

top_ports={}
port_count.each {|port,magnitude_hash|
  top_ports[port]=magnitude_hash["magnitude"] if top_port_val.include?(magnitude_hash["magnitude"])
}



dst_app_tree={}
src_app_tree={}
app_tree={}

CSV.foreach(filename,:headers=>true){|row|
  row_hash=row.to_hash
  #src_tree[row_hash[]][row_hash[]][row_hash[]][row_hash[]]={"bytes"=>{"source"=>0,"destination"=>0},"packets"=>{"source"=>0,"destination"=>0},"startTime"=>{}}
  traverse_tree(dst_app_tree,["direction","destination","appName","source","destinationPort",{:sum=>["totalDestinationPackets","totalSourcePackets","totalSourceBytes","totalDestinationBytes"],:min=>["startDateTime"]}],row_hash)
  traverse_tree(src_app_tree,["direction","source","appName","destination","destinationPort",{:sum=>["totalDestinationPackets","totalSourcePackets","totalSourceBytes","totalDestinationBytes"],:min=>["startDateTime"]}],row_hash)
  traverse_tree(app_tree,["direction","appName","source","destination","destinationPort",{:sum=>["totalDestinationPackets","totalSourcePackets","totalSourceBytes","totalDestinationBytes"],:max=>["startDateTime"]}],row_hash)
#p traverse_tree(['alertname','sourceip','destip'],row_hash) 
}

File.open_mm("output/#{filename.scan(/\d+\-\d+\-\d+/).flatten.first}-dest_app.mm","w") {|mm_file|
  mm_file.node(:text=>"Destination - Application") {|base_node|
    mm_file.enum_to_mm(dst_app_tree) 
  }
}

File.open_mm("output/#{filename.scan(/\d+\-\d+\-\d+/).flatten.first}-src_app.mm","w") {|mm_file|
  mm_file.node(:text=>"Source - Application") {|base_node|
    mm_file.enum_to_mm(src_app_tree) 
  }
}

File.open_mm("output/#{filename.scan(/\d+\-\d+\-\d+/).flatten.first}-app.mm","w") {|mm_file|
  mm_file.node(:text=>"Application") {|base_node|
    mm_file.enum_to_mm(app_tree) 
  }
}
