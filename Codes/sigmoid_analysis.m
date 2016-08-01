%data from simulation
data = [0 2; 1 34.5584; 2 95.593; 3 181.4934; 
        4 274.6621; 5 393.2821; 6 501.9399; 
        7 604.1662; 8 694.8979; 9 772.4584;
        10 836.4424; 11 888.8613; 12 930.3622; 
        13 960.3303; 14 980.1061; 15 991.5733; 
        16 997.1057; 17 999.0635; 18 999.7112];

%%%    
%This script serves to determine an appropriate model for the data above 
%assuming the function (of time t) follows a sigmoidal shape. 
%
%We do this by determining the best value of B in the following function:
%                      y = 1000/(1+e^(-(B*t-3)))
%%%

analysisMat = []; %contains all B values and corresponding score
modelMat = []; %contains values of model at each B-value

B = 0.001;
while (B <= 1)
    modelMat(:) = []; %clears last model's data 
    for j=0:18,
        %%%
        %appends next data point to model matrix; this line can be applied
        %to any desired equation by changing the second element of the 
        %line below
        %%%
        modelMat = [modelMat; 1000./(1+exp(-(B*j-3)))]; 
    end
    
    %score calculation
    modelScore = 0;
    for j=1:19,
        modelScore = modelScore + (data(j,2)-modelMat(j)).^2;
    end
    modelScore = sqrt(modelScore)./length(modelMat);
    
    %adds data from model to matrix for later evaluation
    analysisMat = [analysisMat; B modelScore];
    B = B + .001; %increment B-val
end

disp(analysisMat); %show data from all models