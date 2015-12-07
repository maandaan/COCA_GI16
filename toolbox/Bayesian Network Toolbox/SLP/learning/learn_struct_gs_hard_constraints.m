function [dag,best_score] = learn_struct_gs_hard_constraints(data, nodesizes, seeddag, varargin)
%
% LEARN_STRUCT_GS_HARD_CONSTRAINTS(data,seeddag) learns a structure of
% Bayesian net by Greedy Search, without removing the edges in the seeddag
% (by Zeinab Sadeghipour)
% dag = learn_struct_gs(data, nodesizes, seeddag)
%
% dag: the final structurre matrix
% Data : training data, data(i,m) is the m obsevation of node i
% Nodesizes: the size array of different nodes
% seeddag: given seed Dag for hill climbing, optional
%
%
% by Gang Li @ Deakin University (gli73@hotmail.com)

[N ncases] = size(data);
if (nargin < 3 ) 
    seeddag = zeros(N,N); % mk_rnd_dag(N); %call BNT function
elseif ~acyclic(seeddag)
    seeddag = mk_rnd_dag(N); %zeros(N,N);
else
    basedag = seeddag;
end;

% set default params
scoring_fn = 'bic';
verbose  = 'yes';

% get params
args = varargin;
nargs = length(args);
if length(args) > 0
    if isstr(args{1})
    	for i = 1:2:nargs
    		switch args{i}
    		case 'scoring_fn', scoring_fn = args{i+1};
    		case 'verbose',  verbose  = strcmp(args{i+1},'yes');
    		end;
    	end;
    end;
end;

done = 0;
best_score = score_dags(data,nodesizes, {seeddag},'scoring_fn',scoring_fn);
while ~done
    [dags,op,nodes] = mk_nbrs_of_dag(seeddag);
    if (nargin > 2)
        dags = remove_invalid_dags(dags, basedag);
    end
    nbrs = length(dags);
    scores = score_dags(data, nodesizes, dags,'scoring_fn',scoring_fn);
    max_score = max(scores);
    new = find(scores == max_score );
    if ~isempty(new) && (max_score > best_score)
        p = sample_discrete(normalise(ones(1, length(new))));
        best_score = max_score
        seeddag = dags{new(p)}
    else
        done = 1;
    end;
end;

dag = seeddag;

outcount = 0; 
best_score = score_dags(data,nodesizes, {seeddag},'scoring_fn',scoring_fn)
while outcount < 2
    innercount = 0;
    for i=1:N
        for j=1:N
           if i==j, continue;    end;
           if seeddag(i,j) == 0  % No edge i-->j, then try to add it
               tempdag = seeddag;
               tempdag(i,j) = 1;
               if acyclic(tempdag)
                    temp_score = score_dags(data,nodesizes, {tempdag},'scoring_fn',scoring_fn);
                    if temp_score > best_score
                        seeddag = tempdag
                        best_score= temp_score
                        innercount = innercount +1;
                    end;
               end
           elseif basedag(i,j) == 0  % exists edge i--j, then try reverse it or remove it, if it's not in the base_dag, which has the constrained edges
               tempdag = seeddag;
               tempdag(i,j) = 0; tempdag(j,i) = 1; 
               if acyclic(tempdag)
                   temp_score = score_dags(data,nodesizes, {tempdag},'scoring_fn',scoring_fn);
                   if temp_score > best_score
                       seeddag = tempdag
                       best_score = temp_score
                       innercount = innercount +1;
                   else
                       tempdag = seeddag;
                       tempdag(i,j) = 0;
                       temp_score = score_dags(data,nodesizes, {tempdag},'scoring_fn',scoring_fn);
                       if temp_score > best_score
                           seeddag = tempdag
                           best_score= temp_score
                           innercount = innercount +1;
                       end;
                   end;
               else
                   tempdag = seeddag;
                   tempdag(i,j)=0;
                   temp_score = score_dags(data,nodesizes, {tempdag},'scoring_fn',scoring_fn);
                   if temp_score > best_score
                       seeddag = tempdag
                       best_score= temp_score
                       innercount = innercount +1;
                   end;
               end;
           end;
        end; % end for j
    end; % end for i
    if innercount == 0
        outcount = outcount +1;
    end;
end;  % end while

dag = seeddag;
end

function constrained_dags = remove_invalid_dags(dags, init_dag)
% This function removes the dags that do not have the constrained edges in
% the initial dag.

constrained_dags = {}; % 1xn cell
nbrs = length(dags);
size_dag = size(init_dag, 1);
constrained_size = 1;

for did = 1:nbrs
    potential_dag = dags{did};
    valid = 1;
    
    for i = 1:size_dag
        for j = 1:size_dag
            if init_dag(i,j) == 1 && potential_dag(i,j) == 0
                valid = 0;
            end
        end
    end
    
    if valid
        constrained_dags{1,constrained_size} = potential_dag;
        constrained_size = constrained_size + 1;
    end
end
end

