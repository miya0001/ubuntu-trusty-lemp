require 'spec_helper'

#
# Specific packages should be installed
#
packages = %w(
  apache2
  nginx
  mysql-server
  php7.0
  ruby
);

packages.each do |package|
  describe package(package), :if => os[:family] == 'ubuntu' do
    it { should be_installed }
  end
end

#
# Specific services should be installed
#
services = %w(
  apache2
  nginx
  mysql
);

services.each do |service|
  describe service(service), :if => os[:family] == 'ubuntu' do
    it { should be_enabled }
    it { should be_running }
  end
end

#
# Specific ports should be listening
#
ports = %w(
  22
  80
);

ports.each do |port|
  describe port(port) do
    it { should be_listening }
  end
end

#
# Tests of some commands
#
describe command('php -v') do
  its(:stdout) { should match /PHP 7\.0/ }
end

describe command('ruby -v') do
  its(:stdout) { should match /ruby 2\.3/ }
end

describe command('node -v') do
  its(:stdout) { should match /v5\.10/ }
end

describe command('wp --info') do
  its(:exit_status) { should eq 0 }
end
