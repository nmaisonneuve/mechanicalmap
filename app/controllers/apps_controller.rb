class AppsController < ApplicationController

  # GET /apps
  # GET /apps.json
  def index
    @apps = App.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @apps }
    end
  end

  def scheduler
    context={:from_task=>params[:from_task], :current_user=>current_or_guest_user}
    @task_unit=App.find(params[:id]).schedule(context)
    if @task_unit.nil?
      redirect_to app_path(params[:id]), notice: 'Sorry no further task available!'
    else
      redirect_to app_task_unit_path(@task_unit.task.app, @task_unit.task, @task_unit, :format=>params[:format])
    end
  end


  def show
    @app = App.find(params[:id])
    #@available_tasks=@app.areas.not_annotated_by(current_or_guest_user).exists?
    if (params[:embeddable].blank?)
      render 'show.erb.html'
    else
      render 'embeddable.erb.html'
    end
  end

  def new
    @app = App.new
  end

# GET /apps/1/edit
  def edit
    @app = App.find(params[:id])
  end


# POST /apps
# POST /apps.json
  def create

    # we get the schema and remove it from the persistant attribute

    @app = App.new(params[:app])

    respond_to do |format|
      if @app.save

        gen_params=ActiveSupport::JSON.decode(params[:task_input])

        GeoTaskGenerator.generate({:app_id=>@app.id,
                                   :table_name=>"#{@app.name}_tasks",
                                   :rectangle=>gen_params["rectangle"],
                                   :resolution=>gen_params["resolution"]})

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
    @app = app.find(params[:id])

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

# DELETE /apps/1
# DELETE /apps/1.json
  def destroy
    @app = app.find(params[:id])
    @app.destroy

    respond_to do |format|
      format.html { redirect_to apps_url }
      format.json { head :no_content }
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
