# mkELK
Make a persistent ELK stack docker container PDQ!

### Usage

#### Initialization

`make example` will copy datadir.example to datadir

at this point you'll need to go supply a `datadir/logstash/conf/logstash.conf` file

of note you can move the `datadir` wherever you like, but update the file DATADIR accordingly, it should contain a full path to the `datadir`

### Running

`make elk`  this is pretty much it, it should prompt you for any needed info

#### Restart

restart the container with `make rm` followed by `make elk`

#### Migration

to migrate simply tar up this directory along with the datadir and move to the new docker host
