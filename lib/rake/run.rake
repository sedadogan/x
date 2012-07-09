# encoding: utf-8

desc "çalıştır"
task :run do
  sh "ruby #{Rake.original_dir}/main.rb"
end
