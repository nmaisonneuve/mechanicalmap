class TasksController < ApplicationController

  def index
    @tasks=App.find(params[:app_id]).tasks
    render :json=>@tasks
  end

end
