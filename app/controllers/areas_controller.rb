class AreasController < ApplicationController

  def show

  end

  def gettask
    @task=Task.open.joins(:area=>{:project=>:tasks}).where('areas.id=?', params[:id]).where("projects.id=?", params[:project_id]).limit(1).first
    if @task.nil?
      redirect_to @area.project, notice: 'No task available for you in this project. Thanks for your participation'
    else
      redirect_to project_area_task_path(@task.area.project, @task.area, @task)
    end
  end

  def next
    project=Project.find(params[:project_id])
    area=project.areas.not_annotated_by(current_user).where('areas.id>?', params[:id]).limit(1)
    if (area.nil?)
      redirect_to project, notice: 'No task available for you in this project. Thanks for your participation'
    else
      redirect_to getttask_project_area_path(project, area)
    end
  end


end