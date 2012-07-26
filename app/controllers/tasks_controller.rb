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
end
