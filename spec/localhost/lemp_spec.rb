require 'spec_helper'

#
# Specific packages should be installed
#
packages = %w(
  apache2
  nginx
  mysql-server
  php7.0
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
describe command('/usr/sbin/nginx -V') do
  its(:stderr) { should contain('TLS SNI support enabled') }
  its(:stderr) { should contain('http_v2_module') }
end

describe command('php -v') do
  its(:stdout) { should contain('PHP 7.0') }
end

describe command('ruby -v') do
  its(:stdout) { should contain('ruby 2.3') }
end

describe command('node -v') do
  its(:stdout) { should contain('v5.10') }
end

describe command('wp --info') do
  its(:exit_status) { should eq 0 }
end

describe command('wp --info') do
  its(:exit_status) { should eq 0 }
end

describe command('composer help') do
  its(:exit_status) { should eq 0 }
end

describe file(File.join(ENV["HOME"], '/letsencrypt/letsencrypt-auto')) do
  it { should be_executable }
end
