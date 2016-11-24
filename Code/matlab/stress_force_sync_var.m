function F = stress_force_sync_var(t,dxdt)
%adds external force to vertices marked in movelist. averages out restoring
%force and adds it to the external force, so that all vertices move at the
%same speed. Doesn't have external force builtin, so needs to be defined in
%a parent file.
global movelist N external_force restoring_rec 
%external_force = 0.2;
[V,~] = matricize(dxdt);
Vx = V(:,1);
restoring_forces = Vx(movelist,:);
av_restoring_force = mean(restoring_forces);
net_force = external_force+av_restoring_force;
F = columnize([net_force*movelist zeros(N,1)],zeros(N,2));
restoring_rec = [restoring_rec; abs(av_restoring_force)];
% av_restoring_force
% restoring_forces