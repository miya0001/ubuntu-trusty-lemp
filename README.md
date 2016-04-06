# LEMP on Ubuntu Trusty

* Apache2
* Nginx Mainline release (SNI & HTTP/2)
* MySQL (Default package)
* PHP7
* WP-CLI
* Let's Encrypt

## Requires

* Ubuntu 14.04 Trusty

## Getting Started

Clone this repository on the new machine.

```
$ git clone https://github.com/miya0001/ubuntu-trusty-lemp.git
```

### Install

```
$ cd ubuntu-trusty-lemp
$ bash ./setup.sh
```

## How to contribute

Clone this repository into your machine.

```
$ git clone git@github.com:miya0001/ubuntu-trusty-lemp.git
```

Then:

```
$ vagrant up
```

### Automated testing

SSH into your machine then run following.

```
$ cd /vagrant
$ bundle install --path vendor/bundle
$ bundle exec rake spec
```
