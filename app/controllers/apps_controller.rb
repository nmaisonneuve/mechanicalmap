class AppsController < ApplicationController

  before_filter :authenticate_user!, :only=>[:new]
  # GET /apps
  # GET /apps.json
  def index
    @apps = App.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @apps }
    end
  end

  def show
    @app = App.find(params[:id])
    if (params[:embeddable].blank?)
      render 'show.erb.html'
    else
      render 'embeddable.erb.html', :layout=>false
      #render 'debug.erb.html', :layout=>false
    end
  end


  def new
    @app = App.new
    @app.input_ft=params[:input_ft] unless params[:input_ft].blank?
    @app.output_ft=params[:output_ft] unless params[:output_ft].blank?
  end

  def user_state
    app=App.find(params[:id])
    # strange but working
    opened=app.tasks.not_done_by_username(current_or_guest_username).count
    completed=app.tasks.done_by_username(current_or_guest_username).count
    render json: {:opened=>opened, :completed=>completed}
  end

  def workflow
    app=App.find(params[:id])
    context={:from_task=>params[:from_task], :current_user=>current_or_guest_username}
    task_unit=app.schedule(context)
    if task_unit.nil?
      respond_to do |format|
        format.html { redirect_to app_path(app), notice: 'Sorry no further task available!' }
        format.js { render :json=>"", :status => 404 }
      end
    else
      redirect_to app_task_unit_path(task_unit.task.app, task_unit.task, task_unit, :format=>params[:format])
    end
  end


# GET /apps/1/edit
  def edit
    @app = App.find(params[:id])
    if current_user!=@app.user
      redirect_to root_url
    else

    end
  end


# POST /apps
# POST /apps.json
  def create

    @app = App.create(params[:app])
    @app.user=current_user
    respond_to do |format|
      if @app.save
        @app.ft_index_tasks(params[:app_redundancy].to_i)
        @app.ft_create_output(params[:schema], current_user.email)


        format.html { redirect_to @app, notice: 'app was successfully created.' }
        format.json { render json: @app, status: :created, location: @app }
      else
        format.html { render action: "new" }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

# PUT /apps/1
# PUT /apps/1.json
  def update

    @app = App.find(params[:id])
    if current_user!=@app.user
      redirect_to root_url
    else
      respond_to do |format|
        if @app.update_attributes(params[:app])
          format.html { redirect_to @app, notice: 'app was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @app.errors, status: :unprocessable_entity }
        end
      end
    end
  end

# DELETE /apps/1
# DELETE /apps/1.json
  def destroy
    @app = App.find(params[:id])
    if current_user==@app.user
      @app.destroy
      respond_to do |format|
        format.html { redirect_to apps_url, notice: 'app was successfully deleted.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to apps_url, notice: 'you are not allowed to delete this application' }
        format.json { render json: "" }
      end
    end

  end

  private

  def show_task(task)
    @task=task
    @area=@task.area
    @app=@area.app
    @completed, @size=@area.completion
    @editable=!(@area.annotated_by?(current_or_guest_user))
    respond_to do |format|
      format.html {}
      format.js {
        json_answer={:id=>@task.id, :submit_url=>app_area_task_url(@app, @area, @task), :area=>@area, :editable=>@editable}
        render :json=> json_answer
      }
      format.json {
        json_answer={:id=>@task.id, :submit_url=>app_area_task_url(@app, @area, @task), :area=>@area, :editable=>@editable}
        render :json=> json_answer
      }
    end

  end

end
