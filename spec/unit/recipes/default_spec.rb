#
# Cookbook:: spring_service
# Spec:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'spring_service::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['spring_service'], cookbook_path: ['./test/cookbooks', '../'], platform: 'centos', version: '6.7') do |node|
      end.converge('spring_service_test::default')
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
