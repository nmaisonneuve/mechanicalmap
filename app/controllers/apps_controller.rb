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
    unless params[:copyof].blank?
      original=App.find(params[:copyof])
      @app=original.clone
      @schema=FtDao.instance.get_schema(original.output_ft)
      @schema=@schema.to_json.to_s     #to json string
      @cloned=true
    else
      @app = App.new
      @schema=""
      @cloned=false
    end

  end


  def user_state
    app=App.find(params[:id])
    # strange but working
    opened=app.tasks.not_done_by_username(current_or_guest_username).count
    completed=app.tasks.done_by_username(current_or_guest_username).count
    render json: {:opened=>opened, :completed=>completed}
  end

  def reindex
    app=App.find(params[:id])
    app.reindex_tasks(params[:syn] || false )
    redirect_to app_path(app), notice: 'Reindexing tasks'
  end

  def workflow
    app=App.find(params[:id])
    context={:from_task=>params[:from_task], :current_user=>current_or_guest_username}
    assignment=app.next_task(context)
    if assignment.nil?
      respond_to do |format|
        format.html { redirect_to app_path(app), notice: 'Sorry no further task available!' }
        format.js { render :json=>"", :status => 404 }
      end
    else
      redirect_to app_task_answer_path(assignment.task.app, assignment.task, assignment, :format=>params[:format])
    end
  end


  def editor
    @app = App.find(params[:id])
      render :layout => false
  end


  def editor_update
    @app = App.find(params[:id])
    if current_user!=@app.user
      redirect_to root_url
    else
      respond_to do |format|
        if @app.update_attributes(params[:app])
          format.html { render action: "editor" , notice: 'app was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "editor" }
          format.json { render json: @app.errors, status: :unprocessable_entity }
        end
      end
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
        @app.output_ft
        schema=[{"name"=>"task_id", "type"=>"number"},
                {"name"=>"user_id", "type"=>"string"},
                {"name"=>"created_at", "type"=>"datetime"}]

        schema=ActiveSupport::JSON.decode(params[:schema]) unless  params[:schema].blank?
                     p schema

        # we postpone the indexation of task + the generation of answer task
        FtIndexer.perform_async(@app.id, params[:app_redundancy].to_i)
        FtGenerator.perform_async(@app.id, schema, current_user.email)


        format.html { redirect_to editor_app_path(@app), notice: 'app was successfully created.' }
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


end
