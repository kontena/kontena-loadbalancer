# Development

Kontena loadbalancer uses confd to generate up-to-date config for the HAProxy


# Testing

Testing the loadbalancer is done locally using excellent [Bats](https://github.com/sstephenson/bats) framework.

## Setup

### Install Bats

Install Bats, e.g. on OSX you can do it with `brew install bats`

### Prepare test Docker images and helpers

```
./prepare_test.sh
```

The script builds few Docker images and runs couple of instances of the loadbalancer with Docker compose.

When the script exits your test cases are ready to be run.

## Run the tests

To run all test cases run:
```
$ bats test/
 ✓ basic auth gives 401 without user and password
 ✓ basic auth gives 200 with valid user and password
 ✓ basic auth gives 200 with valid user and password, password encrypted
 ✓ supports cookie stickyness
 ✓ supports cookie stickyness with custom cookie config
 ✓ supports cookie stickyness with custom cookie prefix
 ✓ returns custom error page
 ✓ returns health check page if configured in env
 ✓ returns error if health not configured in env
 ✓ supports health check uri setting for balanced service
 ✓ redirects *.foo.com -> foo.com
 ✓ supports ssl with invalid cert ignored
 ✓ supports virtual_hosts
 ✓ supports wildcard virtual_hosts
 ✓ supports virtual_hosts + virtual_path
 ✓ supports virtual_hosts + virtual_path + keep_virtual_path
 ✓ handles empty upstreams
 ✓ on duplicate virtual_hosts first one in alphabets wins
 ✓ prioritizes first vhost+vpath, then vhost and finally vpath
 ✓ works with domain:port host header
 ✓ supports virtual_path
 ✓ supports virtual_path + keep_virtual_path

22 tests, 0 failures
```

The tests are organized so that each `.bats` file container logically related test cases, a.k.a test suite.

If you want to run individual suite run:
```
$ bats test/virtual_path_test.bats
 ✓ supports virtual_path
 ✓ supports virtual_path + keep_virtual_path

2 tests, 0 failures
```

## Writing test cases

Typical test case has three steps:
- Write proper data to etcd
- Wait for ConfD to reload the config
- Test with actual HTTP request(s)

See existing test cases for "template"

## Test against new changes in LB

When you make changes to LB you must naturally re-build and re-run the docker containers. If you've started the base setup with `prepare_test.sh` script you can stop the existing containers with:
```
$ docker-compose -f docker-compose.test.yml stop
```

To re-build images and containers issue:
```
$ docker-compose -f docker-compose.test.yml up --build -d
```
