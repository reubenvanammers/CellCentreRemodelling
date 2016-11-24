function F = stress_force_sync(t,dxdt)
%adds external force to vertices marked in movelist. averages out restoring
%force and adds it to the external force, so that all vertices move at the
%same speed. 
global movelist N external_force restoring_rec 
if isempty(external_force) %default value of external force if no previous value is defined. 
    external_force = 0.2;
end

[V,~] = matricize(dxdt);
Vx = V(:,1);
restoring_forces = Vx(movelist,:);
av_restoring_force = mean(restoring_forces);
net_force = external_force+av_restoring_force;
F = columnize([net_force*movelist zeros(N,1)],zeros(N,2));
restoring_rec = [restoring_rec; abs(av_restoring_force)];
% av_restoring_force
% restoring_forces