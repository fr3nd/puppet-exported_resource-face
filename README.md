puppet-exported_resource-face
=============================

Description
-----------

A Puppet Face for interacting with all the exported resources stored in puppet database

Requirements
------------

* `puppet ~> 2.7.0`
* `activeresource` gem
* Puppet configured with `storeconfigs=true`

Installation
------------

1. Install puppet-exported_resource-face as a module in your Puppet master's module path.

2. Install the activeresource gem:

    $ sudo gem install activeresource

You will also probably need to set up the RUBYLIB environment variable:

    export RUBYLIB=/var/lib/puppet/lib:$RUBYLIB

Usage
-----

### List

To list all exported resources from a host:

    $ puppet exported_resource list www.puppetlabs.com

List all exported resources with name sshkey from a host

    $ puppet exported_resource list www.puppetlabs.com --restype sshkey

### Search

Search all nagios_host exported resources:

    $ puppet exported_resource search nagios_host

Search all nagios_host exported resources with tag puppetlabs.com:

    $ puppet exported_resources search nagios_host --filter "tag=puppetlabs.com"

Author
------

Carles Amigó <fr3nd@fr3nd.net>

License
-------

    Author:: Carles Amigo (<fr3nd@fr3nd.net>)
    Copyright:: Copyright (c) 2012 Carles Amigo
    License:: Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
