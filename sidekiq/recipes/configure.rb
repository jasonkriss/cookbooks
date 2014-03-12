node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping sidekiq::configure application #{application} as it is not a rails app")
    next
  end

  process_name = "#{application}_sidekiq"

  template "/etc/monit.d/#{process_name}.monitrc" do
    source "sidekiq.monitrc.erb"
    owner 'root'
    group 'root'
    mode 0644
    variables({
      :process_name => process_name,
      :path => deploy[:deploy_to],
      :env => deploy[:rails_env],
      :user => deploy[:user],
      :group => deploy[:group],
      :memory_limit => node[:sidekiq][:memory_limit]
    })
  end

  template "#{deploy[:deploy_to]}/shared/config/sidekiq.yml" do
    owner deploy[:user]
    group deploy[:group]
    mode 0644
    source "sidekiq.yml.erb"
    variables(node[:sidekiq])
  end

  execute "reload-monit-for-sidekiq" do
    command "monit reload"
  end
end
