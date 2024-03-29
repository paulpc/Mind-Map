require 'csv'
require_relative 'mindmap'

# building the array based on the source IP in the form of: 
# source >> destinationIP >> appName >> port >> bytes >> source | destination | total
	#										>> packets >> source | destination | total
#											>> start_time >>

src_tree={}
src_app_tree={}
dst_app_tree={}
app_tree={}
top_total_traffic={}

CSV.foreach("./data/2011-10-31-data_export.csv",:headers=>true){|row|
row_hash=row.to_hash
# by source IP
src_tree[row_hash["source"]]={} unless src_tree[row_hash["source"]]
src_tree[row_hash["source"]][row_hash["destination"]]={} unless src_tree[row_hash["source"]][row_hash["destination"]]
src_tree[row_hash["source"]][row_hash["destination"]][row_hash["appName"]]={} unless src_tree[row_hash["source"]][row_hash["destination"]][row_hash["appName"]]
src_tree[row_hash["source"]][row_hash["destination"]][row_hash["appName"]][row_hash["destinationPort"]]={"bytes"=>{"source"=>0,"destination"=>0},"packets"=>{"source"=>0,"destination"=>0},"startTime"=>{}} unless src_tree[row_hash["source"]][row_hash["destination"]][row_hash["appName"]][row_hash["destinationPort"]]
src_tree[row_hash["source"]][row_hash["destination"]][row_hash["appName"]][row_hash["destinationPort"]]={"bytes"=>{
"source"=>src_tree[row_hash["source"]][row_hash["destination"]][row_hash["appName"]][row_hash["destinationPort"]]["bytes"]["source"].to_i+row_hash["totalSourceBytes"].to_i,
"destination"=>src_tree[row_hash["source"]][row_hash["destination"]][row_hash["appName"]][row_hash["destinationPort"]]["bytes"]["destination"].to_i+row_hash["totalDestinationBytes"].to_i},
"packets"=>{"source"=>src_tree[row_hash["source"]][row_hash["destination"]][row_hash["appName"]][row_hash["destinationPort"]]["packets"]["source"].to_i+row_hash["totalSourcePackets"].to_i,
"destination"=>src_tree[row_hash["source"]][row_hash["destination"]][row_hash["appName"]][row_hash["destinationPort"]]["packets"]["destination"].to_i+row_hash["totalDestinationPackets"].to_i},
"startTime"=>{row_hash["startTime"]=>(Time.at((Float(row_hash["startTime"])/1000).to_i))}}

# application > source > destinationPort > destination
app_tree[row_hash["appName"]]={} unless app_tree[row_hash["appName"]]
app_tree[row_hash["appName"]][row_hash["source"]]={} unless app_tree[row_hash["appName"]][row_hash["source"]]
app_tree[row_hash["appName"]][row_hash["source"]][row_hash["destinationPort"]]={} unless app_tree[row_hash["appName"]][row_hash["source"]][row_hash["destinationPort"]]
app_tree[row_hash["appName"]][row_hash["source"]][row_hash["destinationPort"]][row_hash["destination"]]={"bytes"=>{"source"=>0,"destination"=>0},"packets"=>{"source"=>0,"destination"=>0},"startTime"=>{}} unless app_tree[row_hash["appName"]][row_hash["source"]][row_hash["destinationPort"]][row_hash["destination"]]

app_tree[row_hash["appName"]][row_hash["source"]][row_hash["destinationPort"]][row_hash["destination"]]={"bytes"=>{
"source"=>app_tree[row_hash["appName"]][row_hash["source"]][row_hash["destinationPort"]][row_hash["destination"]]["bytes"]["source"].to_i+row_hash["totalSourceBytes"].to_i,
"destination"=>app_tree[row_hash["appName"]][row_hash["source"]][row_hash["destinationPort"]][row_hash["destination"]]["bytes"]["destination"].to_i+row_hash["totalDestinationBytes"].to_i},
"packets"=>{"source"=>app_tree[row_hash["appName"]][row_hash["source"]][row_hash["destinationPort"]][row_hash["destination"]]["packets"]["source"].to_i+row_hash["totalSourcePackets"].to_i,
"destination"=>app_tree[row_hash["appName"]][row_hash["source"]][row_hash["destinationPort"]][row_hash["destination"]]["packets"]["destination"].to_i+row_hash["totalDestinationPackets"].to_i},
"startTime"=>{row_hash["startTime"]=>(Time.at((Float(row_hash["startTime"])/1000).to_i))}}
# we might revert to this need be: "startTime"=>{row_hash["startTime"]=>(Time.at(row_hash["startTime"][0..-4].to_i))}}

# by source IP>application>destination>port
top_total_traffic[row["source"]]=top_total_traffic[row["source"]].to_i+(row_hash["totalSourceBytes"].to_i+row_hash["totalDestinationBytes"].to_i)
top_total_traffic[row["destination"]]=top_total_traffic[row["destination"]].to_i+(row_hash["totalSourceBytes"].to_i+row_hash["totalDestinationBytes"].to_i)
src_app_tree[row_hash["direction"]]={} unless src_app_tree[row_hash["direction"]]
src_app_tree[row_hash["direction"]][row_hash["source"]]={} unless src_app_tree[row_hash["direction"]][row_hash["source"]]
src_app_tree[row_hash["direction"]][row_hash["source"]][row_hash["appName"]]={} unless src_app_tree[row_hash["direction"]][row_hash["source"]][row_hash["appName"]]
src_app_tree[row_hash["direction"]][row_hash["source"]][row_hash["appName"]][row_hash["destination"]]={} unless src_app_tree[row_hash["direction"]][row_hash["source"]][row_hash["appName"]][row_hash["destination"]]
src_app_tree[row_hash["direction"]][row_hash["source"]][row_hash["appName"]][row_hash["destination"]][row_hash["destinationPort"]]={"bytes"=>{"source"=>0,"destination"=>0},"packets"=>{"source"=>0,"destination"=>0},"startTime"=>{}} unless src_app_tree[row_hash["direction"]][row_hash["source"]][row_hash["appName"]][row_hash["destination"]][row_hash["destinationPort"]]
src_app_tree[row_hash["direction"]][row_hash["source"]][row_hash["appName"]][row_hash["destination"]][row_hash["destinationPort"]]={"bytes"=>{
"source"=>src_app_tree[row_hash["direction"]][row_hash["source"]][row_hash["appName"]][row_hash["destination"]][row_hash["destinationPort"]]["bytes"]["source"].to_i+row_hash["totalSourceBytes"].to_i,
"destination"=>src_app_tree[row_hash["direction"]][row_hash["source"]][row_hash["appName"]][row_hash["destination"]][row_hash["destinationPort"]]["bytes"]["destination"].to_i+row_hash["totalDestinationBytes"].to_i},
"packets"=>{"source"=>src_app_tree[row_hash["direction"]][row_hash["source"]][row_hash["appName"]][row_hash["destination"]][row_hash["destinationPort"]]["packets"]["source"].to_i+row_hash["totalSourcePackets"].to_i,
"destination"=>src_app_tree[row_hash["direction"]][row_hash["source"]][row_hash["appName"]][row_hash["destination"]][row_hash["destinationPort"]]["packets"]["destination"].to_i+row_hash["totalDestinationPackets"].to_i},
"startTime"=>{row_hash["startTime"]=>(Time.at((Float(row_hash["startTime"])/1000).to_i))}}

# by dest>application>source>port
dst_app_tree[row_hash["direction"]]={} unless dst_app_tree[row_hash["direction"]]
dst_app_tree[row_hash["direction"]][row_hash["destination"]]={} unless dst_app_tree[row_hash["direction"]][row_hash["destination"]]
dst_app_tree[row_hash["direction"]][row_hash["destination"]][row_hash["appName"]]={} unless dst_app_tree[row_hash["direction"]][row_hash["destination"]][row_hash["appName"]]
dst_app_tree[row_hash["direction"]][row_hash["destination"]][row_hash["appName"]][row_hash["source"]]={} unless dst_app_tree[row_hash["direction"]][row_hash["destination"]][row_hash["appName"]][row_hash["source"]]
dst_app_tree[row_hash["direction"]][row_hash["destination"]][row_hash["appName"]][row_hash["source"]][row_hash["destinationPort"]]={"bytes"=>{"source"=>0,"destination"=>0},"packets"=>{"source"=>0,"destination"=>0},"startTime"=>{}} unless dst_app_tree[row_hash["direction"]][row_hash["destination"]][row_hash["appName"]][row_hash["source"]][row_hash["destinationPort"]]
dst_app_tree[row_hash["direction"]][row_hash["destination"]][row_hash["appName"]][row_hash["source"]][row_hash["destinationPort"]]={"bytes"=>{
"source"=>dst_app_tree[row_hash["direction"]][row_hash["destination"]][row_hash["appName"]][row_hash["source"]][row_hash["destinationPort"]]["bytes"]["source"].to_i+row_hash["totalSourceBytes"].to_i,
"destination"=>dst_app_tree[row_hash["direction"]][row_hash["destination"]][row_hash["appName"]][row_hash["source"]][row_hash["destinationPort"]]["bytes"]["destination"].to_i+row_hash["totalDestinationBytes"].to_i},
"packets"=>{"source"=>dst_app_tree[row_hash["direction"]][row_hash["destination"]][row_hash["appName"]][row_hash["source"]][row_hash["destinationPort"]]["packets"]["source"].to_i+row_hash["totalSourcePackets"].to_i,
"destination"=>dst_app_tree[row_hash["direction"]][row_hash["destination"]][row_hash["appName"]][row_hash["source"]][row_hash["destinationPort"]]["packets"]["destination"].to_i+row_hash["totalDestinationPackets"].to_i},
"startTime"=>{row_hash["startTime"]=>(Time.at((Float(row_hash["startTime"])/1000).to_i))}}
}

$cloud_color={}
top_values_arry=top_total_traffic.values.sort[-10,10]
#color_coef=(top_values_arry.last-top_values_arry.first)/65535
#p top_values_arry.first
#p top_values_arry.last
# going from 255,0,0 to 255,255,0 - 255 values / 10 => stepping by 51
#available_colors:

top_total_traffic.each {|ip,value|
if top_values_arry.include?(value)
#$cloud_color[ip]="##{((value-top_values_arry.first)/color_coef).to_s(16).rjust(4,"0")}22"
$cloud_color[ip]="#ff#{(255-(top_values_arry.index(value))*25).to_s(16).rjust(2,'0')}22"
#p (value)/color_coef
p value, $cloud_color[ip]
end
}


# adding source tree:
$spaces=0
File.open_mm("./output/source_nodes.mm","w") {|mm|
	mm.node(:text=>"Source IP Tree") {|src_tree_node|
		position="right"
		src_tree.each {|src_ip,src_ip_tree|
			if position == "right"
				position="left"
			else
				position="right"
			end
			src_tree_node.node(:text=>src_ip,:folded=>"true",:position=>position) {|src_ip_node|
				src_ip_tree.each {|dst_ip,dst_ip_tree|
					src_ip_node.node(:text=>dst_ip, :folded=>"true") {|dst_ip_node|
						dst_ip_tree.each {|app_name,app_name_tree|
							dst_ip_node.node(:text=>app_name,:folded=>"true") {|app_name_node|
								app_name_tree.each {|port,port_tree|
									app_name_node.node(:text=>port,:folded=>"true") {|port_node|
										port_tree.each {|attribute,attribute_tree|
											port_node.node(:text=>attribute.to_s){|attribute_node|
												attribute_tree.each {|name,value|
													attribute_node.node(:text=>name) {|name_node|
														name_node.node(:text=>value)
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
$spaces=0
# adding source tree: app_tree[row_hash["appName"]][row_hash["source"]][row_hash["destinationPort"]][row_hash["destination"]]
File.open_mm("./output/applications.mm","w") {|mm|
	mm.node(:text=>"Application Tree") {|app_tree_node|
		position="right"
		app_tree.each {|app_name,app_name_tree|
			if position=="right"
				position="left"
			else
				position="right"
			end
			app_tree_node.node(:text=>app_name,:folded=>"true",:position=>position) {|app_name_node|
				app_name_tree.each {|src_ip,src_ip_tree|
					app_name_node.node(:text=>src_ip, :folded=>"true") {|src_ip_node|
						src_ip_tree.each {|port,port_tree|
							src_ip_node.node(:text=>port) {|port_node|
								port_tree.each {|dst_ip,dst_ip_tree|
									port_node.node(:text=>dst_ip,:folded=>"true") {|dst_ip_node|
										dst_ip_tree.each {|attribute,attribute_tree|
											dst_ip_node.node(:text=>attribute.to_s){|attribute_node|
												attribute_tree.each {|name,value|
													attribute_node.node(:text=>name) {|name_node|
														name_node.node(:text=>value)
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

File.open_mm("./output/source_application.mm","w") {|mm|
	mm.node(:text=>"Source application Tree") {|dir_node|
		mm.enum_to_mm(src_app_tree) 
  }
}

File.open_mm("./output/destination_application.mm","w") {|mm|
	mm.node(:text=>"Destination application Tree") {|dir_node|
		mm.enum_to_mm(dst_app_tree) 
  }
}