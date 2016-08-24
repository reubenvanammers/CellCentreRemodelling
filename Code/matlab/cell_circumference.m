function circumference = cell_circumference(l,C,V);
vertex_list = C{l};
circumference = 0;
nk = length(vertex_list);
for i = 1:nk
    circumference = circumference + norm(V(vertex_list(mod(i,nk)+1),:)-V(vertex_list(i),:));
end