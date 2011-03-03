Redmine simple graph plugin
=====

This is a simple graph plugin for Redmine.
This plugin visualize project status with following graphs.

- Issue Closed Ratio Chart: visualize closed/total ratio with time series (past 14 days). 
- Tracker Pie Chart: visualize issue ratio (on today).
- Category Pie Chart: visualize category ratio (on today).
- Version Bar Chart: visualize top 90% versions (on today).
- Assign Bar Chart: visualize top 90% assigned users (on today).

each graphs are described by selected query.


Requirements
-----

- Redmine 0.9.x or later.


Setup
-----

1. download Fusion Charts v3. (http://www.fusioncharts.com/)
2. extract FusionCharts.
3. copy FusionCharts/Code/RoR/Libraries/* to redmine_simple_graphs/lib
4. copy FusionCharts/Code/FusionCharts/FusionCharts.js to redmine_simple_graphs/assets/javascripts
5. mkdir redmine_simple_graphs/assets/FusionCharts
6. copy FusionCharts/Charts/Bar2D.swf, MSColumn3DLineDY.swf, Pie3D.swf to redmine_simple_graphs/assets/FusionCharts
7. copy redmine_simple_graphs to redmine/vendor/plugins
8. restart Redmine.
 

Other
-----

if you get garbled, add following patch to redmine/config/enviroment.rb.
I think Japanese Users needs to apply this patch.
 
  class String
    def to_xs
      ERB::Util.h(unpack('U*').pack('U*')).gsub("'", '&apos;')
    rescue
      unpack('C*').map {|n| n.xchr}.join
    end
  end