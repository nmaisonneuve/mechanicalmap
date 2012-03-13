class TasksController < ApplicationController
	before_filter :anonymous_sign_in

  def show

    @task=Task.find(params[:id])
    @area=@task.area
    @project=@area.project
    @completed, @size=@area.completion
    @contributable=!(@area.annotated_by?(current_user))
  end

  def update
    @task=Task.find(params[:id])
    @task.user=current_user
    @task.state=Task::COMPLETED
    @task.answer=params[:task][:answer]
    project=@task.area.project
    project.insert(ActiveSupport::JSON.decode(@task.answer))


    if (@task.save)
      redirect_to next_project_area_path(@task.area.project,@task.area)
    else
      redirect_to @task.area.project, notice: 'Sorry, there was an error while saving your annotation'
    end
  end

end
