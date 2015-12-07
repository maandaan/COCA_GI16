function [ best_gmm ] = tune_number_of_gaussians( x, k )
% This function tries to find the number of Gaussians (components) for a
% GMM which best fits the model. (by Zeinab Sadeghipour)
% input:
%   x: data to fit gmm
%   k: possible number of components

nK = numel(k);
Sigma = {'diagonal','full'};
nSigma = numel(Sigma);
SharedCovariance = {true,false};
SCtext = {'true','false'};
nSC = numel(SharedCovariance);
RegularizationValue = 0.01;
options = statset('MaxIter',1000);

% Preallocation
gm = cell(nK,nSigma,nSC);
aic = zeros(nK,nSigma,nSC);
bic = zeros(nK,nSigma,nSC);

% Fit all models
for m = 1:nSC
    for j = 1:nSigma
        for i = 1:nK
            try
                gm{i,j,m} = fitgmdist(x,k(i),'CovType',Sigma{j},...
                    'SharedCov',SharedCovariance{m},'Regularize',RegularizationValue,'Options',options);
                aic(i,j,m) = gm{i,j,m}.AIC;
                bic(i,j,m) = gm{i,j,m}.BIC;
            catch
                best_gmm = [];
                return;
            end
        end
    end
    
    [~, ind] = min(aic(:));
    best_gmm = gm{ind};
    
end

