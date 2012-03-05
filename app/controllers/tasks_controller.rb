class TasksController < ApplicationController


  def show
    @task=Task.find(params[:id])
    @area=@task.area
    @project=@area.project
  end

  def update
    @task=Task.find(params[:id])
    @task.state=Task::COMPLETED
    if (@task.save)
      redirect_to next_project_area_path(@task.area.project,@task.area)
    else
      redirect_to @task.area.project, notice: 'Sorry, there was an error while saving your annotation'
    end
  end
end