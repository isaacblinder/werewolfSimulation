%begin program
%this function simulates the outbreak of a werewolf epidemic and
%returns the final result. 0=undecided 1=win(for villagers) 2=loss
%PARAMS
%docs, wolves, village = initial num of doctors, werewolves and villagers.
%printInfo = print interesting stats, as well as plot graph
%cMax = clockMax (max number of days for simulation loop)
function result = epidemicProj(docs, wolves, village, cMax, printInfo)
    if printInfo == 1
        disp('Single Loop Summary:');
    end
    %variables
    result = 0; % default result is tie
    S = village + docs; %initial num healthy people
    I = wolves; %initial num werewolves     
    beta1 = 0.0002; %birth rate for villagers (a village of 1000 will have about 1 child every 5 days)
    beta2 = 0.0004; %birth rate for werewolves
    delta1  = 0.00015; %death rate for villagers
    delta2  = 0; %death rate for werewolves
  
    
    %initial chance of infection through drinking contaminated water
    aWater = 0;
    
    %simple stats
    rainCount = 0; %number of rainy days
    moonCount = 0; %number of full moons
    byWater = 0; %num infected by water
    byBite = 0; %num infected by a bite
    biggestDay = 0; %most infected in one day

    %each step is one day.
    clockmax = cMax;

    
    %arrays save values for graphing
    if printInfo == 1
        tsave = zeros(1,clockmax);
        Ssave = zeros(1,clockmax);
        Isave = zeros(1,clockmax);
        Dsave = zeros(1,clockmax);
    end

    %loop beginning
    for clock = 1 : clockmax
        %variables
        raining = false;
        fullMoon = false;
        
        S2I = 0; %number of villagers getting infected this loop
        D2I = 0; %number of doctors getting infected this loop
        
        Sdie = 0; %villagers that die
        Idie = 0; %werewolves that die
        Sborn = 0; %villagers that are born
        Iborn = 0; %werewolves that are born
        
        N = S + I; %total num of people (including werewolves)
        
        if aWater > 0
        aWater = aWater - .015; end %chance of getting infected by water is reduced every day there isn't rain

       %a new doctor is trained every week
        if mod(clock,7) == 0
            docs = docs + 1; 
        end 

        %chance of rain is seasonal
        %rainy season (1/4 of yr)
        if mod(clock,365) < 91
            rainChance = .20;
        %reg season (1/2 of yr)
        elseif mod(clock,365) < 273
            rainChance = .08;
        %dry season (1/4 of yr)
        else
            rainChance = .04;
        end

        %finally, use randomness to decide if it is raining
        if rand < rainChance
            raining = true; 
            aWater = .1; %10 percent chance of becoming werewolf if villager drinks contaminated water
            rainCount = rainCount + 1;
        end


        %full moon is every thirty days (middle of every month)
        if mod(clock,30) == 15
            fullMoon = true; 
            moonCount = moonCount + 1;  
        end     


        
        %natural births and deaths
        for s = 1:S
            if rand < beta1
                Sborn = Sborn+1;
            elseif rand < delta1
                if rand < docs/S %see if a doctor is the one whos dying
                    D2I = D2I+1;
                else
                    Sdie = Sdie+1;
                end
            end
        end
        
        for i = 1:I
            if rand < beta2
                Iborn = Iborn+1;
            elseif rand < delta2
                Idie = Idie+1;
            end
        end
                
        
        
        %Infections (S2I and D2I)
        

        %water infections
        %chance of these infections is increased by rainfall 
        %and by total number of werewolves (because then more werewolves are drinking water) 
        for s = 1:S
            if rand < aWater * I/N %true = gets infected
                byWater = byWater+1;
                %check if the person getting infected is a doctor
                    if rand < docs/S
                        D2I = D2I + 1;
                    else
                        S2I = S2I + 1;
                    end
            end
        end

        %werewolves hunt villagers at night. 
        %chance of getting infected by bite (can only happen on full moon)
        %the individual chance of a werewolf catching and biting someone is reduced when there
        %are less villagers left, however there will be more werewolves overall
        %someone who is bit has 25% chance of dying, 65% chance of becoming a werewolf, and 10% chance of nothing happening.
        oddsOfCatch = (S-S2I-D2I)/N;
        %if it is currently raining the werewolf has less of a chance of catching and biting someone
        if raining
            oddsOfCatch = oddsOfCatch/2; end
        if oddsOfCatch > 1
            oddsOfCatch = 1; end

        if fullMoon
            for i = 1:I
                if rand < oddsOfCatch 
                    r = rand;
                    if r < 0.65 %a bite that turns the person into werewolf
                        byBite = byBite +1;
                        %check if the person getting infected is a doctor
                        if rand < docs/S 
                            D2I = D2I+1;
                        else
                            S2I = S2I + 1;
                        end
                    elseif r < 0.90 %a bite that kills the person
                        if rand < docs/S %see if a doctor is the one whos dying
                            D2I = D2I+1;
                        else
                            Sdie = Sdie+1;
                        end
                    end
                   %there remains a 10percent chance nothing will happen to the person from
                   %the bite
                end
            end
        end

        %update number of doctors left
        docs = docs - D2I;
        %every remaining doctor can give the vaccine to 10 random people each day (except full moons).
        %the odds of the doctor administering the vaccine to a werewolf is I/N
        %the odds of the vaccine working is 20%
        I2S = 0;
        if ~fullMoon
            for d = 1:docs
                for i = 1:10
                    if rand < I/N
                        if rand < 0.2
                            I2S = I2S + 1; 
                        end
                    end
                end
            end
        end


        %update variables S, I, and docs
        S = S - S2I + I2S - D2I - Sdie + Sborn;
        I = I + S2I - I2S + D2I - Idie + Iborn;

        %update biggest infection day variable
        if S2I + D2I > biggestDay
            biggestDay = S2I + D2I;
        end

        %save values for graphing
        if printInfo == 1
            tsave(clock) = clock;
            Ssave(clock) = S;
            Isave(clock) = I;
            Dsave(clock) = docs;
        end
        
        %checking break conditions
        %check if the werewolves have won
        if S <= 0
            result = 2;
            if printInfo == 1
                disp('all hope is lost!')
                fprintf('days survived = %d\n', clock);
            end
            break
        end

        %check if the villagers have won
        if I <= 0
            result = 1;
            if printInfo == 1
                disp('we are saved!')
                fprintf('num of days = %d\n', clock);
            end
            break
        end 
    %loop end
    end

    %print this if the loop ends without a winner
    if I > 0 && S > 0 && printInfo == 1
        disp('weve survived! (for now..)'); 
        fprintf('num of villagers left = %d\n', S);
        fprintf('num of infected left = %d\n', I);
    end

    %print some summary stats
    if printInfo == 1
        fprintf('num of rainy days = %d\n', rainCount);
        fprintf('num of full moons = %d\n', moonCount);
        fprintf('num of people infected by water = %d\n', byWater);
        fprintf('num of people infected by bites = %d\n', byBite);
        fprintf('most infected in one day = %d\n', biggestDay);
        
        %plot the graph
        plot(tsave, Ssave, tsave, Isave);
        legend('Villagers', 'Werewolves'); 
        xlabel('days'); ylabel('population');
        title('Werewolf Simulation');
    end
end
%end program
