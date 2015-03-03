#
# Cookbook Name:: es-specinfra-example
# Recipe:: fluentd
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'build-essential'
include_recipe 'rbenv::default'
include_recipe 'rbenv::ruby_build'
include_recipe 'supervisor'

case node['platform_family']
when "rhel", "fedora"
  package 'libcurl-devel'
when "debian"
  package 'libcurl4-openssl-dev'
end

rbenv_ruby "2.1.5" do
  global true
end

%w{
  fluentd
  fluent-plugin-forest
  fluent-plugin-elasticsearch
  fluent-plugin-specinfra_inventory
}.each do |name|
  rbenv_gem name do
    ruby_version "2.1.5"
  end
end

file "/etc/fluentd.conf" do
  content <<-EOH
<source>
  type specinfra_inventory
  time_span 60
</source>
<match specinfra.inventory>
  type forest
  subtype elasticsearch
  <template>
    logstash_format true
    logstash_prefix fluentd-${hostname}
  </template>
</match>
EOH
  notifies :restart, 'supervisor_service[fluentd]', :delayed
end

supervisor_service "fluentd" do
  command "#{node['rbenv']['root_path']}/shims/fluentd -c /etc/fluentd.conf"
  user node['rbenv']['user']
  action [:enable, :start]
  autostart true
end
