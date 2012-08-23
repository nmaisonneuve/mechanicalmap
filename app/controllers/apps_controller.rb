class AppsController < ApplicationController

  before_filter :authenticate_user!, :only=>[:new]

  # GET /apps
  # GET /apps.json
  def index
    @apps = App.order("created_at asc")
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @apps }
    end
  end

  def dashboard
    @app = App.find(params[:id])
  end

  def show
    @app = App.find(params[:id])
    respond_to do |format|
      format.html { render "show.html.erb", :layout => false }
      format.png  { redirect_to "http://api.qrserver.com/v1/create-qr-code/?size=145x145&data=#{app_url(@app)}"  }   
    end
  end

  def new
    @edit=false
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
    render json: {:opened=>opened, :completed=>completed}, :callback => params[:callback]
  end

  def reindex
    app=App.find(params[:id])
    app.index_tasks_async()
    redirect_to app_path(app), notice: 'Reindexing tasks'
  end

  def delete_answers
    app=App.find(params[:id])
    app.delete_answers
    redirect_to app_path(app), notice: 'Deleting answers'
  end

  def source
    @app = App.find(params[:id])
    if (current_or_guest_username != @app.user and !@app.gist_id.nil?)
      redirect_to "https://gist.github.com/#{@app.gist_id}"
    end
  end


  def source_update
    @app = App.find(params[:id])
    if current_user != @app.user
      redirect_to root_url
    else
      if @app.update_attributes(params[:app])
        render json: {"gist_id"=> @app.synch_gist}.to_json 
      else
        render json: @app.errors, status: :unprocessable_entity 
      end
    end
  end

# GET /apps/1/edit
  def edit
    @app = App.find(params[:id])
    @edit = true
    @app.input_ft = "https://www.google.com/fusiontables/DataSource?docid=#{@app.input_ft }" unless @app.input_ft.blank?
    @app.output_ft = "https://www.google.com/fusiontables/DataSource?docid=#{@app.output_ft}" unless @app.output_ft.blank?
    @app.gist_id = "https://gist.github.com/#{@app.gist_id}" unless @app.gist_id.blank?

    if current_user != @app.user
      return redirect_to root_url
    end
  end


# POST /apps
# POST /apps.json
  def create
    clean_url(params)
    @app = App.create(params[:app])
    @app.user=current_user
    respond_to do |format|

      if @app.save
        @app.output_ft
      
        # we postpone the indexation of task 
        @app.index_tasks_async
        #+ the generation of answer tables 
        @app.create_schema(params[:schema], current_user.email)
        
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
    clean_url(params)
    @app = App.find(params[:id])
    if current_user!=@app.user
      redirect_to root_url
    else
      respond_to do |format|
        if @app.update_attributes(params[:app])
          format.html { redirect_to dashboard_app_path(@app), notice: 'app was successfully updated.' }
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
    if current_user == @app.user
      @app.destroy
      redirect_to apps_url, notice: 'app was successfully deleted.' 
    else
      redirect_to apps_url, notice: 'you are not allowed to delete this application'     
    end
  end

private
  
  GOOGLE_TABLE_REG=/www\.google\.com\/fusiontables\/DataSource\?docid=(.*)/

  def clean_url(params)
    matching=GOOGLE_TABLE_REG.match(params[:app][:input_ft])
    unless matching.nil?
      params[:app][:input_ft]=matching[1]
    end

    matching=GOOGLE_TABLE_REG.match(params[:app][:output_ft])
    unless matching.nil?
      params[:app][:output_ft]=matching[1]
    end

    matching=/https:\/\/gist\.github.com\/(.*)\/?/.match(params[:app][:gist_id])
    unless matching.nil?
      params[:app][:gist_id]=matching[1]
    end
  end

end
