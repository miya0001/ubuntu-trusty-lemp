# LEMP on Ubuntu Trusty

* Apache2
* Nginx Mainline release
* MySQL (Default package)
* Let's Encrypt & SNI & HTTP/2

## Getting Started

```
$ git clone git@github.com:miya0001/ubuntu-trusty-lemp.git
```

### Setup LEMP

```
$ bash ./setup.sh
```

### Automated testing

```
$ bundle install --path vendor/bundle
$ bundle exec rake spec
```
