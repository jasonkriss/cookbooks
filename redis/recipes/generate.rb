node[:deploy].each do |application, deploy|
  template "#{deploy[:deploy_to]}/shared/config/redis.yml" do
    source "redis.yml.erb"
    cookbook "redis"
    mode "0660"
    group deploy[:group]
    owner deploy[:user]
    variables(:redis => deploy[:redis] || {})

    only_if do
      deploy[:redis].present?
    end
  end
end
