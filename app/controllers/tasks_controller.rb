class TasksController < ApplicationController

  def index
    @tasks=App.find(params[:app_id]).tasks
    render :json=>@tasks
  end


  def show

    #render json: @unit
    @task=Task.find(params[:task_id])
    @app=@task.app
    @completed, @size=@task.completion
    @editable=!(@task.done_by?(current_or_guest_user))
    respond_to do |format|
      format.html {}
      format.js {
        json_answer={:submit_url=>app_task_url(@app, @task), :task=>@task, :editable=>@editable}
        render :json=> json_answer
      }
    end
  end



  def getjob
    @task=Task.open.joins(:area=>{:project=>:units}).where('areas.id=?', params[:id]).where("projects.id=?", params[:project_id]).limit(1).first
    if @task.nil?
      redirect_to project_path(params[:project_id]), notice: 'No task available for you in this project. Thanks for your participation'
    else
      redirect_to project_area_task_path(@task.area.project, @task.area, @task)
    end
  end

end
