-- init.sql

CREATE DATABASE IF NOT EXISTS university;
USE university;

CREATE TABLE IF NOT EXISTS student (
    faculty VARCHAR(100),
    degree VARCHAR(100),
    RegNo VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100),
    NICno VARCHAR(20),
    gender VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS result (
    IndexNo VARCHAR(20) PRIMARY KEY,
    semester VARCHAR(10),
    s1 VARCHAR(10),
    s2 VARCHAR(10),
    s3 VARCHAR(10),
    s4 VARCHAR(10),
    s5 VARCHAR(10),
    s6 VARCHAR(10)
);


-- kubectl create configmap mysql-initdb-config \
--   --from-file=init.sql \
--   --dry-run=client -o yaml > mysql-initdb-configmap.yaml

-- kubectl delete configmap mysql-custom-config
-- kubectl create configmap mysql-custom-config --from-file=z-custom.cnf=./z-custom.cnf

-- kubectl create configmap mysql-custom-config \
  --from-file=z-custom.cnf=./z-custom.cnf \
  --dry-run=client -o yaml | kubectl apply -f -

--   dos2unix z-custom.cnf