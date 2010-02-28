xml = Builder::XmlMarkup.new
xml.chart(:palette=>'4', :caption=>'Issue Closed Ratio', :xAxisName => 'Date', :PYAxisName => 'Issues', :SYAxisName => 'Closed Ratio (%)', :SYAxisMaxValue => 100, :formatNumberScale=>'0', :showValues=>'0', :decimals=>'0') do
  xml.categories do
		hash_data.keys.each do |k|
			xml.category(:name => k.slice(5, 9))
		end
	end
  xml.dataset(:seriesName => 'Closed', :color => 'AFD8F8') do
		hash_data.values.each do |v|
			xml.set(:value => v.get_closed)
		end
	end
  xml.dataset(:seriesName => 'Total', :color => 'F6BD0F') do
		hash_data.values.each do |v|
			xml.set(:value => v.get_total)
		end
	end
  xml.dataset(:seriesName=>'Closed Ratio', :parentYAxis=>'S', :color => '8BBA00', :renderAs => 'Line') do
		hash_data.values.each do |v|
			xml.set(:value => v.get_closed_ratio)
		end
	end
	xml.styles do
	  xml.definition do
	    xml.style(:name => 'LineShadow', :type => 'shadow', :color => '333333', :distance => 6)
	  end
	  xml.application do
	    xml.apply(:toObject => 'DATAPLOT', :styles => 'LineShadow')
	  end
	end
end