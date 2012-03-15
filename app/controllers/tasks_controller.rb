class TasksController < ApplicationController

  def show
    @task=Task.find(params[:id])
    @area=@task.area
    @project=@area.project
    @completed, @size=@area.completion
    @editable=!(@area.annotated_by?(current_or_guest_user))
    respond_to do |format|
      format.html {}
      format.js {
        json_answer={:id=>@task.id, :submit_url=>project_area_task_url(@project, @area,@task), :area=>@area, :editable=>@editable}
        render :json=> json_answer
      }
      format.json {
        json_answer={:id=>@task.id, :submit_url=>project_area_task_url(@project, @area,@task), :area=>@area, :editable=>@editable}
        render :json=> json_answer
      }
    end

  end

  def update
    @task=Task.find(params[:id])
    @task.user=current_or_guest_user
    @task.state=Task::COMPLETED
    @task.answer=params[:task][:answer]
    if (@task.save)
      project=@task.area.project

      #add user_id
      answer=ActiveSupport::JSON.decode(@task.answer)

     # project.insert()

      redirect_to getjob_project_path(project)


    end


  end

end
