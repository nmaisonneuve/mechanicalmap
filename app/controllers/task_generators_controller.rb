class TaskGeneratorsController < ApplicationController
  before_filter :authenticate_user!

  def create
    gen_params=ActiveSupport::JSON.decode(params[:task_input])
    table_name=(0..10).map{|i| (65 +rand(26)).chr}.join("")
    @table_id=GeoTaskGenerator.generate({:table_name=>table_name,
                               :rectangle=>gen_params["rectangle"],
                               :resolution=>gen_params["resolution"],
                                        :owner=>current_user.email })
    render "show.html.erb"
  end
end
