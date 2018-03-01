#
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
# Cookbook Name:: java
# Recipe:: oracle
#
# Copyright 2011, Bryan w. Berry
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


java_home = node['java']["java_home"]
arch = node['java']['arch']
jdk_version = node['java']['jdk_version']

#convert version number to a string if it isn't already
if jdk_version.instance_of? Fixnum
  jdk_version = jdk_version.to_s
end

case jdk_version
when "6"
  tarball_url = node['java']['jdk']['6'][arch]['url']
  tarball_checksum = node['java']['jdk']['6'][arch]['checksum']
when "7"
  tarball_url = node['java']['jdk']['7'][arch]['url']
  tarball_checksum = node['java']['jdk']['7'][arch]['checksum']
end

ruby_block  "set-env-java-home" do
  block do
    ENV["JAVA_HOME"] = java_home
  end
end

java_ark "jdk" do
  url tarball_url
  checksum tarball_checksum
  app_home java_home
  bin_cmds ["java", "javac", "jar"]
  action :install
end

# Create symbolic link from JAVA_HOME location created using java-sun recipe
# and the new recipes
ruby_block "create links for backwards compat with older recipes" do 
  block do
    case node["platform"]
    when "ubuntu"
      java_home_abspath = File.readlink(java_home)
      case jdk_version
      when "6"
        link_name = "/usr/lib/jvm/java-6-sun"
        if File.exist?(link_name) || File.symlink?(link_name) then
          File.delete(link_name)
        end
      when "7"
        link_name = "/usr/lib/jvm/java-7-sun"
        if File.exist?(link_name) || File.symlink?(link_name) then
          File.delete(link_name)
        end
      else
        link_name = "/usr/lib/jvm/java-sun"
        if File.exist?(link_name) || File.symlink?(link_name) then
          File.delete(link_name)
        end
      end
      File.symlink(java_home_abspath, link_name)
    end
  end
end
