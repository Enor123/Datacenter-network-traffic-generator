NEPHELE Traffic Generator

Short Description 
The traffic generator generates Data Center traffic in the form of traffic matrices based on the independent connection model by V. Erramill, M. Crovella, and N. Taft, “An independent-connection model for traffic matrices,” in Proc. ACM SIGCOMM, pp. 267-278, 2006. Traffic is generated at the beginning of each reporting period and each traffic matrix (i,j) entry corresponds to the traffic requirements between a connection of two top-of-rack switches TORi and TORj in the Data center, as measured in timeslots. TOR connections are established or terminated following a Bernoulli ON/OFF model, while the load of connection is approximated Gaussian random variate under the rationale that TORs aggregate a large number of individual connections. 

Description of Functions
Several aspects of the generated traffic can be controlled, including the netwok load, density of connections and the temporal dynamicity in the generated load and spatial distribution of connections. The generator utilizes two functions:

1. function traffic_matrix_creation_Gauss_Bernoulli initializes the traffic matrix. 

The function parameters are as follows:
a. I - number of planes (integer value): number of optical communication planes in the Data Center. 
b. T - number of timeslots (integer value): number of timeslots per reporting period in the Data Center. 
c. P - number of clusters/PODs (integer value): number of clusters that are available in the Data Center. 
d. W - number of wavelengths (integer value): number of wavelengths that are available in the Data Center (one wavelength per TOR at each cluster/POD). 
e. density_incluster (float between 0.0-1.0) is the average density of connections inside the datacenter PODs/clusters.
f. density_outsidecluster (float between 0.0-1.0): the average density of connections between the datacenter PODs/clusters.
g. load (float between 0.0-1.0): the average network load.
h. load_percentage_change (float between 0.0-1.0): the average percentile change in the network load within two successive reporting periods.

The function returns:
a. traffic_matrix: a W*PxW*P float matrix that maintains the traffic requirements (number of timeslots) in connections between TORi and TORj.
b. load_matrix: a W*PxW*P float matrix that maintains the load in connections between TORi and TORj.
c. connection_matrix: a W*PxW*P Boolean matrix that maintains the existence of a connection between TORi and TORj.

2. delta_traffic_matrix_creation_Gauss_Bernoulli generates an updated traffic matrix given the desired dynamicity in load and connection pattern.


The key function parameters are as follows (rest same as above):
a. traffic_matrix: the existing traffic matrix that will be updated.
b. load_matrix: the existing load matrix that will be updated.
c. connection_matrix: the existing connection matrix that will be updated.
d. load_percentage_change (float between 0.0-1.0): the average percentile change in the network load within two successive reporting periods.
e. spatial_percentage_change (float between 0.0-1.0): the average percentile change in the existing connections within two successive reporting periods.

The function returns:
a. traffic_matrix: an updated W*PxW*P float matrix that maintains the new traffic requirements (number of timeslots) in connections between TORi and TORj.
b. load_matrix: an updated W*PxW*P float matrix that maintains the new load in connections between TORi and TORj.
c. connection_matrix: an updated W*PxW*P Boolean matrix that maintains the existence of a connection between TORi and TORj.

The auxiliary Matlab file testgen.m can be used as an example for using the functions and in order to validate that the produced traffic conforms to the required load, densiy and dynamicity.