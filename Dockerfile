FROM aquasec/trivy:0.53.0

COPY pipe /

RUN apk --no-cache add bash

RUN chmod +x /pipe.sh

ENTRYPOINT ["/pipe.sh"]
