#!/bin/bash

export JAVA_HOME=/home/oogasawa/local/jdk-20.0.1
export PATH=$JAVA_HOME/bin:$PATH
apptainer exec --mount src=/home/oogasawa,dst=/home/oogasawa ~/emacs29.sif emacs "$@"
