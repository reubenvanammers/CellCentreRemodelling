%Varies parameters of stress_2d_ode, and plots time strain graphs in a
%subplot.

endstrain = 1.5;
ramptimevec = [5];
%Tvec = [0 20 100];
T = 50;
etavec = logspace(-1,0,2);
alphavec = logspace(-1,0,2);
tend = 100;
t = length(ramptimevec);g = length(etavec);a = length(alphavec);
L = t*g*a;
stresscell = cell(1,L);
timecell = cell(1,L);
%flagcell = cell(1,L);
%restoringcell = cell(1,L);
parfor_progress(L);
for i = 1:L%index loops over alpha, then eta, then T
    counter = i-1;
    alpha_index = mod(counter,a);
    counter = (counter-alpha_index)/a;
    eta_index = mod(counter,g);
    counter = (counter-eta_index)/g;
    ramptime_index = counter;
    alpha = alphavec(alpha_index+1);
    ramptime = ramptimevec(ramptime_index+1);
    eta = etavec(eta_index+1);%converts linear index to alpha,eta,T
    [Time, Y,~,stress] =strain_2d_ode(alpha,eta,T,tend,ramp(endstrain,1,ramptime),inf,[10,10]);
    N = size(Y,2)/4;
    xvalues = Y(:,1:N);
    %strain = (max(xvalues,[],2)-min(xvalues(1,:)))/(max(xvalues(1,:))-min(xvalues(1,:)));
    stresscell{i} = stress;
    timecell{i} = Time;
    %flagcell{i} = flag;
    parfor_progress;
end
parfor_progress(0);

stresscell2 = cell(t,g,a);
timecell2 = cell(t,g,a);

fit1 = nan*ones(t,g,a,3);
fit2 = nan*ones(t,g,a,5);
error1 = nan*ones(t,g,a);
error2 = nan*ones(t,g,a);
error_fit = nan*ones(t,g,a);

save([pwd '\workspaces\strainerror' num2str(T) '_' num2str(etavec(1)) '-' num2str(etavec(end)) '_' num2str(alphavec(1)) '-' num2str(alphavec(end)) '.mat']);
%%
load([pwd '\workspaces\strainerror' num2str(T) '_' num2str(etavec(1)) '-' num2str(etavec(end)) '_' num2str(alphavec(1)) '-' num2str(alphavec(end)) '.mat']);
maxstraincell = cell(t,g,a);
timeendcell = cell(t,g,a);
stresscell3 = cell(t,g,a);
timecell3 = cell(t,g,a);
for i = 1:L
    counter = i-1;
    alpha_index = mod(counter,a);
    counter = (counter-alpha_index)/a;
    eta_index = mod(counter,g);
    counter = (counter-eta_index)/g;
    time_index = counter;
    vars = {time_index+1,eta_index+1,alpha_index+1};
    straincell2{vars{:}} = straincell{i};
    timecell2{vars{:}} = timecell{i};
    endstresscell{vars{:}} = (stresscell2{vars{:}}(end);
    timeendcell{vars{:}} = 2*timecell2{vars{:}}(find(stresscell2{vars{:}}>(1.1*endstresscell{vars{:}}),1,'last')); %Note: Need to change condition: 90% of the way?
    if  timeendcell{vars{:}} > tend;
        ['Not enough time calculated for variables']
        vars
    end
    timecell3{vars{:}} = linspace(0,timeendcell{vars{:}},1001)';
    stresscell3{vars{:}} = interp1(timecell2{vars{:}},straincell2{vars{:}},timecell3{vars{:}});
end
%%
unable_to_fit = [];
for i = 1:L
    counter = i-1;
    alpha_index = mod(counter,a);
    counter = (counter-alpha_index)/a;
    eta_index = mod(counter,g);
    counter = (counter-eta_index)/g;
    time_index = counter;
    vars = {time_index+1,eta_index+1,alpha_index+1};
%     straincell2{vars{:}} = straincell{i};
%     timecell2{vars{:}} = timecell{i};
    if ~flagcell{i}
        try
            [fit1(vars{:},:),error1(vars{:}),fit2(vars{:},:),error2(vars{:}),error_fit(vars{:})] = CalculateExponentialFits(timecell3{vars{:}}',stresscell3{vars{:}}');
        catch
            unable_to_fit = [unable_to_fit; vars];
        end
    else
        %unable_to_fit = [unable_to_fit; vars];
    end
end


%% plots strain-time graphs and exponential fits

for time_index = 1:t
    figure
    hold on
    for alpha_index = 1:a 
        for  eta_index = 1:g
            subplot(a,g,eta_index-g*(alpha_index)+a*g)
            vars = {time_index,eta_index,alpha_index};
            exp1 = @(x) fit1(vars{:},1) + fit1(vars{:},2)*exp(-x/fit1(vars{:},3));
            exp2 = @(x) fit2(vars{:},1) + fit2(vars{:},2)*exp(-x/fit2(vars{:},3))+ fit2(vars{:},4)*exp(-x/fit2(vars{:},5));
            plot(timecell3{vars{:}},stresscell3{vars{:}},'r',timecell3{vars{:}},exp1(timecell3{vars{:}}),'k--',timecell3{vars{:}},exp2(timecell3{vars{:}}),'b--')
            title(['alpha = ', num2str(alphavec(alpha_index)), ' eta = ', num2str(etavec(eta_index)), ' force = ' num2str(etavec(time_index))]); 
        end
    end
    SaveAsPngEpsAndFig(-1,[pwd '/pictures/creepfitting/strainplot-' num2str(T) '-' num2str(timevec(time_index))]  , 7, 7/5, 9)
end

%%
error_threshold = 1e-5;
colourvec = ['y','m','c','r','b','g','k'];
figure
hold on
[X,Y] = meshgrid(etavec,alphavec);
contours = logspace(-10,10,21);
plot(X,Y,'ko');

for time_index = 1:t
    [~,h(time_index)] = contour(X,Y,reshape(error_fit(time_index,:,:),[g,a])',[error_threshold,error_threshold],colourvec(time_index),'ShowText','off');
    set(gca, 'XScale', 'log', 'YScale', 'log');
end
xlabel('eta');
ylabel('alpha');
title('regions above/right of contours are good fits/have 1 timescale')
legendflex(h,arrayfun(@num2str,timevec,'UniformOutput',false));
SaveAsPngEpsAndFig(-1,[pwd '/pictures/creepfitting/fitcontour-' num2str(T)]  , 7, 7/5, 9)


%%
contours = logspace(-10,10,21);
for time_index = 1:t;
    figure
    [X,Y] = meshgrid(etavec,alphavec);
    hold on;
    plot(X,Y,'k.')
    surf(X,Y,reshape(error_fit(time_index,:,:),[g,a])');
    shading interp;
    alpha(0.5);
    colorbar;
    contour(X,Y,reshape(error_fit(time_index,:,:),[g,a])',contours,'ShowText','on');

    set(gca, 'XScale', 'log', 'YScale', 'log');
    xlabel('eta');
    ylabel('alpha');
    SaveAsPngEpsAndFig(-1,[pwd '/pictures/creepfitting/forcefitcontour-' num2str(T) '-' num2str(timevec(time_index))]  , 7, 7/5, 9)

end

%%
for time_index = 2:2;
    figure
    [X,Y] = meshgrid(1./etavec,alphavec);
    hold on;
    surf(X,Y,reshape(cell2mat(timeendcell(time_index,:,:)),[g,a])');
    shading interp;
    alpha(0.5);
    colorbar;
    contour(X,Y,reshape(cell2mat(timeendcell(time_index,:,:)),[g,a])',contours,'ShowText','on');

    set(gca, 'XScale', 'log', 'YScale', 'log','ZScale','log');
    xlabel('1/eta');
    ylabel('alpha');
    title('equilibriation times')
    SaveAsPngEpsAndFig(-1,[pwd '/pictures/creepfitting/equilibriationtimes-' num2str(T) '-' num2str(timevec(time_index))]  , 7, 7/5, 9)

end
%%
for time_index = 2:2;
    figure
    [X,Y] = meshgrid(etavec,alphavec);
    hold on;
    mesh(X,Y,reshape(cell2mat(maxstraincell(time_index,:,:)),[g,a])');
    shading interp;
    alpha(0.5);
    colorbar;
    contour(X,Y,reshape(cell2mat(maxstraincell(time_index,:,:)),[g,a])',contours,'ShowText','on');

    set(gca, 'XScale', 'log', 'YScale', 'log','ZScale','log');
    xlabel('eta');
    ylabel('alpha');
    title('max strain')
    SaveAsPngEpsAndFig(-1,[pwd '/pictures/creepfitting/equilibriationlenghs-' num2str(T) '-' num2str(timevec(time_index))]  , 7, 7/5, 9)

end
