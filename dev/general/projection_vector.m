function proj = projection_vector(v,u)
% Projection of vector v onto u.
%
%
%

proj = dot(v,u)/dot(u,u)*u;