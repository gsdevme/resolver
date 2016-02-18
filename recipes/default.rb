#
# Cookbook Name:: resolver
# Recipe:: default
#
# Copyright 2009-2015, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# = Requires
# * node[:resolver][:nameservers]

if node['resolver']['nameservers'].empty? || node['resolver']['nameservers'][0].empty?
  Chef::Log.warn("#{cookbook_name}::#{recipe_name} requires that attribute ['resolver']['nameservers'] is set.")
  Chef::Log.info("#{cookbook_name}::#{recipe_name} exiting to prevent a potential breaking change in /etc/resolv.conf.")
  return
else
  template '/etc/resolv.conf' do
    source 'resolv.conf.erb'
    owner 'root'
    group node['root_group']
    mode '0644'
    # This syntax makes the resolver sub-keys available directly
    variables node['resolver']
  end
  
  ruby_block "Disable DHCP from resetting resolv.conf" do
    block do
      fe = Chef::Util::FileEdit.new("/etc/sysconfig/network-scripts/ifcfg-eth0")
      fe.insert_line_if_no_match(/PEERDNS=no/,"PEERDNS=no")
      fe.write_file
    end
    only_if { ::File.exists?("/etc/sysconfig/network-scripts/ifcfg-eth0") }
  end
end
