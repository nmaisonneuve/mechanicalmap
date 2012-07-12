class AnswersController < ApplicationController

  def show
    answer=Answer.find(params[:id])
    task=answer.task
    app=task.app
    render :json => {:submit_url => app_task_answer_url(app, task, answer),
                     :task => task,
                     :ft_task_column => app.task_column,
                     :editable => true} , :callback => params[:callback] #!(@task.done_by?(current_or_guest_username))
  end

  def update
    answer=Answer.find(params[:id] || params[:answer_id]) #put + get 
    answer.task=Task.find(params[:task_id])
    answer.user=current_or_guest_user
    answer.state=Answer::COMPLETED
    answer.input_from_form(params[:answer])
    answer.ft_sync=false
    if answer.save
      FtSyncAnswers.perform_async()
      flash[:success] = 'Answer was successfully created.'
      render :json => answer.to_json, :callback => params[:callback]
    else
      render :json => {:error => answer.errors}, :status => :unprocessable_entity, :location => nil
    end
  end


end

