#
# Cookbook Name:: es-specinfra-example
# Recipe:: elasticsearch
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'java'
include_recipe 'elasticsearch'
include_recipe 'supervisor'

package 'which'

execute "extract-kibana" do
  cwd node['kibana_base_dir']
  command "tar -xzf #{node['kibana_src']}.tar.gz"
  action :nothing
end

remote_file "#{node['kibana_base_dir']}/#{node['kibana_src']}.tar.gz" do
  source "https://download.elasticsearch.org/kibana/kibana/#{node['kibana_src']}.tar.gz"
  notifies :run, 'execute[extract-kibana]', :immediately
end

service "elasticsearch" do
  supports :status => true, :restart => true
  action :start
end

supervisor_service "kibana" do
  command "#{node['kibana_base_dir']}/#{node['kibana_src']}/bin/kibana"
  action [:enable, :start]
  autostart true
end
