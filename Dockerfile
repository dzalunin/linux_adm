FROM nginx:latest
ENV CWD=/tmp/build
ADD build $CWD
RUN chmod +x $CWD/init.sh && $CWD/init.sh && rm -rf $CWD