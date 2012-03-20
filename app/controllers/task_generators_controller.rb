class TaskGeneratorsController < ApplicationController
  def new

  end

  def create

    gen_params=ActiveSupport::JSON.decode(params[:task_input])

    p gen_params

    table_name=(0..10).map{|i| (65 +rand(26)).chr}.join("")
    @table_id=GeoTaskGenerator.generate({:table_name=>table_name,
                               :rectangle=>gen_params["rectangle"],
                               :resolution=>gen_params["resolution"]})
    render "show.html.erb"
  end

  def show
         p params
  end
end
