FROM rocker/geospatial:4.0.0

RUN set -x && \
  apt-get update && \
  apt-get install -y \
    r-cran-covr \
    r-cran-roxygen2 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ARG GITHUB_PAT

RUN set -x && \
  echo "GITHUB_PAT=$GITHUB_PAT" >> /usr/local/lib/R/etc/Renviron

RUN set -x && \
  install2.r --error --ncpus -1 --repos 'http://mran.revolutionanalytics.com/snapshot/2020-05-30' \
    knitr \
    usethis \
    lintr && \
  installGithub.r \
    r-lib/revdepcheck \
    r-spatial/sf && \
  rm -rf /tmp/downloaded_packages/ /tmp/*.rds
