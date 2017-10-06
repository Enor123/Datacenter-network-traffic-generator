I=2; %number of planes 
P=2; %number of pods
W=8; %number of wavelengths 
T=8; %number of slots/period 

rng('shuffle');

% Synthetic traffic parameters
density_incluster=0.05;
density_outsidecluster=0.5;
density=density_incluster/P+density_outsidecluster*(P-1)/P;
spatial_percentage_change=0.01;
load=0.9;
load_percentage_change=0.01;

% Measurement variables
avgload=0;
avgdensity=0;
avgdensityin=0;
avgdensityout=0;
avgconnectionschange=0;
avgloadchange=0;

% A block diagonal matrix that helps measure connections in cluster and
% outside cluster
tmp1=ones(W,W);
tmp2=repmat({tmp1},P,1);
localitytest=blkdiag(tmp2{:});
localitytestmirror=1-localitytest;

% Output file
fid = fopen('generator_output.dat', 'wt'); 
fprintf(fid, 'Number of planes: %d \n',I);
fprintf(fid, 'Number of PODs/Clusters: %d \n',P);
fprintf(fid, 'Number of Wavelengths: %d \n',W);
fprintf(fid, 'Number of Timeslots: %d \n',T);
fprintf(fid, 'Load and load dynamiciy: %e %e \n',load,load_percentage_change);
fprintf(fid, 'Density (inside, outside cluster) and connection dynamiciy: %e %e %e\n\n',density_incluster,density_outsidecluster,spatial_percentage_change);


% Initialization: a traffic matrix with the desired "density" and "load" is created
[load_matrix,connection_matrix,traffic_matrix]=traffic_matrix_creation_Gauss_Bernoulli(density_incluster,density_outsidecluster,load,load_percentage_change,I,T,P,W);
summatrix=traffic_matrix;

% Remove comments if you need to visually check generated traffic per timeslot
% measuredload=sum(sum(traffic_matrix))/W/P/I/T
% measureddensityin=nnz(traffic_matrix.*localitytest)/nnz(localitytest)
% measureddensityout=nnz(traffic_matrix.*localitytestmirror)/nnz(localitytestmirror)
% measureddensity=nnz(traffic_matrix)/W/P/W/P

% Number of succesive times that traffic is generated
times=100;
for i=1:times
    old_load_matrix=load_matrix;
    old_connection_matrix=connection_matrix;
    old_traffic_matrix=traffic_matrix;
    
    % The new traffic matrix is generated 
    [load_matrix,connection_matrix,traffic_matrix]=delta_traffic_matrix_creation_Gauss_Bernoulli(I,T,P,W,load_matrix,connection_matrix,traffic_matrix,load,load_percentage_change,density_incluster,density_outsidecluster,spatial_percentage_change);
    
    % Load and connection dynamicity calculation for cross checking
    avgloadchange=avgloadchange+sum(abs(load_matrix-old_load_matrix))/W/P;
    avgconnectionschange=avgconnectionschange+nnz(xor(old_connection_matrix,connection_matrix))/W/P/W/P;
    
    % Density and load calculation for crosschcking
    measuredload=sum(sum(traffic_matrix))/W/P/I/T;
    measureddensity=nnz(traffic_matrix)/W/P/W/P;
    measureddensityin=nnz(traffic_matrix.*localitytest)/nnz(localitytest);
    measureddensityout=nnz(traffic_matrix.*localitytestmirror)/nnz(localitytestmirror);
    
    % Intermidiate average value calculation
    avgload=avgload+measuredload;
    avgdensity=avgdensity+measureddensity;
    avgdensityin=avgdensityin+measureddensityin;
    avgdensityout=avgdensityout+measureddensityout;
    
    % Output to file
    fprintf(fid, 'Traffic Matrix (timeslot %d) \n',i);    
    for j=1:size(traffic_matrix,1)
        fprintf(fid, '%2.2e ', traffic_matrix(j,:));
        fprintf(fid, '\n');
    end
    fprintf(fid, '\n');
    
end

% Average value calculation 
avgdensity=avgdensity/times
avgdensityin=avgdensityin/times
avgdensityout=avgdensityout/times
avgload=avgload/times
avgconnectionschange=avgconnectionschange/times/density/2
avgloadchange=avgloadchange/times/load

% Output to file
fprintf(fid, '\nMeasured load and load dynamiciy: %e %e \n',avgload,avgloadchange);
fprintf(fid, 'Measured density (inside, outside cluster) and connection dynamiciy: %e %e %e\n\n',avgdensityin,avgdensityout,avgconnectionschange);
fclose(fid);
