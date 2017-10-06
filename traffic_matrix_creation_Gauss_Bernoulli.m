function [load_matrix,connection_matrix,traffic_matrix]=traffic_matrix_creation_Gauss_Bernoulli(density_incluster,density_outsidecluster,load,load_percentage_change,I,T,P,W)

number_of_racks=P*W;
number_of_generic_slots=I*T;
number_of_racks_incluster=W;
number_of_racks_outsidecluster=number_of_racks-number_of_racks_incluster;

% Initialization of load
if(load_percentage_change>0)
    % Average number of active connections (flows) - Gaussian appoximation
    mu=4/pi/load_percentage_change/load_percentage_change;
    % Variance of active connections - Gaussian appoximation
    sigma=sqrt(mu);
    flow_matrix=ceil(abs(normrnd(mu,sigma,1,number_of_racks)));
    load_matrix=load/mu*flow_matrix;
else
    load_matrix=load*ones(1,number_of_racks);
    flow_matrix=Inf(1,number_of_racks);
end

% Connection/traffic matrices 
traffic_matrix=zeros(number_of_racks,number_of_racks);
connection_matrix=zeros(number_of_racks,number_of_racks);
s_matrix=zeros(number_of_racks,number_of_racks);

% A fixed (and density defined) number of connections is initially created
% The corresponding load is set on the traffic matrix following the "Independent Connection"
% model
active_racks_incluster=ceil(number_of_racks_incluster*density_incluster);
active_racks_outsidecluster=ceil(number_of_racks_outsidecluster*density_outsidecluster);
active_racks=active_racks_incluster+active_racks_outsidecluster;

for i=1:number_of_racks
    % Randomly select active racks
    perm_incluster=randperm(number_of_racks_incluster,active_racks_incluster);
    perm_outsidecluster=number_of_racks_incluster+randperm(number_of_racks_outsidecluster,active_racks_outsidecluster);
    perm=[perm_incluster,perm_outsidecluster];
    if(flow_matrix(1,i)<10*active_racks)
        % If the number of connections is small then connections are
        % randomly distributed among racks
        idx=randi(active_racks,1,flow_matrix(1,i));
        unqidx=unique(idx);
        countidx=histc(idx,unqidx);
        tmpidx=linspace(1,length(unqidx),length(unqidx));
        s_matrix(i,perm(unqidx(tmpidx)))=s_matrix(i,perm(unqidx(tmpidx)))+countidx(tmpidx);
    else
        % If the number of connections is large then connections are
        % equally distributed among racks
        s_matrix(i,perm)=load_matrix(1,i)/active_racks;
    end
    
    currentcluster=floor((i-1)/number_of_racks_incluster);
    s_matrix(i,:)=circshift(s_matrix(i,:)',currentcluster*number_of_racks_incluster)';
    traffic_matrix(i,:)=load*s_matrix(i,:)*number_of_generic_slots/sum(s_matrix(i,:));
end

% Connection matrix update
connection_matrix=s_matrix>0;
end
