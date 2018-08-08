#!/bin/sh

mvn -P release deploy -DskipTests=true -B -V -s travis-settings.xml
