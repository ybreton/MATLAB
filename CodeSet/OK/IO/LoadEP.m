function [TTL,EVS] = LoadEP(fn)

% [TTL, EVS] = LoadEP(fn) : tsd-obj
%
%
% TTL 16-bit representation (stored as fp doubles) tsd of TTL input
% EVS tsd containing ts and 128 char strings
% NOTE: timestamps returned are in seconds!
%
% Status: PROMOTED

[t, ttl, evs] = LoadEP0(fn);

TTL = tsd(t/1e6, dec2bin(ttl, 16));
EVS = tsd(t/1e6, char(evs'));