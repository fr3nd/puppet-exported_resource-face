require 'puppet/face'
require 'puppet/rails'

Puppet::Face.define(:exported_resource, '0.0.1') do
    copyright "Carles Amigo", 2012
    author    "Carles Amigo <fr3nd@fr3nd.net>"
    license   "Apache 2 license; see COPYING"

    summary "View and manage Puppet exported resources."
    description <<-'EOT'
        This subcommand provides a command line interface to work Puppet exported
        resources.
    EOT
    option "--format FORMAT" do
        summary "Rendering output format. Available options: yaml, puppet"
    end


    action :list do
        summary "List exported resources for a node"
        arguments "<node>"
        description <<-'EOT'
            Lists the stored exported resources for the specified node.
        EOT
        examples <<-'EOT'
            # list all exported resources for host www.puppetlabs.com
            ] puppet exported_resource list www.puppetlabs.com

            # lists all sshkey resources for host www.puppetlabs.com
            ] puppet exported_resource list www.puppetlabs.com --restype sshkey
        EOT
        option "--restype RESOURCE" do
            summary "Show only the resources with the specified name"
        end

        when_invoked do |node, options|
            require 'puppet/util/run_mode'
            $puppet_application_mode = Puppet::Util::RunMode[:master]

            return unless Puppet[:storeconfigs] && Puppet.features.rails?
            Puppet::Rails.connect
            unless rails_node = Puppet::Rails::Host.find_by_name(node)
                Puppet.notice "No entries found for #{node} in storedconfigs."
                return
            end

            query = {:include => {:param_values => :param_name}}
            query_string = "exported=? AND host_id=?"
            query_options = [true, rails_node]
            if options[:restype]
                query_string << " AND restype=?"
                query_options << options[:restype]
            end
            query[:conditions] = [ query_string ] | query_options

            Puppet::Rails::Resource.find(:all, query).each do |resource|
                show_resource(resource, options[:format])
                puts
            end
            puts
        end
    end

    action :search do
        summary "Search exported resources of a specific type"
        arguments "<resource>"
        description <<-'EOT'
            Given a specific resource type, search all the exported resources
            from this type. All the resources can also be filtered given a
            specific attribute.
        EOT
        examples <<-'EOT'
            # search all nagios_host exported resources:
            ] puppet exported_resource search nagios_host

            # search all nagios_host exported resources with tag puppetlabs.com:
            ] puppet exported_resources search nagios_host --filter "tag=puppetlabs.com"
        EOT
        option "--filter FILTER" do
            summary "Filter the result using any resource parameter."
        end

        when_invoked do |type, options|
            require 'puppet/util/run_mode'
            $puppet_application_mode = Puppet::Util::RunMode[:master]

            return unless Puppet[:storeconfigs] && Puppet.features.rails?
            Puppet::Rails.connect

            query = {:include => {:param_values => :param_name}}
            query_string = "exported=? AND restype=?"
            query_options = [true, type]
            query[:conditions] = [ query_string ] | query_options
            Puppet::Rails::Resource.find(:all, query).each do |resource|
                if options[:filter] then
                    param_name = Puppet::Rails::ParamName.find_or_create_by_name(options[:filter].split("=")[0])
                    if Puppet::Rails::ParamValue.find(:all, :conditions => [ 'value=? AND param_name_id=? AND resource_id=?', options[:filter].split("=")[1], param_name, resource.id ])[0] then
                        show_resource(resource, options[:format])
                        puts
                    end
                else
                    show_resource(resource, options[:format])
                    puts
                end
            end
            puts
        end
    end

    def show_resource(resource, format)
        case format
        when 'yaml'
            puts "#{resource.to_yaml}"
        else
            puts "# created_at: #{resource[:created_at]}"
            puts "# updated_at: #{resource[:updated_at]}"
            puts "#{resource[:restype].downcase} { '#{resource[:title]}':"
            params = Hash.new
            resource.param_values.each do |param_value|
                unless params.has_key?(param_value.param_name[:name])
                    params[param_value.param_name[:name]] = Array.new
                end
                params[param_value.param_name[:name]] << param_value[:value]
            end
            params.sort.map do |param, value|
                case param
                when 'require', 'before', 'notify', 'subscribe'
                    # when it's a reference to other resource it should be treated diferently
                    references = Array.new
                    value.each do |v|
                        references << YAML::load(v)
                    end
                    if references.length > 1
                        puts "    #{param} => [ #{references.join(', ')} ],"
                    else
                        puts "    #{param} => #{references},"
                    end
                else
                    if value.length > 1
                        puts "    #{param} => [ '#{value.join('\', \'')}' ],"
                    else
                        puts "    #{param} => '#{value}',"
                    end
                end
            end
            puts "}"
        end
    end
end
