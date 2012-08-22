class TasksController < ApplicationController

  def index
    @tasks = App.find(params[:app_id]).tasks
    render :json=>@tasks
  end

  # POST /tasks.json
  def create
    data  = ActiveSupport::JSON.decode(params[:data])
    app   = App.find(params[:app_id])
    @task = app.add_task(data)
    format.json { render json: task, status: :created, location: @task }
  end

  def show
    app=App.find(params[:app_id])
    task=app.tasks.where(:input_task_id => params[:id])
    render :json =>  task.to_json, :callback => params[:callback]
  end

  def next
    context = { :from_task => params[:from_task], 
                :current_user => current_or_guest_username}
    task = App.find(params[:app_id]).next_task(context)
    if task.nil?
      render :json => {:error => "no task found"}, :status => 404 
    else
      redirect_to (app_task_url(task.app,task))
    end
  end

end
