    git clone --branch 1.4.2 https://bitbucket.org/genomicepidemiology/kma.git && \
    cd kma && \
    make;

    git clone --branch 2.0.9 https://bitbucket.org/genomicepidemiology/mlst.git;


    git clone https://git@bitbucket.org/genomicepidemiology/mlst_db.git && \
    cd mlst_db && \ 
# Updated on 25/05/22
    git checkout 5e385d4 && \ 
    python3 INSTALL.py kma_index;