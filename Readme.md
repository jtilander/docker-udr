# Easy to use UDR syncing

## Why?

No need to compile and install dependencies for UDR. This can be cleanly run inside of a docker container, both the server and the client.

## Usage


## Environment variables

|Name|Default|Description|
|----|-------|-----------|
|KEYS_URL||We will download this URL and stick it as /root/.ssh/authorized_keys|


## Ports

|Port|Protocol|Description|
|----|-------|-----------|
|22|TCP|Local sshd will be run here, usually map to 2222 on host.|
|9000|UDP|9000 - 9100 UDP will be used by UDR|


## Volumes

|Name|Description|
|----|-----------|
|/workspace|This is the directory both on the client and the server that will be synced|





# Resources

* http://www.ciara.fiu.edu/images/udr_poster_sc12.pdf
* https://github.com/LabAdvComp/UDR

