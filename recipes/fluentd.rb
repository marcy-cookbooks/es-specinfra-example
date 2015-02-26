#
# Cookbook Name:: es-specinfra-example
# Recipe:: fluentd
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

package 'libcurl-devel'

include_recipe 'build-essential'
include_recipe 'td-agent'

td_agent_source 'specinfra_inventory' do
  type 'specinfra_inventory'
  params(inventory_keys: ['cpu','domain','filesystem','fqdn','hostname','memory','platform','platform_version'])
end

td_agent_match 'elasticsearch' do
  type 'elasticsearch'
  tag 'specinfra.inventory.**'
end
