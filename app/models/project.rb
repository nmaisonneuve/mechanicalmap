require 'geo_ruby'

class Project < ActiveRecord::Base
  has_many :areas
  has_many :tasks, :through => :areas

  validates_presence_of :name
  validates_presence_of :lat_sw
  validates_presence_of :lng_sw
  validates_presence_of :lat_ne
  validates_presence_of :lng_ne

  attr_accessible :wms_map, :lat_sw, :lng_sw, :lat_ne, :lng_ne,
                  :name,
                  :description, :lat_res, :lng_res, :redundancy,
                  :ft_id

  def completion
    completed=self.tasks.completed.count
    size=self.tasks.count
    [completed, size]
  end

  def insert(rows)
    FtDao.instance.enqueue(self.ft_id, rows)
  end
  def pre_processing(user)
    #begin
      first_line=self.description.split("\n")[0]
      first_line=first_line.match(/<!--(.*)-->/)[1].chomp.strip
      cols=ActiveSupport::JSON.decode(first_line)
      p cols
      table_id=FtDao.instance.create_table(self.name, cols)
      self.ft_id=table_id
      FtDao.instance.set_permission("table:#{self.ft_id}", user.email)
      create_tasks

    #rescue MultiJson::DecodeError=> e
    #end

  end

  def create_tasks()

    ne=GeoRuby::SimpleFeatures::Point.from_x_y(lng_ne, lat_ne)
    n_w=GeoRuby::SimpleFeatures::Point.from_x_y(lng_sw, lat_ne)
    s_e=GeoRuby::SimpleFeatures::Point.from_x_y(lng_ne, lat_sw)

    lng_distance=ne.ellipsoidal_distance(n_w)
    lat_distance=ne.ellipsoidal_distance(s_e)

    div_lat=(lat_distance/(lat_res*1000)).ceil
    div_lng=(lng_distance/(lng_res*1000)).ceil

    res_lat=((lat_ne-lat_sw)/div_lat)
    res_lng =((lng_ne-lng_sw)/div_lng)

    0.upto(div_lat.to_i-1) do |i|
      0.upto(div_lng.to_i-1) do |j|
        cell_lat_sw=lat_sw+res_lat*i
        cell_lng_sw=lng_sw+res_lng*j
        cell_lat_ne=cell_lat_sw+res_lat
        cell_lng_ne=cell_lng_sw+res_lng
        area=Area.create(:lat_ne=>cell_lat_ne,
                         :lng_ne=>cell_lng_ne,
                         :lat_sw=>cell_lat_sw,
                         :lng_sw=>cell_lng_sw)

        redundancy.times do
          area.tasks<< Task.create(:state=>Task::AVAILABLE)
        end

        self.areas<<area
      end
    end
  end

end

