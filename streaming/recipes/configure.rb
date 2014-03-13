node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'other'
    Chef::Log.debug("Skipping streaming::configure application #{application} as it is not a streaming app")
    next
  end

  template "/etc/monit.d/streaming.monitrc" do
    source "streaming.monitrc.erb"
    owner 'root'
    group 'root'
    mode 0644
    variables({
      :process_name => deploy[:process_name],
      :path => deploy[:deploy_to],
      :env => deploy[:daemon_env]
    })
  end

  template "#{deploy[:deploy_to]}/shared/config/redis.yml" do
    owner deploy[:user]
    group deploy[:group]
    mode 0644
    source "redis.yml.erb"
    variables(deploy[:redis])
  end

  execute "reload-monit-for-streaming" do
    command "monit reload"
  end
end