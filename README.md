# LEMP on Ubuntu Trusty

* Apache2
* Nginx Mainline release
* MySQL (Default package)
* PHP7
* WP-CLI
* Let's Encrypt & SNI & HTTP/2

## Requires

* Ubuntu 14.04 Trusty

## Getting Started

```
$ git clone git@github.com:miya0001/ubuntu-trusty-lemp.git
```

### Installs Apache2 + Nginx + MySQL + PHP5

Clone this repository on the new machine.
```
$ bash ./setup.sh
```

### Automated testing

```
$ bundle install --path vendor/bundle
$ bundle exec rake spec
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
