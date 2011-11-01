# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'csv'
require_relative 'mindmap'
# require_relative 'csv_to_mindmap'

#row_hash={'timestamp'=>"2011-10-31 19:00:38",'sourceip'=>"204.87.86.50",'destip'=>"208.109.181.224",'alertname'=>"Zeus",'sensorname'=>"ok-Albert-1","BYTES"=>"7275 (36)"}
@tree={}
CSV.foreach("./data/2011-10-31-data_export.csv",:headers=>true){|row|
  row_hash=row.to_hash
  #src_tree[row_hash[]][row_hash[]][row_hash[]][row_hash[]]={"bytes"=>{"source"=>0,"destination"=>0},"packets"=>{"source"=>0,"destination"=>0},"startTime"=>{}}
  traverse_tree(@tree,["direction","destination","appName","source","destinationPort",{:sum=>["totalDestinationPackets","totalSourcePackets","totalSourceBytes","totalDestinationBytes"],:append=>["startDateTime"]}],row_hash)
#p traverse_tree(['alertname','sourceip','destip'],row_hash) 
}
p @tree
File.open_mm("output/test.mm","w") {|mm_file|
  mm_file.node(:text=>"alert_row") {|base_node|
    mm_file.enum_to_mm(@tree) 
  }
}

