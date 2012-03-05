class Project < ActiveRecord::Base
  has_many :areas
  has_many :tasks, :through => :areas

  before_save :create_tasks

  def completion
    completed=self.tasks.completed.count
    size=self.tasks.count
    [completed,size]
  end

  def create_tasks()

    div_lat=5.0
    div_lng=5.0

    lat_unit=(lat_ne-lat_sw)/div_lat
    lng_unit =(lng_ne-lng_sw)/div_lng

    #user capacity (in km/km_to_degree)
    #lng_unit=5.0/111.12
    #lat_unit=3.0/111.12
    # num of cells
    #div_lat =(lat_ne-lat_sw)/lat_unit # /111.12 to convert km to degree
    #div_lng =(lng_ne-lng_sw)/lng_unit
    #puts "number of cells: #{div_lat.to_i}x#{div_lng.to_i}=#{div_lat.to_i*div_lng.to_i}"

    0.upto(div_lat.to_i-1) do |i|
      0.upto(div_lng.to_i-1) do |j|
        cell_lat_sw=lat_sw+lat_unit*i
        cell_lng_sw=lng_sw+lng_unit*j
        cell_lat_ne=cell_lat_sw+lat_unit
        cell_lng_ne=cell_lng_sw+lng_unit
        area=Area.create(:lat_ne=>cell_lat_ne,
                    :lng_ne=>cell_lng_ne,
                    :lat_sw=>cell_lat_sw,
                    :lng_sw=>cell_lng_sw)

        10.times do
          area.tasks<< Task.create(:state=>Task::AVAILABLE)
        end

        self.areas<<area
      end
    end
  end

end

