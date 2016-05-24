function TF = isOK(X)
% Wrapper to conduct test
% ~isnan(X) & ~isinf(X)
% 

TF = ~isnan(X) & ~isinf(X);