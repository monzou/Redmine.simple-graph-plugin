xml = Builder::XmlMarkup.new
xml.chart(:caption => caption, :canvasBgColor => 'FFFFDD', :bgColor => 'B8D288,FFFFFF', :bgAngle => '90', :numDivLines => '9', :plotBorderColor => '3B242', :canvasBorderColor => '83B242', :canvasBorderThickness => '1') do
  hash_data.each do |k, v|
    xml.set(:label => k, :value => v, :color => '83B242,B8D288')
  end
end