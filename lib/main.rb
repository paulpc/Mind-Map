# To change this template, choose Tools | Templates
# and open the template in the editor.
require_relative 'mindmap'
require_relative 'csv_to_mindmap'

test_hash={"one"=>{"one.one"=>"one.one.one","one.two"=>"one.two.one"},"two"=>["two.one","two.one","two.one"],"three"=>"three"}

File.open_mm("test.mm","w") {|mm_file|
  mm_file.node(:text=>"Base node goes here") {|base_node|
    mm_file.enum_to_mm(test_hash) 
  }
}

