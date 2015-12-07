%CLIQUETREECALIBRATE Performs sum-product or max-product algorithm for 
%clique tree calibration.

%   P = CLIQUETREECALIBRATE(P, isMax) calibrates a given clique tree, P 
%   according to the value of isMax flag. If isMax is 1, it uses max-sum
%   message passing, otherwise uses sum-product. This function 
%   returns the clique tree where the .val for each clique in .cliqueList
%   is set to the final calibrated potentials.
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function P = CliqueTreeCalibrate(P, isMax)


% Number of cliques in the tree.
N = length(P.cliqueList);

% Setting up the messages that will be passed.
% MESSAGES(i,j) represents the message going from clique i to clique j. 
MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% We have split the coding part for this function in two chunks with
% specific comments. This will make implementation much easier.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% YOUR CODE HERE
% While there are ready cliques to pass messages between, keep passing
% messages. Use GetNextCliques to find cliques to pass messages between.
% Once you have clique i that is ready to send message to clique
% j, compute the message and put it in MESSAGES(i,j).
% Remember that you only need an upward pass and a downward pass.
%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = length(P.cliqueList);

%%
if (isMax == 0)
for k = 1 : 2 * (N - 1)
    [i, j] = GetNextCliques(P, MESSAGES);
    orderedEdges(k,:) = [i, j];
    if (i == 0)
        dddd= 1;
    end
    allNeighborsExJ = setdiff(find(P.edges(i,:)), j);
    
    sepset = intersect(P.cliqueList(i).var, P.cliqueList(j).var);
    sumedOutVars = setdiff(P.cliqueList(i).var, sepset);
    
    if (isempty(allNeighborsExJ))
        MESSAGES(i, j) = FactorMarginalization(P.cliqueList(i), sumedOutVars);
    else
        J = ComputeJointDistribution(MESSAGES(allNeighborsExJ, i));
        Joint = FactorProduct(P.cliqueList(i), J);
        MESSAGES(i, j) = FactorMarginalization(Joint, sumedOutVars);
    end
    MESSAGES(i, j).val = MESSAGES(i, j).val / sum(MESSAGES(i, j).val);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Now the clique tree has been calibrated. 
% Compute the final potentials for the cliques and place them in P.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n = 1:N
    allNeighbors = P.edges(n,:) == 1;
    J = ComputeJointDistribution(MESSAGES(allNeighbors, n));
    P.cliqueList(n) = FactorProduct(P.cliqueList(n), J);
end


%%
elseif(isMax == 1)
    
for n = 1:N
    P.cliqueList(n).val = log(P.cliqueList(n).val);
end

for k = 1 : 2 * (N - 1)
    [i, j] = GetNextCliques(P, MESSAGES);
    
    allNeighborsExJ = setdiff(find(P.edges(i,:)), j);
    
    sepset = intersect(P.cliqueList(i).var, P.cliqueList(j).var);
    sumedOutVars = setdiff(P.cliqueList(i).var, sepset);
    
    if (isempty(allNeighborsExJ))
        MESSAGES(i, j) = FactorMaxMarginalization(P.cliqueList(i), sumedOutVars);
    else
        J = ComputeAllSums(MESSAGES(allNeighborsExJ, i));
        Joint = FactorSum(P.cliqueList(i), J);
        MESSAGES(i, j) = FactorMaxMarginalization(Joint, sumedOutVars);
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Now the clique tree has been calibrated. 
% Compute the final potentials for the cliques and place them in P.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n = 1:N
    allNeighbors = P.edges(n,:) == 1;
    J = ComputeAllSums(MESSAGES(allNeighbors, n));
    P.cliqueList(n) = FactorSum(P.cliqueList(n), J);
end

end
return
