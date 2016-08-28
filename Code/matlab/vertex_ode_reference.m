function [Time,Y] = vertex_ode_reference(lambda0,beta0,gamma0,alpha0,T0,tend) 
global C connectivitylist F N A0_vec C0_vec lambda beta gamma M alpha t_rec C_rec A_rec T neighbouring_cells

A0=sqrt(3)/2;
%C0 = 2*sqrt(pi*A0);
C0 = 2*sqrt(3);
% lambda = 1;
% beta = 1;
% gamma = 1;
% alpha = 1;
% tend = 50;
lambda = lambda0;beta=beta0;gamma=gamma0;alpha=alpha0;T=T0;

[V,C,connectivitylist,neighbouring_cells] = hexgrid_voronoi();
V_init = V;
N= length(V);
M = length(C);
A0_vec = ones(1,M)*A0;
C0_vec = ones(1,M)*C0;
V(3,1) = V(3,1)+0;
ref_V = V;
V_vec = columnize(V,ref_V);
%V_vec = V_vec(1:2*N);%ignore reference cells for now
F=0;

t_rec = linspace(-T,0)';%sets up averaging vector for each edge
C_rec = C0*ones(100,M);
A_rec = A0*ones(100,M);

options = odeset('RelTol',1e-3,'AbsTol',1e-6);
[Time,Y] = ode15s(@cell_vertex_stress_reference,0:0.2:tend,V_vec,options);
final_hex = Y(end,:)';
[V,V_ref] = matricize(final_hex);
%hex_vis_2(Time,Y,C);



% cell_areas = zeros(1,M);
% cell_circumferences = zeros(1,M);
% for i = 1:M
%     cell_areas(i) = cell_area(i,C,V);
%     cell_circumferences(i) = cell_circumference(i,C,V);
% end
% area_diff = norm(cell_areas-A0);
% circumference_diff = norm(cell_circumferences-C0);
