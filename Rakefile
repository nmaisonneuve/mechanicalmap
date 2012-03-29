#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake/dsl_definition'

Mechanicalmap::Application.load_tasks

desc "synch answers"
task :sync=>:environment do
  App.all.each { |app|
  units=app.units.answered.where(:ft_sync=>false)
  if (units.size>0)
    puts "#{units.size} answers to synchronize"
    FtDao.instance.sync_answers(units)
  end
  }
end
