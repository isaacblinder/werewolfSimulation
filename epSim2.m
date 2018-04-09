%begin program

%simulation params

docs = 10;
wolves = 10;
villagers = 1000;
clockMax = 365*10;
printInfo = 0;
loops = 100;

%summary stats
wins  = 0;
losses = 0;
undecided = 0;


for i = 1:loops
   printInfo = 0;
   if i == loops %on the last loop print info and plot graph
       printInfo = 1;
   end
   
   result = epidemicProj(docs, wolves, villagers, clockMax, printInfo);
   if result == 0
       undecided = undecided+1;
   elseif result == 1
       wins = wins+1;
   elseif result == 2
       losses = losses+1;
   end
end

disp(' ');
disp('Full Simulation Summary:');
fprintf('num of rounds = %d\n', loops);
fprintf('num of wins = %d\n', wins);
fprintf('num of losses = %d\n', losses);
fprintf('num of undecided = %d\n', undecided);
%end program