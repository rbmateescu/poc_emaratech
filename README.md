IBM Operational Decision Manager

- Developed for a POC Only, do not promote to the toolchain
- A single role which deploys Liberty and ODM in a single server has been developed.
- A single role which deploys WebSphere and ODM in a single server has been developed.
- The use of IM in this cookbook is incorrect, ideally IM cookbook will be modified to allow for a deployment xml file to be passed instead of the current method which allows for a single set of variables to be passed in.

- This installation requires the IM Repo is updated with the following two new REPOS, they should be merged and unzipped into two new IM Repos.

-- Part Numbers --

Decision Server Rules for Multiplatform
CNM9VML - DSR_MPS_1OF5_IM_REP_V8.9.1.00
CNM9WML - DSR_MPS_2OF5_IM_REP_V8.9.1.01
CNM9XML - DSR_MPS_3OF5_IM_REP_V8.9.1.02
CNM9YML - DSR_MPS_4OF5_IM_REP_V8.9.1.03
CNM9ZML - DSR_MPS_5OF5_IM_REP_V8.9.1.04

Decision Centre for Multiplatform
CNMA0ML - DEC_CENTER_MPS_1OF5_IM_REP_V8.9.1.00
CNMA1ML - DEC_CENTER_MPS_2OF5_IM_REP_V8.9.1.01
CNMA2ML - DEC_CENTER_MPS_3OF5_IM_REP_V8.9.1.02
CNMA3ML - DEC_CENTER_MPS_4OF5_IM_REP_V8.9.1.03
CNMA4ML - DEC_CENTER_MPS_5OF5_IM_REP_V8.9.1.04

WebSphere Profile Templates for WAS Installs only

CNMA9ML - DCP_TEM_WAS_MP_IM_REP_V8.9.1.tar
CNMA8ML - DSRPRO_TEM_WAS_MP_IM_REP_V8.9.1.tar
