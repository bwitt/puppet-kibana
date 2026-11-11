# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'helpers/acceptance/tests/class_shared_examples'

# rubocop:disable RSpec/MultipleMemoizedHelpers
describe 'kibana class v5' do
  let(:plugin)         { 'health_metric_vis' }
  let(:plugin_version) { '0.3.4' }
  let(:port)           { 5602 }
  let(:version)        { fact('osfamily') == 'RedHat' ? '5.2.0-1' : '5.2.0' }

  let(:manifest) do
    <<-MANIFEST
        class { 'elastic_stack::repo':
          version => 5,
        }

        class { 'kibana':
          ensure => '#{version}',
          config => {
            'server.host' => '0.0.0.0',
            'server.port' => #{port},
          },
        }

        # Kibana 5 bundles a Node.js too old to verify GitHub's TLS chain
        file { '#{plugin_file}':
          source => '#{plugin_url}',
        }

        kibana_plugin { '#{plugin}':
          ensure  => 'present',
          url     => 'file://#{plugin_file}',
          version => '#{plugin_version}',
          require => File['#{plugin_file}'],
        }
    MANIFEST
  end

  let(:plugin_file) { "/tmp/#{plugin}-#{plugin_version}.zip" }

  let(:plugin_url) do
    "https://github.com/DeanF/#{plugin}/releases/download/v#{plugin_version}/#{plugin}-#{version.split('-').first}.zip"
  end

  include_examples 'class manifests',
                   '/usr/share/kibana/plugins/health_metric_vis/package.json',
                   '0.3.5'
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
