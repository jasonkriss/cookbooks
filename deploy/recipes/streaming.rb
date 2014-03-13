include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'other'
    Chef::Log.debug("Skipping deploy::streaming application #{application} as it is not a streaming app")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  execute 'bundle install' do
    cwd "#{deploy[:deploy_to]}/current"
    user 'root'
    environment 'RAILS_ENV' => deploy[:daemon_env]
  end

  OpsWorks::RailsConfiguration.bundle(application, deploy, "#{deploy[:deploy_to]}/current")
end