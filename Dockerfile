FROM xu-cheng/texlive-alpine:latest AS build

RUN apk --no-cache add \
    ghostscript \
    inkscape
RUN tlmgr update --self
RUN tlmgr update --all
CMD ["/entrypoint.sh"]
