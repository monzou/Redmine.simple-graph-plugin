xml = Builder::XmlMarkup.new
xml.chart(:palette => '2', :caption => caption, :animation => '1', :formatNumberScale => '0', :pieSliceDepth => '30', :startingAngle => '125') do
  hash_data.each do |k, v|
    xml.set(:label => k, :value => v)
  end
end