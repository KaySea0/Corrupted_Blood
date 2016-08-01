format shortG;
%data for given simulation
data = [0 2 0; 1 34.5584 32.5584; 2 95.593 61.0346; 3 181.4934 85.9004; 
        4 274.6621 103.1687; 5 393.2821 108.62; 6 501.9399 108.6578; 
        7 604.1662 102.2263; 8 694.8979 90.7317; 9 772.4584 77.5605;
        10 836.4424 63.984; 11 888.8613 52.4189; 12 930.3622 41.5009; 
        13 960.3303 29.9681; 14 980.1061 19.7758; 15 991.5733 11.4672; 
        16 997.1057 5.5324; 17 999.0635 1.9578; 18 999.7112 0.6477];

%matrices used to store values for A/B/C for proposed models
modelA = [];
modelB = [];
modelC = [];

%for each generation (other than 0), compute value of A/B/C
for i=2:19,
   modelA = [modelA; data(i,2)./data(i,3)];
   modelB = [modelB; ((data(i,2)).^2)./data(i,3)];
   modelC = [modelC; log(data(i,3))./data(i,2)];
end

%removes max/min values from list of A vals 
%if data has too high of variance
numRemovalsA = 0;
for i=1:numRemovalsA,
    modelA = modelA(modelA~=max(modelA(:)));
    modelA = modelA(modelA~=min(modelA(:)));
end

%removes max/min values from list of B vals 
%if data has too high of variance
numRemovalsB = 0;
for i=1:numRemovalsB,
    modelB = modelB(modelB~=max(modelB(:)));
    modelB = modelB(modelB~=min(modelB(:)));
end

%removes max/min values from list of C vals 
%if data has too high of variance
numRemovalsC = 1;
for i=1:numRemovalsC,
    modelC = modelC(modelC~=max(modelC(:)));
    modelC = modelC(modelC~=min(modelC(:)));
end

%computes A/B/C-bar from generated list of vals
modelABar = sum(modelA)./length(modelA);
modelBBar = sum(modelB)./length(modelB);
modelCBar = sum(modelC)./length(modelC);
    
%variance calculations for A/B/C lists
varA = 0;
varB = 0;
varC = 0;
for i=1:length(modelA),
    varA = varA + (modelA(i)-modelABar).^2;
end
for i=1:length(modelB),
    varB = varB + (modelB(i)-modelBBar).^2;
end
for i=1:length(modelC),
    varC = varC + (modelC(i)-modelCBar).^2;
end
varA = varA./length(modelA);
varB = varB./length(modelB);
varC = varC./length(modelC);

disp(modelCBar);
disp(varC);

modelAScore = 0; %score for model A (linear)
modelBScore = 0; %score for model B (quadratic)
modelCScore = 0; %score for model C (exponential)
modelDScore = 0; %score for model D (sigmoid)
eq1 = []; % y = (eq1Bar)*(dy/dt)
eq2 = []; % y^2 = (eq2Bar)*(dy/dt)
eq3 = []; % (dy/dt) = e^(eq3Bar*y)
eq4 = []; % sigmoid function (modified to match graph)
for i=0:18,
    val1 = 2.*exp(i./modelABar);
    val2 = (2.*modelBBar)./(modelBBar - 2.*i);
    val3 = -log(exp(-2.*modelCBar) - (modelCBar.*i))./modelCBar;
    val4 = 1000*(1/(1+exp(-(.484*i-3)))); 
    
    modelAScore = modelAScore + (data(i+1,2)-val1).^2;
    modelBScore = modelBScore + (data(i+1,2)-val2).^2;
    modelCScore = modelCScore + (data(i+1,2)-val3).^2;
    modelDScore = modelDScore + (data(i+1,2)-val4).^2;
    
    eq1 = [eq1; i val1];
    eq2 = [eq2; i val2];
    eq3 = [eq3; i val3];
    eq4 = [eq4; i val4];
end

modelAScore = sqrt(modelAScore)./19;
modelBScore = sqrt(modelBScore)./19;
modelCScore = sqrt(modelCScore)./19;
modelDScore = sqrt(modelDScore)./19;

display(modelAScore);
display(modelBScore);
display(modelCScore);
display(modelDScore);

%eq5 - (y/(dy/dt)) = Ae^(Bt) (from data)
eq5 = [];
for i = 2:19,
    val = data(i,2)./data(i,3);
    eq5 = [eq5; i val];
end

%eq6 - attempted model of Ae^(Bt)
eq6 = [];
for i = 1:18,
    val = .0008*exp(.8*i);
    eq6 = [eq6; i val];
end

%eq7 - attempted model for data in (0,7)
eq7 = [];
for i = 0:7,
    val = sqrt(3125*(exp(.8*i)-1)+4);
    eq7 = [eq7; i val];
end

%x/y tables for each data set - used for graphing
pdatax = data(1:19,1);
pdatay = data(1:19,2);
pdatax_1 = data(1:8,1);
pdatay_1 = data(1:8,2);
p1x = eq1(1:19,1);
p1y = eq1(1:19,2);
p2x = eq2(1:19,1);
p2y = eq2(1:19,2);
p3x = eq3(1:19,1);
p3y = eq3(1:19,2);
p4x = eq4(1:19,1);
p4y = eq4(1:19,2);
p5x = eq5(1:18,1);
p5y = eq5(1:18,2);
p6x = eq6(1:18,1);
p6y = eq6(1:18,2);
p7x = eq7(1:8,1);
p7y = eq7(1:8,2);

%plot data
plot(pdatax,pdatay,p4x,p4y); % (x_values,y_values,x_2_values,y_2_values)
legend('actual','attempted model'); % used when plotting >1 graph at once to label each