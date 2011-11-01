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
p app_count
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
