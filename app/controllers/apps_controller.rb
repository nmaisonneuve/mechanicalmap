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

  def show
    @app = App.find(params[:id])
    if (params[:embeddable].blank?)
      respond_to do |format|
        format.html {render 'show.erb.html'}
        format.png { render :qrcode => app_url(@app, :embeddable=>1), :size => 5 }
      end
    else
      render 'embeddable.erb.html', :layout=>false
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
    render json: {:opened=>opened, :completed=>completed}, :callback => params[:callback]
  end

  def reindex
    app=App.find(params[:id])
    app.index_tasks_async()
    redirect_to app_path(app), notice: 'Reindexing tasks'
  end

  def clean_answers
    app=App.find(params[:id])
    app.answers.each {|answer| 
      answer.destroy
    }
    FtDao.delete_all(app.output_ft)
    redirect_to app_path(app), notice: 'Deleting answers'
  end

  def editor
    @app = App.find(params[:id])
  end


  def editor_update
    @app = App.find(params[:id])
    if current_user!=@app.user
      redirect_to root_url
    else
        if @app.update_attributes(params[:app])
          id=@app.synch_gist
          p id 
          render json: {"gist_id"=> id}.to_json 
        else
          render json: @app.errors, status: :unprocessable_entity 
        end
    end
  end

# GET /apps/1/edit
  def edit
    @app = App.find(params[:id])
    if current_user!=@app.user
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
