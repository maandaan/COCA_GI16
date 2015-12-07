%COMPUTEINITIALPOTENTIALS Sets up the cliques in the clique tree that is
%passed in as a parameter.
%
%   P = COMPUTEINITIALPOTENTIALS(C) Takes the clique tree skeleton C which is a
%   struct with three fields:
%   - nodes: cell array representing the cliques in the tree.
%   - edges: represents the adjacency matrix of the tree.
%   - factorList: represents the list of factors that were used to build
%   the tree. 
%   
%   It returns the standard form of a clique tree P that we will use through 
%   the rest of the assigment. P is struct with two fields:
%   - cliqueList: represents an array of cliques with appropriate factors 
%   from factorList assigned to each clique. Where the .val of each clique
%   is initialized to the initial potential of that clique.
%   - edges: represents the adjacency matrix of the tree. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function P = ComputeInitialPotentials(C)

% number of cliques
N = length(C.nodes);

% initialize cluster potentials 
P.cliqueList = repmat(struct('var', [], 'card', [], 'val', []), N, 1);
P.edges = zeros(N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% First, compute an assignment of factors from factorList to cliques. 
% Then use that assignment to initialize the cliques in cliqueList to 
% their initial potentials. 

% C.nodes is a list of cliques.
% So in your code, you should start with: P.cliqueList(i).var = C.nodes{i};
% Print out C to get a better understanding of its structure.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

P.edges = C.edges;
numFactors = length(C.factorList);

%%
V = unique([C.factorList.var]);
% Setting up the cardinality for the variables since we only get a list 
% of factors.
T.card = zeros(1, length(V));
for i = 1 : length(V),

	 for j = 1 : numFactors
		  if (any(C.factorList(j).var == i))
				T.card(i) = C.factorList(j).card(find(C.factorList(j).var == i));
				break;
		  end
	 end
end

%%
alpha = zeros(numFactors, 1);
for k = 1:numFactors
    for n = 1:N
        if(all(ismember(C.factorList(k).var, C.nodes{n})))
            alpha(k) = n;
            break;
        end
    end
end

%%
for n = 1:N
    P.cliqueList(n).var = C.nodes{n};
    P.cliqueList(n).card = T.card(C.nodes{n});
    P.cliqueList(n).val = ones(1, prod(P.cliqueList(n).card));
    if(any(alpha == n))
        Joint = ComputeJointDistribution(C.factorList(alpha == n));
        P.cliqueList(n) = FactorProduct(P.cliqueList(n), Joint);
    end
end


