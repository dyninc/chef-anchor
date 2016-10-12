# anchor cookbook

The anchor cookbook is a library cookbook that provides resources for dealing with openstack anchor.

## Scope

This cookbook installs anchor and configures it. It is currently only supported running on ubuntu 14.04 using upstart for process control and nginx as a frontend proxy to a backend uwsgi server with the anchor app. Deployment of the anchor app happens directly from the openstack GIT repository or from pip.

## Requirements

* Chef 12.0.0 or higher. Chef 11 is NOT SUPPORTED, please do not open issues about it.
* Ruby 2.1 or higher (preferably, the Chef full-stack installer)

## Cookbook dependencies

* apt
* compat_resource
* nginx
* poise-python

## Usage

* Add dependency to your metadata.rb
* Use provided resources such as `anchor_ca` to configure the anchor service

## Usage Examples

See `test/cookbooks/anchor-test/recipes/git.rb`

## Resources Overview
* `anchor_ca`
* `anchor_certificate`
* `anchor_installation_git`
* `anchor_installation_pip`
* `anchor_proxy_nginx`
* `anchor_service`
  * `anchor_service_manager_upstart`

## Resource Details

For more full examples see https://github.com/dyninc/chef-anchor/blob/master/test/cookbooks/anchor-test/recipes/git.rb or https://github.com/dyninc/chef-anchor/blob/master/test/cookbooks/anchor-test/recipes/pip.rb.

### anchor_ca

The `anchor_ca` resource configures the CA certificate and key for the anchor service.

```ruby
anchor_ca 'myca' do
  certificate '----- my certificate -----'
  key '----- my private key -----'
end
```

### anchor_installation_pip

Installs anchor from pip

```ruby
anchor_installation_pip '/opt/anchor'
```

### anchor_installation_git

Installs the anchor source code from git.

```ruby
anchor_installation_git '/opt/anchor' do
  repourl 'git://git.openstack.org/openstack/anchor'
end
```

### anchor_proxy_nginx

Configures NGINX to proxy to the anchor UWSGI server

```ruby
anchor_proxy_nginx 'localhost' do
  ssl false
end
```

### anchor_service

Configures the anchor service to run (currently only supports upstart through `anchor_service_manager_upstart`)

```ruby
anchor_service 'anchor' do
  action :start
end
```

### anchor_certificate

Can be used on a client to generate a certificate from Anchor

```ruby
anchor_certificate 'test.test.test.net' do
  country 'UK'
  state 'S Gloucs'
  city 'Bristol'
  organisation 'Dyn'
  department 'Testers'
  email 'test@test.com'
  bits 2048
  extensions ('extendedKeyUsage' => 'serverAuth,clientAuth')
  path '/tmp'
  anchorurl 'http://localhost:5016/v1/sign/default'
  anchoruser 'myusername'
  anchorsecret 'simplepassword'
  action :create
end
```

# Maintainers

* Paul Thomas <pthomas@dyn.com>

# License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
