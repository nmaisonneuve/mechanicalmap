class UnitsController < ApplicationController


  # GET /units/new
  # GET /units/new.json
  def new
    @unit = Unit.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @unit }
    end
  end

  # POST /units
  # POST /units.json
  def create
    @unit = Unit.new
    @unit.task=Task.find(params[:task_id])
    @unit.save
    respond_to do |format|
      if @unit.save
        format.html { redirect_to @unit, notice: 'Unit was successfully created.' }
        format.json { render json: @unit, status: :created, location: @unit }
      else
        format.html { render action: "new" }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /units/1
  # PUT /units/1.json
  def update

    @unit=Unit.find(params[:id])
    @unit.user=current_or_guest_user
    @unit.state=Unit::COMPLETED
    @unit.ft_sync=FALSE
    @unit.answer=params[:task_answer]

    respond_to do |format|
      if (@unit.save)
        format.html { redirect_to workflow_app_path(@unit.task.app), notice: 'Unit was successfully updated.' }
        format.json { render :json=>"", status: :success }
      else
        format.html { render action: "show" }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  def show

    #render json: @unit
    @unit=Unit.find(params[:id])
    @task=@unit.task
    @app=@task.app
    @completed, @size=@task.completion
    @editable=!(@task.done_by?(current_or_guest_user))
    respond_to do |format|
      format.html {}
      format.js {
        json_answer={:submit_url=>app_task_unit_url(@app, @task, @unit), :task=>@task, :editable=>@editable}
        render :json=> json_answer
      }
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @unit = Unit.find(params[:id])
    @unit.destroy

    respond_to do |format|
      format.html { redirect_to units_url }
      format.json { head :no_content }
    end
  end
end

