FROM ubuntu
MAINTAINER Eduardo Arango <carlos.arango.gutierrez@correounivalle.edu.co>

ADD singularity_build.sh /tmp
WORKDIR /tmp
ENTRYPOINT ["/tmp/singularity_build.sh","setup","build","install"]
