#!/bin/bash -xe
DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=ab630323ee0887cfdc2493c33f51cc02 DD_SITE="datadoghq.eu" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"