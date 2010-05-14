class ProjectPlanningGraph

  include PlanningHelper
  
  attr_reader :period, :project, :overview_graph, :employees, :plannings
  
  def initialize(project, period = nil)
    @project = project
    period ||= Period.currentMonth
    @period = extend_to_weeks period
    @cache = Hash.new
    @plannings = Planning.all(:conditions => ['project_id = ? and start_week <= ?', @project.id, Week::from_date(period.endDate).to_integer] )
    @employees = @plannings.select{|planning| planning.planned_during?(@period)}.collect{|planning| planning.employee }.uniq.sort
    @overview_graph = ProjectOverviewPlanningGraph.new(@project, @plannings, @period)
  end

end