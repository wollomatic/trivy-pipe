FROM aquasec/trivy:0.69.3

COPY pipe /

RUN apk --no-cache add bash && chmod +x /pipe.sh

ENTRYPOINT ["/pipe.sh"]
