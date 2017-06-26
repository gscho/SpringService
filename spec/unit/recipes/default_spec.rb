#
# Cookbook:: spring_service
# Spec:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

require 'spec_helper'

ChefSpec.define_matcher :my_custom_resource

describe 'spring_service::default' do

  context 'When all attributes are default, on an unspecified platform' do

    let(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['spring_service'], cookbook_path: ['./test/cookbooks', '../'], platform: 'centos', version: '6.7') do |node|
      end.converge('spring_service_test::default')
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'creates a symbolic link' do
      expect(chef_run).to create_link('/testdir/test.jar').with(link_type: :symbolic)
    end

    it 'creates a template with the default action' do
	  expect(chef_run).to create_template('/testdir/test.conf').with(mode: 755)
	end

  end
end
