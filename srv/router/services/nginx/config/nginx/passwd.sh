#!/bin/bash
echo "guest:$(openssl passwd -apr1)" >>.htpasswd_console
