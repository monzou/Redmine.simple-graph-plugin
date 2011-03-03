class SimpleGraphsController < ApplicationController
  
  GRAPH_SIZE = 14
  
  unloadable
  
  before_filter :find_project, :only => [:index]
  rescue_from Query::StatementInvalid, :with => :query_statement_invalid
  
  helper :queries
  include QueriesHelper
  helper :issues
  include IssuesHelper
  
  def index
    retrieve_query
    if @query.valid?
      issues = @query.issues(
        :include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
        :conditions => [ "#{Issue.table_name}.created_on >= ?", start_date]
      )
      prepare_for_closed_ratio_graph(issues, start_date)
      prepare_for_detail_graph
    end
    headers["content-type"] = "text/html";
    render(:template => 'simple_graphs/index.html.erb', :layout => !request.xhr?)
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def to_date_string(date)
    date.strftime("%Y/%m/%d")
  end
  
  def to_date(date_string)
    Date.strptime(date_string, '%Y/%m/%d')
  end
  
  def start_date
    end_date - GRAPH_SIZE
  end
  
  def end_date
    Date.today
  end
  
private

  def prepare_for_detail_graph
    count_trackers
    count_categories
    count_versions
    count_assigns
  end
  
  def count_trackers
    count_hash = count_issues("#{Issue.table_name}.tracker_id")
    @by_tracker = to_entity_hash(count_hash, Tracker)
  end
  
  def count_categories
    count_hash = count_issues("#{Issue.table_name}.category_id")
    @by_category = to_entity_hash(count_hash, IssueCategory)
  end
  
  def count_versions
    count_hash = count_issues("#{Issue.table_name}.fixed_version_id")
    @by_version = to_entity_hash(count_hash, Version)
  end
  
  def count_assigns
    count_hash = count_issues("#{Issue.table_name}.assigned_to_id")
    @by_assign = to_entity_hash(count_hash, User)
  end
  
  def to_entity_hash(count_hash, entity_symbol)
    entities = entity_symbol.find(:all, :conditions => [ "#{entity_symbol.table_name}.id in (?)", count_hash.keys ])
    entity_hash = Hash.new
    entities.each do |entity|
      entity_hash[entity.id] = entity
    end
    result = Hash.new
    count_hash.each do |k, v|
      entity = entity_hash[k]
      entity_name = entity.nil? ? "" : entity.name
      result[entity_name] = v
    end
    result
  end
  
  def prepare_for_closed_ratio_graph(issues, start_date)
    grouping_issues(issues)
    count_past_issues(start_date)
  end

  def grouping_issues(issues)
    @by_date_issues = issues.group_by do |issue|
      to_date_string(issue.start_date)
    end
    closed_issues = []
    issues.each do |issue|
      closed_issues << issue if issue.status.is_closed?
    end
    @by_date_closed_issues = closed_issues.group_by do |issue|
      to_date_string(issue.updated_on)
    end
  end

  def count_past_issues(edge)
    @by_date_past_issues = count_issues("#{Issue.table_name}.start_date", [ "#{Issue.table_name}.created_on < ?", edge ])
    @by_date_past_closed = count_issues("date_format(#{Issue.table_name}.updated_on, '%Y/%m/%d')", [ "#{Issue.table_name}.created_on < ? and #{IssueStatus.table_name}.is_closed = ?", edge, 1 ])
  end

  def count_issues(grouping_key, conditions=nil)
    Issue.count(:include => [:status, :project], :group => grouping_key, :conditions => Query.merge_conditions(@query.statement, conditions))
  end
    
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
    
  def retrieve_query
    if !params[:query_id].blank?
      condition = "project_id is null"
      condition << " or project_id = #{@project.id}" if @project
      @query = Query.find(params[:query_id], :conditions => condition)
      @query.project = @project
      session[:query] = {:id => @query.id, :project_id => @query.project_id}
    else
      if params[:set_filter] || session[:query].nil? || session[:query][:project_id] != (@project ? @project.id : nil)
        @query = Query.new(:name => "_")
        @query.project = @project
        if params[:fields] and params[:fields].is_a? Array
          params[:fields].each do |field|
            @query.add_filter(field, params[:operators][field], params[:values][field])
          end
        else
          @query.available_filters.keys.each do |field|
            @query.add_short_filter(field, params[field]) if params[field]
          end
        end
        session[:query] = {:project_id => @query.project_id, :filters => @query.filters}
      else
        @query = Query.find_by_id(session[:query][:id]) if session[:query][:id]
        @query ||= Query.new(:name => "_", :project => @project, :filters => session[:query][:filters])
        @query.project = @project
      end
    end
  end

  def query_statement_invalid(exception)
    logger.error "Query::StatementInvalid: #{exception.message}" if logger
    session.delete(:query)
    render_error "An error occurred while executing the query and has been logged. Please report this error to your Redmine administrator."
  end

end
