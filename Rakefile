#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake/dsl_definition'

Mechanicalmap::Application.load_tasks

desc "synch answers"
task :sync => :environment do
  App.all.each { |app|
    answers=app.answers.answered.where(:ft_sync => false)
    if (answers.size>0)
      puts "#{answers.size} answers to synchronize"
      FtDao.instance.sync_answers(answers)
    end
  }
end

desc "synch answers"
task :sync => :environment do
  App.all.each { |app|
    answers=app.answers.answered.where(:ft_sync => false)
    if (answers.size>0)
      puts "#{answers.size} answers to synchronize"
      FtDao.instance.sync_answers(answers)
    end
  }
end

desc "reindex answer"
task :answers_gen => :environment do
  App.first.tasks.each { |task|
    1.times do
      task.answers<<Answer.create!(:state => Answer::AVAILABLE)
    end
  }
end

