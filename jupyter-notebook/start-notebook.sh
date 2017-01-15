#!/bin/sh
echo "run Jupyter Notebook on port ${JUPYTER_NOTEBOOK_PORT}
cd /home/jupyter/${JUPYTER_WORKDIR}
. ./bin/activate
jupyter notebook --ip=0.0.0.0 --port=${JUPYTER_NOTEBOOK_PORT}
