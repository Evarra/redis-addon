ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache redis bash

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT []

CMD ["/run.sh"]