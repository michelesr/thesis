if docker start --attach thesis; then
  :
else
  docker run --name thesis -v $PWD:/code/ michelesr/latex /bin/bash \
    scripts/compile_pdf.sh
fi
