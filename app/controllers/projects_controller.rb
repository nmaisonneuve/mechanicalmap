class ProjectsController < ApplicationController
  # GET /projects
  # GET /projects.json

  def index
    @projects = Project.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  def getjob
    context={:from_area=>params[:from_area],:current_user=>current_or_guest_user}
    @task=Project.find(params[:id]).get_area_to_analyze(context)
    if @task.nil?
      redirect_to project_path(params[:id]), notice: 'No task available for you in this project. Thanks for your participation'
    else
    respond_to do |format|
      format.html {redirect_to project_area_task_path(@task.area.project, @task.area, @task)}
      format.json { show_task(@task)}
    end


    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])
    respond_to do |format|
      format.html {
        @available_tasks=@project.areas.not_annotated_by(current_or_guest_user).exists?
      }
      format.js {
        if params[:widget].blank?
          render json: @project,
        else
          render 'widget.js.erb'
        end
      }
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end

  def widget

  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(params[:project])
    @project.pre_processing(current_user)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end

  private

  def show_task(task)
    @task=task
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
end
