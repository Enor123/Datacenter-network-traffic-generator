function [load_matrix,connection_matrix,traffic_matrix]=delta_traffic_matrix_creation_Gauss_Bernoulli(I,T,P,W,load_matrix,connection_matrix,traffic_matrix,load,load_percentage_change,density_incluster,density_outsidecluster,spatial_percentage_change)

% In cluster test matrix
tmp1=ones(W,W);
tmp2=repmat({tmp1},P,1);
localitytest=blkdiag(tmp2{:});

number_of_racks=P*W;
number_of_generic_slots=I*T;

% The new load vector is calculated - the load change is also a Gaussian random variable 
if(load_percentage_change>0)
    % Average number of active connections
    mu=4/pi/load_percentage_change/load_percentage_change;
    % Variance of active connections
    sigma=sqrt(mu);
    flow_matrix=ceil(abs(normrnd(mu,sigma,1,number_of_racks)));
    load_matrix=load/mu*flow_matrix;
else
    % If the load dynamicity equals zero
    load_matrix=load*ones(1,number_of_racks);
    flow_matrix=Inf(1,number_of_racks);
end

% New connections (Bernoulli distributed change)
% Active servers deactivate with a probability p=spatial_percentage_change
% Inactive servers activate with a probability
% q=spatial_percentage_change*density/(1-density)
rand_connection_matrix=rand(number_of_racks);
% Active servers that deactivate in cluster
active_change_matrix_incluster=rand_connection_matrix<=spatial_percentage_change;
active_change_matrix_incluster=(active_change_matrix_incluster.*connection_matrix).*localitytest;
% Inactive servers that activate in cluster
inactive_change_matrix_incluster=rand_connection_matrix<=(spatial_percentage_change*density_incluster/(1-density_incluster));
inactive_change_matrix_incluster=(inactive_change_matrix_incluster.*(1-connection_matrix)).*localitytest;
% Active servers that deactivate outside cluster
active_change_matrix_outsidecluster=rand_connection_matrix<=spatial_percentage_change;
active_change_matrix_outsidecluster=(active_change_matrix_outsidecluster.*connection_matrix).*(1-localitytest);
% Inactive servers that activate in cluster
inactive_change_matrix_outsidecluster=rand_connection_matrix<=(spatial_percentage_change*density_outsidecluster/(1-density_outsidecluster));
inactive_change_matrix_outsidecluster=(inactive_change_matrix_outsidecluster.*(1-connection_matrix)).*(1-localitytest);

% Servers that change state
change_matrix=active_change_matrix_incluster+inactive_change_matrix_incluster+active_change_matrix_outsidecluster+inactive_change_matrix_outsidecluster;
% New state of connections
connection_matrix=xor(connection_matrix,change_matrix);

% New traffic matrix
traffic_matrix=zeros(number_of_racks,number_of_racks);
s_matrix=zeros(number_of_racks,number_of_racks);
for i=1:number_of_racks
    active_racks=sum(connection_matrix(i,:));
    if(active_racks==0)
        % In case a source is inactive
        traffic_matrix(i,:)=0;
    else
        perm=find(connection_matrix(i,:)>0);
        if(flow_matrix(1,i)<10*active_racks)
            % Similar to the initialization
            % A small number of connections is randomly assigned to racks
            idx=randi(active_racks,1,flow_matrix(1,i));
            unqidx=unique(idx);
            countidx=histc(idx,unqidx);
            tmpidx=linspace(1,length(unqidx),length(unqidx));
            s_matrix(i,perm(unqidx(tmpidx)))=s_matrix(i,perm(unqidx(tmpidx)))+countidx(tmpidx);
            traffic_matrix(i,perm)=load_matrix(1,i)*s_matrix(i,perm)*number_of_generic_slots/sum(s_matrix(i,:));
        else
            % A small number of connections is assigned to all racks equally
            s_matrix(i,perm)=load_matrix(1,i)/active_racks;
            traffic_matrix(i,perm)=load*s_matrix(i,perm)*number_of_generic_slots/sum(s_matrix(i,:));
        end
    end
end

% Update the connection matrix
connection_matrix=s_matrix>0;
end