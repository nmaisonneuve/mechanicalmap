class UnitsController < ApplicationController


  # GET /units/1
  # GET /units/1.json
  def show
    @unit = Unit.find(params[:id])
    #render json: @unit
    @task=@unit.task
    @app=@task.app
    @completed, @size=@task.completion
    @editable=!(@unit.done_by?(current_or_guest_user))
    respond_to do |format|
      format.html {}
      format.js {
        json_answer={:id=>@unit.id, :submit_url=>app_task_unit_url(@app, @task, @unit), :task=>@task, :editable=>@editable}
        render :json=> json_answer
      }
    end
  end

  # GET /units/new
  # GET /units/new.json
  def new
    @unit = Unit.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @unit }
    end
  end

  # GET /units/1/edit
  def edit
    @unit = Unit.find(params[:id])
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
    @unit.state=unit::PENDING
    @unit.answer=params[:unit][:answer]


    respond_to do |format|
      if (@unit.save)
        format.html { redirect_to scheduler_app_path(@unit.task.project), notice: 'Unit was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "show" }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
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

