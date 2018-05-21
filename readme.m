%% Cellular Remodelling Code
% This Matlab code repository is to run dynamic discrete cell simulations
% with remodelling via the use of a reference state. This is implemented in
% various ways for both cell centre and vertex based models.

%% Folder Structure
%The linearSpring and vertex folders contain code for running simulations
%for cell centre and linear spring models respectively. shared code that is
%used for both in order to run simulations for both of these is located in
%the generalHelperFunctions folder. The sweeps folder contains a set of
%files to run multiple simulations and create plots of the relevant data.
%Files in the graphFunctions folder are used to work with plots, either
%as useful plot manipulation tools to save to latex, calculate fits of data
%for plotting, or to produce plots by passing in simulation functions as
%arguments and plotting the results. 

%% Cell Centre Models
%Cellular Remodelling has been implemented via cell centre linear spring
%models. Code has been written to for both applying constant stress to the
%righthand side of a monolayer while keeping the left hand fixed, and also
%forcing the monolayer to obey a given stress function. 


% To run a constant stress simulation:
%[Time,Y,Tri,flag]=stress_2d_ode(alpha,eta,T_mem,t_end,gridsize,ext_force,maxstrain)
%Input Variables:
%alpha and eta are parameters of the model, and details are given in the
%paper. T_mem gives the averaging time, with T_mem = 0 for no memory. t_end
%gives the final time of the simulation. 
%Optional Arguments: gridize is a 1*2 vector specifying the dimensions of 
%the monolayer, ext_force is the force applied to the RHS of the monolayer,
%defaulting to 0.2, and maxstrain is a argument to stop the simulation if
%the strain goes above the given value. 

%Output arguments: Time is the output times of the solver, Y is the
%location of the set of points for each time in T for both the real and
%reference states, Tri specifies the mesh of the triangles, and flag is an
%argument giving true if the solver stops prematurely via maxstrain.

%The simulation for both the real and reference states can be visualized
%via the function:
%tri_vis(Time,Y,Tri). eg:
[Time,Y,Tri] = stress_2d_ode(0.5,0.5,0,100);
tri_vis(Time,Y,Tri);

%The strain can also be visualised by passing the function into
%strain_calc with the arguments to be passed in:
%[Time,strain,Y] = strain_calc(fnhandle,varargin)
%eg 
[Time,strain] = strain_calc(@stress_2d_ode,0.5,0.5,0,100);
plot(Time,strain);
%this strain_calc function can take any appropriate function to calculate
%the strains, including for the vertex based solvers. 
%%

%The strain can also be forced on the righthand side of the monolayer with
%a similar function:
%[Time,Y,Tri2,stress_rec] = strain_2d_ode(alpha,eta,T_mem,t_end,strainfunc,t_strain_end,gridsize)
%the arguments are similar to the previous function, but with strainfunc
%giving the function of the strain to force the monolayer into, and
%optional argument t_strain_end to allow the monolayer tor relax after this
%time. Stress_rec records stress experienced on the righthand side of the
%monolayer following this loading. 
%For the stress relaxation experiment, the required force function has been
%implemented via the ramp function ramp(strainmax,reps,reptime), with
%strainmax the maximum strain, reps the number of repetitions of this
%loading (1 for stress relaxation experiment) and reptime is the time it
%takes to fully move to the maximum strainvalue. Eg

[Time,Y,Tri2]=strain_2d_ode(0.5,0.5,0,100,ramp(1.5,1,20));
tri_vis(Time,Y,Tri);

%The strain increases for 20 time units, at which point the righthand side
%of the real state's monolayer stops moving, allowing the system to relax.

%Cyclic loading experiments can be run by choosing an appropriate strain
%function to input into the model, eg a sinusoidal based function. 

%%
%In order to run sweeps of such simulations in order to view compound plots
%to view the behaviour of such simulations, we can run sweep driver files
%for both the creep and strain relaxation experiments.

%For the creep experiment, this is located in the file
%creep_sweep_origtimes.m. This will run the the simulations, and save
%the time-strain data for each parameter combination in a high dimensional
%matlab cell. The data is then fitted with a variety of fits (via the
%CalculateExponentialFits function, and then this information is then used
%to create contour and surface plots of various features, such as the 
%coefficient ratio of the data. 

%To choose the bounds of such a contour sweep, simply change the bounds at
%the start of the file

%fbounds = {-1 0 3}; %F_ext value
%Tbounds = {1 2 2}; %T_mem value
%etabounds = {-1 0 21};
%alphabounds = {-1 0 21};

%The first argument of these bounds is the log10 value of the minimum
%value, the second argument is the log10 of maximum value, and the final
%value is the number of points to sample between these (inclusive) bounds
%in an exponential spacing. Such a sweep is computationally expensive, so
%running this sweep on multiple threads is recommended.

%The indices of the cells of the various data is arranged in the order
%(F_ext,eta,alpha,T_mem), with the index value being the location of the
%given value in the above bound values. 

%This can be done in similar manner for the stress relaxation experiment
%for recording the time-stress values, in the file strain_sweep_origtimes.m.
%This has similar lines for choosing bounds, but with fbounds being
%replaced with 
%Tbounds = {0 2 3}
%with the same syntax as previously.
%Again, various plots, such as for the coefficient ratio for plots
%regarding the time-stress values for the simulations can then be run
%further down in the file.

