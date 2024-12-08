% Developed in MATLAB R2022b
% Source codes 
% _____________________________________________________
clear  
clc
close all

%% 
N=30; % Number of search agents
T=1000; % Maximum numbef of iterations
F_name='F13'; % Name of the test function

[lb,ub,D,fobj]=Functions_details(F_name);% Load details of the selected benchmark function

[Best_Fitness,Best_Pos,Convergence_curve]=APO(N,T,lb,ub,D,fobj);

%% Display calculation results
display(['The best fitness is:', num2str(Best_Fitness)]);
display(['The best position is:', num2str(Best_Pos)]);


  