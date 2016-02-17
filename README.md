# anchor cookbook

The anchor cookbook is a library cookbook that provides resources for dealing with openstack anchor.

## Scope

This cookbook installs anchor and configures it. It is currently only supported running on ubuntu 14.04 using upstart for process control and nginx as a frontend proxy to a backend uwsgi server with the anchor app. Deployment of the anchor app happens directly from the openstack GIT repository.

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
* `anchor_installation_git`
* `anchor_proxy_nginx`
* `anchor_service`
  * `anchor_service_manager_upstart`

## Resource Details

### anchor_ca

The `anchor_ca` resource configures the CA certificate and key for the anchor service.

```ruby
anchor_ca 'myca' do
  certificate '----- my certificate -----'
  key '----- my private key -----'
end
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

# Maintainers

* Paul Thomas <pthomas@dyn.com>
