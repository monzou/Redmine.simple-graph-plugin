module SimpleGraphsHelper

  require "fusioncharts_helper"
  
  include ApplicationHelper
  include FusionChartsHelper
  
  def get_closed_ratio_graph_data
    sorted_keys = @by_date_issues.keys.sort
    summary = SortedHash.new
    prev = nil
    k = controller.start_date
    until k > controller.end_date
      key = controller.to_date_string(k)
      summary[key] = Issues.new(prev, get_size(@by_date_issues[key]), get_size(@by_date_closed_issues[key]))
      prev = summary[key]
      k = k.succ
    end
    apply_past(summary)
    summary
  end
  
  def get_tracker_ratio_graph_data
    sort_hash_by_values(@by_tracker)
  end
  
  def get_category_ratio_graph_data
    sort_hash_by_values(@by_category)
  end
  
  def get_version_graph_data
    h = sort_hash_by_values(@by_version)
    truncate(h, 10, 0.9)
  end
  
  def get_assign_graph_data
    h = sort_hash_by_values(@by_assign)
    truncate(h, 20, 0.9)
  end
  
  def truncate(hash, pos, percentile)
    size = hash.size
    unless (size < pos)
      max = (size * percentile).to_i
      result = SortedHash.new
      counter = 0
      others = 0
      hash.each do |k, v|
        if (counter >= max)
          others += v
        else
          result[k] = v
        end
        counter += 1
      end
      result['Others'] = others
      return result
    end
    hash
  end
  
  def sort_hash_by_values(hash)
    ary = hash.to_a.sort do |a, b|
      (b[1] <=> a[1]) * 2 + (a[0] <=> b[0])
    end
    hash = SortedHash.new
    ary.each do |v|
      hash[v[0]] = v[1]
    end
    hash
  end
      

  def apply_past(summary)
    
    past_total = 0
    @by_date_past_issues.each do |k, v|
      past_total += v
    end
    summary.values.first.increment_total(past_total)
    
    @by_date_past_closed.each do |k, v|
      issues = summary[k] ? summary[k] : summary.values.first
      issues.increment_closed(v) if issues
    end

  end
  
  class Issues
    
    def initialize(prev, total, closed)
      @prev = prev
      @total = total
      @closed = closed
    end
    
    def increment_total(v=1)
      @total += v
    end
    
    def increment_closed(v=1)
      @closed += v
    end
    
    def get_total
      count(0, :total)
    end

    def get_closed
      count(0, :closed)
    end

    def get_closed_ratio
      (get_closed.to_f / get_total.to_f) * 100.0
    end

    def count(counter, key)
      counter += key == :total ? @total : @closed
      if (@prev.nil?)
        counter
      else
        @prev.count(counter, key)
      end
    end

  end
  
  # this is a partial SortedHash implementation.
  class SortedHash < Hash
    
    attr_accessor :keys
    
  	def initialize
  		@keys = Array.new
  	end
  	
  	def []=(k, v)
  		super(k, v)
  		unless @keys.include?(k)
  			@keys << k
  		end
  	end
  	
  	def clear
  		@keys.clear
  		super
  	end
  	
  	def delete(k)
  		if @keys.include?(k)
  			@keys.delete(k)
  			super(k)
  		else
  			yield(k)
  		end
  	end
  	
  	def keys
  	  @keys
  	end
  	
  	def values
  	  values = []
  	  @keys.each do |k|
  	    values << self[k]
  	  end
  	  values
	  end
  	
  	def each
  		@keys.each do |k|
  			arr = Array.new
  			arr << k
  			arr << self[k]
  			yield(arr)
  		end
  		return self
  	end
  	
  	def each_pair
  		@keys.each do |k|
  			yield(k, self[k])
  		end
  		return self
  	end
  	
  end
  
  private
  
    def get_size(ary)
      ary ? ary.length : 0
    end
  
end