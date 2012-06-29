class AnswersController < ApplicationController

  respond_to :json

  # GET /answers/new
  # GET /answers/new.json
  def new
    respond_with(Answer.new)
  end

  # POST /answers
  # POST /answers.json
  def create
    fill_answer(Answer.new)
  end

# PUT /answers/1
# PUT /answers/1.json
  def update
    fill_answer(Answer.find(params[:id]))
  end

  def show
    answer=Answer.find(params[:id])
    task=answer.task
    p task
    app=task.app
    p app
    render :json => {:submit_url => app_task_answer_url(app, task, answer),
                     :task => task,
                     :ft_task_column => app.task_column,
                     :editable => true} #!(@task.done_by?(current_or_guest_username))

  end

# DELETE /answers/1
# DELETE /answers/1.json
  def destroy
    @answer = Answer.find(params[:id])
    @answer.destroy
    respond_with(:location => answers_url)
  end

  protected

  def fill_answer(answer)
    answer.task=Task.find(params[:task_id])
    answer.user=current_or_guest_user
    answer.state=Answer::COMPLETED
    answer.input_from_form(params[:task_answer])
    answer.ft_sync=false

    if answer.save
      FtSyncAnswers.perform_async() if (params[:sync]=="1")
      flash[:success] = 'Answer was successfully created.'
      respond_with(answer, location: answer_url(answer))
    else
      respond_with(answer.errors, :status => :unprocessable_entity, :location => nil)
    end
  end
end

