 class FtIndexer

  include Sidekiq::Worker

  def perform(table_name,rectangle, resolution , email)

    @table_id=GeoTaskGenerator.generate({:table_name=>table_name,
                               :rectangle=>rectangle,
                               :resolution=>resolution,
                                        :owner=> email })

  end

end

