%COMPUTEEXACTMARGINALSBP Runs exact inference and returns the marginals
%over all the variables (if isMax == 0) or the max-marginals (if isMax == 1). 
%
%   M = COMPUTEEXACTMARGINALSBP(F, E, isMax) takes a list of factors F,
%   evidence E, and a flag isMax, runs exact inference and returns the
%   final marginals for the variables in the network. If isMax is 1, then
%   it runs exact MAP inference, otherwise exact inference (sum-prod).
%   It returns an array of size equal to the number of variables in the 
%   network where M(i) represents the ith variable and M(i).val represents 
%   the marginals of the ith variable. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function M = ComputeExactMarginalsBP(F, E, isMax)

% initialization
% you should set it to the correct value in your code
M = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Implement Exact and MAP Inference.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

P = CreateCliqueTree(F, E);
P = CliqueTreeCalibrate(P, isMax);

N = length(P.cliqueList);

nVars = 0;
vars = [];
for n = 1:N
    for i = 1:length(P.cliqueList(n).var)
        if(~ismember(P.cliqueList(n).var(i), vars))
            nVars = nVars + 1;
            vars(nVars) =  P.cliqueList(n).var(i);
        end
    end
end

M = repmat(struct('var', [], 'card', [], 'val', []), nVars, 1);

if(isMax == 1)
vars = zeros(1, nVars);
nVars = 0;
for n = 1:N
    for i = 1:length(P.cliqueList(n).var)
        if(~ismember(P.cliqueList(n).var(i), vars))
            nVars = nVars + 1;
            currVar = P.cliqueList(n).var(i);
            vars(nVars) =  currVar;
            sumedOutVars = setdiff(P.cliqueList(n).var, P.cliqueList(n).var(i));
            M(currVar) = FactorMaxMarginalization(P.cliqueList(n), sumedOutVars);
        end
    end
end

elseif(isMax == 0)
vars = zeros(1, nVars);
nVars = 0;
for n = 1:N
    for i = 1:length(P.cliqueList(n).var)
        if(~ismember(P.cliqueList(n).var(i), vars))
            nVars = nVars + 1;
            currVar = P.cliqueList(n).var(i);
            vars(nVars) =  currVar;
            sumedOutVars = setdiff(P.cliqueList(n).var, P.cliqueList(n).var(i));
            M(currVar) = FactorMarginalization(P.cliqueList(n), sumedOutVars);
            M(currVar).val = M(currVar).val / sum(M(currVar).val);
        end
    end
end
end
