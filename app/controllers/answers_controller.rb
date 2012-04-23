class AnswersController < ApplicationController


  # GET /answers/new
  # GET /answers/new.json
  def new
    @answer = Answer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @answer }
    end
  end

  # POST /answers
  # POST /answers.json
  def create
    @answer = Answer.new
    @answer.task=Task.find(params[:task_id])
    @answer.save
    respond_to do |format|
      if @answer.save
        format.html { redirect_to @answer, notice: 'Unit was successfully created.' }
        format.json { render json: @answer, status: :created, location: @answer }
      else
        format.html { render action: "new" }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /answers/1
  # PUT /answers/1.json
  def update

    @answer=Answer.find(params[:id])
    @answer.user=current_or_guest_user
    @answer.state=Answer::COMPLETED
    answer=ActiveSupport::JSON.decode(params[:task_answer])
    answer.each { |row|
      row["task_id"]=@answer.task.id if row["task_id"].blank?
      row["user_id"]=@answer.user.id if row["user_id"].blank?
      row["created_at"]=Time.now if row["created_at"].blank?
    }
    @answer.answer=answer
    @answer.ft_sync=false

    if (params[:sync]=="1")
      FtDao.instance.sync_answers([@answer])
    end

    respond_to do |format|
      if (@answer.save)
        format.html { redirect_to workflow_app_path(@answer.task.app), notice: 'Unit was successfully updated.' }
        format.json { render json: @answer }
      else
        format.html { render action: "show" }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
    end
  end

  def show

    #render json: @unit
    @answer=Answer.find(params[:id])
    @task=@answer.task
    @app=@task.app
    @completed, @size=@task.completion
    @editable=true #!(@task.done_by?(current_or_guest_username))
    respond_to do |format|
      format.html {}
      format.js {
        json_answer={:submit_url => app_task_unit_url(@app, @task, @answer), :task => @task, :editable => @editable}
        render :json => json_answer
      }
    end
  end

  # DELETE /answers/1
  # DELETE /answers/1.json
  def destroy
    @answer = Answer.find(params[:id])
    @answer.destroy

    respond_to do |format|
      format.html { redirect_to answers_url }
      format.json { head :no_content }
    end
  end
end

