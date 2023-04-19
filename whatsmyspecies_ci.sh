mkdir minikraken && cd minikraken && \
wget -q https://ccb.jhu.edu/software/kraken/dl/minikraken_20171019_8GB.tgz && \
tar -zxf minikraken_20171019_8GB.tgz --strip-components=1 && \
rm minikraken_20171019_8GB.tgz && \
wget -O minikraken_100mers_distrib.txt -q https://ccb.jhu.edu/software/bracken/dl/minikraken_8GB_100mers_distrib.txt && \
chmod +r minikraken_100mers_distrib.txt; 