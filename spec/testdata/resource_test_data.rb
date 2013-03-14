class ResourceTestData
  
  def self.resources
      {'cars' => [],
       'trucks' => 
      [{'id' =>'4db0dedb387f7123c9000001',"size"=>"big", "colour"=>"green", "wheels"=>4},
         {'id'=>'4db0dedb387f7123c9000002',"size"=>"small", "colour"=>"red", "wheels"=>4, "_koda_title"=>"4 wheeled truck"},
         {'id'=>'4db0dedb387f7123c9000008',"alias" => "smallblueone","size"=>"small", "colour"=>"blue", "wheels"=>4}],         
       'iguanas' => []}
  end
end