%initial conditions
pop = 1000; % total population of area
bomb = 2; % number of initial infected
r = .6; % radius of infection
numSteps = 80; % number of generations to simulate
numIterations = 1; % number of times to repeat simulation

  %plot graph / modify area to get desired lambda
  R = unifrnd(0,1,pop,2);
  pproc = R*10;
  plot(pproc(:, 1), pproc(:, 2), '.');
  grid on

A_ij = cell(10); %creates a 10x10 matrix of matrices
%%%
%this loop places points into bins based on where they fall on the PPP 
%graph; based on the 10x10 division displayed on graph
%%%
for i=1:pop,
       A_ij{(floor(pproc(i,1))+1),(floor(pproc(i,2))+1)} = ...
       [A_ij{(floor(pproc(i,1))+1),(floor(pproc(i,2))+1)}; pproc(i,1) ...
       pproc(i,2)];
end

S = []; %will contain average distance between points for each bin
for i=1:10,
   for j=1:10,
       nextList = A_ij{i,j}; %gets single bin for analysis
       nextS = 0; %average distance between points for one bin
       
       %%%
       %These loops run through each point and finds the distance between
       %a point and every other point in the matrix and sums these values
       %together
       %%%
       for k=1:size(nextList,1),
          for m=1:size(nextList,1),
              nextS = nextS + sqrt((nextList(k,1)-nextList(m,1)).^2 + ...
              (nextList(k,2)-nextList(m,2)).^2);
          end
       end
       %finalizes average value of distance between points
       nextS = nextS ./ (factorial(length(nextList))./ ...
                       (factorial(length(nextList)-2))); 
       S = [S; nextS]; %add average to overarching matrix of averages
   end
end

S_avg = mean(S); %compute average of averages
display(S_avg);
  
%set all players to uninfected initially
toAdd = zeros(1,pop)';
%%%
%this table contiains the core data of each person including their (x,y)
%coordinates and infection state.
%%%
analysis = [pproc toAdd]; 

averages = []; % pre-allocated for final data collection

%main simulation loop
for iter=1:numIterations,
    %%%
    %sets all people as infected at the start of each iteration
    %to effectively reset the simulation
    %%%
    analysis(:,3) = 0;
    initialI = randi([1,pop],1,bomb); % randomly choose infected from population

    % 0 --> not infected
    % 1 --> infected, past feasible generation
    % 2 --> infected, to be added to next generation
    % 3 --> infected, current generation
    for i=1:bomb,
        analysis(initialI(i),3) = 3; % set chosen people as infected
    end

    infected = bomb; % tracks number of infected through each generation
    %%%
    %this table is used to track the number of infected for the current 
    %generation of the simulation; the average of these values over
    %each iteration makes up the final "averages" table
    %%%
    iTable = [0,infected]; 

    for step=1:numSteps,
        for i=1:pop,
            if analysis(i,3) == 3 % if selected person is infected
                for j=1:pop,
                    if j ~= i && analysis(j,3) == 0 % if selected person is not infected
                        %%%
                        %following two lines used to simplify Eulcidean
                        %distance calculation
                        %%%
                        xDif = (analysis(i,1)-analysis(j,1)).^2;
                        yDif = (analysis(i,2)-analysis(j,2)).^2;
                        if sqrt(xDif+yDif) <= r % if selected person is within infection radius
                            infected = infected + 1; % add to number of infected
                            analysis(j,3) = 2; % set new infected to be node in next generation
                        end
                    end
                end
                %%%
                %after a person has been infected everything in its radius,
                %it no longer needs to be checked. therefore, they are put
                %in the "1" state and will not be processed in any
                %following generations
                %%%
                analysis(i,3) = 1; 
            end
        end 
        nextGen = [step,infected]; %groups together informaion about generation
        iTable = [iTable; nextGen]; %add last generation to iteration table

        for i=1:pop,
            if analysis(i,3) == 2
                %%%
                %if a person was infected within the current generation
                %(signified by the "2" state), then they are set to the "3"
                %state and will be checked in the following generation as
                %an infection node
                %%%
                analysis(i,3) = 3;
            end
        end

		%%%
		%this section is used to produce graphs of the simulation's map
		%of nodes at designated generations; these graphs signify 
		%infected persons as red and healthy persons as green
		%%%
		
		%set which generations to produce graphs
        if step == 20 || step == 40 || step == 60 || step == 80
            healthyPop = []; %will contain all healthy nodes
            infectedPop = []; %will contain all infected nodes
            for i=1:pop,
				%add nodes to correct lists based on infection status
                if analysis(i,3) == 0,
                    healthyPop = [healthyPop; analysis(i,1) analysis(i,2)];
                else
                    infectedPop = [infectedPop; analysis(i,1) analysis(i,2)];
                end
            end

			%generates name for graph based on generation and simulation settings;
			%all of this information must be set manually and known beforehand
			
			%beginning of file name designates infection scenario (percolation theory)
            fileName = 'super_crit_gen_';
            %concatenate generation number to end of file name
			if step == 20
                fileName = strcat(fileName,'20');
            elseif step == 40
                fileName = strcat(fileName,'40');
            elseif step == 60
                fileName = strcat(fileName,'60');
            elseif step == 80
                fileName = strcat(fileName,'80');
            end

			%if all nodes are infected, only worry about graphing infected nodes
            if isempty(healthyPop)
                plot(infectedPop(:,1), infectedPop(:,2), 'r.');
                grid off
            %if mix of healthy and infected nodes present, graph both with color
			else
                plot(healthyPop(:,1), healthyPop(:,2), 'g.', ...
                     infectedPop(:,1), infectedPop(:,2), 'r.');
                grid off
            end
            
			%save file to local directory where this script is saved
            saveas(gcf,fileName,'jpg');
        end 
    end
    
	%adds generation to total infected table component-wise
    if size(averages) == [0,0]
        averages = iTable;
    else
        averages = averages + iTable;
    end
end

%compute average value of each generation
averages = averages./numIterations;

%find change in infected over each generation
delta = [0];
for i=1:numSteps,
    delta = [delta; (averages(i+1,2)-averages(i,2))];
end

averages = [averages delta];

%display data
format shortG;
display(averages);
