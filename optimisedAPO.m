



function [BestF, BestX, curve] = APO(N, T, lb, ub, dim, fobj)
   PopPos = zeros(N, dim);
   PopFit = zeros(N, 1);
   % Initialize Population
   for i = 1:N
       PopPos(i, :) = rand(1, dim) .* (ub - lb) + lb;
       PopFit(i) = fobj(PopPos(i, :));
   end
   BestF = inf;
   BestX = [];
   for i = 1:N
       if PopFit(i) <= BestF
           BestF = PopFit(i);
           BestX = PopPos(i, :);
       end
   end
   curve = zeros(T, 1);
   %%% Adaptive Parameter Initialization %%% ADDED
   C = 0.5; % Initialize C to 0.5 within [0.3, 0.7] range    
   F = 0.5; % Initialize F to 0.5 within [0.3, 0.7] range
   C_min = 0.3; C_max = 0.7; % Range bounds for C
   F_min = 0.3; F_max = 0.7; % Range bounds for F
   update_interval = 10; % Interval to adapt parameters // DOUBT 
   %% -------------------Start iteration------------------------------------%
   for It = 1:T
       % Adaptive parameter adjustment every few iterations % 




       if mod(It, update_interval) == 0
           % Adjust C based on improvement in best fitness
           if curve(max(1, It - update_interval)) - BestF < 1e-5 % Convergence criterion
               C = max(C - 0.01, C_min); % Decrease C if improving
               F = min(F + 0.01, F_max); % Increase F for exploitation
           else
               C = min(C + 0.01, C_max); % Increase C for exploration
               F = max(F - 0.01, F_min); % Decrease F for independent search
           end
       end
       for i = 1:N
           theta1 = (1 - It / T);
           B = 2 * log(1 / rand) * theta1;
           %% -------------------1. Aerial Flight Stage-------------------%
           if B > 0.5
               while true
                   K = [1:i - 1, i + 1:N];
                   RandInd = K(randi([1, N - 1]));
                   step1 = PopPos(i, :) - PopPos(RandInd, :);
                   if norm(step1) ~= 0 && ~isequal(PopPos(i, :), PopPos(RandInd, :))
                       break;
                   end
               end
               %% -------------------1.1 Aerial search.-------------------%
               Y = PopPos(i, :) + C * Levy(dim) .* step1 + round(0.5 * (0.05 + rand)) * randn; % core exploration term


% when near solution, jump less(cc decreased so lesser jumps)
dynamic C—--also_
               %% -------------------1.2 Swooping predation.-------------------%
               R = rand(1, dim);
               step2 = (R - 0.5) * pi;
               S = tan(step2);   
% tan is increasing fn—>  step2 promotes exploitation
               Z = Y .* S;
               Y = SpaceBound(Y, ub, lb);
               Z = SpaceBound(Z, ub, lb);
               NewPop = [Y; Z];
               NewPopfit = [fobj(Y); fobj(Z)];
               [~, sorted_indexes] = sort(NewPopfit);
               newPopPos = NewPop(sorted_indexes(1), :);
           else
               %% -------------------2. Underwater Foraging Stage-------------------%
               K = [1:i - 1, i + 1:N];
               RandInd = K(randi([1, N - 1], 1, 3));
               f = (0.1 * (rand - 1) * (T - It)) / T;
               while true
                   RandInd = K(randi([1, N - 1], 1, 3));
                   step1 = PopPos(RandInd(2), :) - PopPos(RandInd(3), :);
                   if norm(step1) ~= 0 && RandInd(2) ~= RandInd(3)
                       break;
                   end
               end
               %% -------------------2.1 Gathering foraging-------------------%
               if rand < 0.5
                   W = PopPos(RandInd(1), :) + F .* step1;    %focus on step 1 influence
               else
                   W = PopPos(RandInd(1), :) + F .* Levy(dim) .* step1; 
               end
               %% -------------------2.2 Intensifying search-------------------%
               Y = (1 + f) * W;
               %% -------------------2.3 Underwater Foraging Stage-------------------%
               while true
                   rand_leader_index1 = floor(N * rand() + 1);
                   rand_leader_index2 = floor(N * rand() + 1);
                   X_rand1 = PopPos(rand_leader_index1, :);
                   X_rand2 = PopPos(rand_leader_index2, :);
                   step2 = X_rand1 - X_rand2;
                   if norm(step2) ~= 0 && ~isequal(X_rand1, X_rand2)
                       break;
                   end
               end
               Epsilon = unifrnd(0, 1);
               if rand < 0.5
                   Z = PopPos(i, :) + Epsilon .* step2;
               else
                   Z = PopPos(i, :) + F .* Levy(dim) .* step2;  %focus on step 2 influence                end
               NewPop = [W; Y; Z];
               NewPopfit = [fobj(W); fobj(Y); fobj(Z)];
               [~, sorted_indexes] = sort(NewPopfit);
               newPopPos = NewPop(sorted_indexes(1), :);
           end
           newPopPos = SpaceBound(newPopPos, ub, lb);
           newPopFit = fobj(newPopPos);
           if newPopFit < PopFit(i)
               PopFit(i) = newPopFit;
               PopPos(i, :) = newPopPos;
           end
       end
       for i = 1:N
           if PopFit(i) < BestF
               BestF = PopFit(i);
               BestX = PopPos(i, :);
           end
       end
       curve(It) = BestF;
   end
end

function o = Levy(Dim)
   beta = 1.5;
   sigma = (gamma(1 + beta) * sin(pi * beta / 2) / (gamma((1 + beta) / 2) * beta * 2^((beta - 1) / 2)))^(1 / beta);
   u = randn(1, Dim) * sigma;
   v = randn(1, Dim);
   step = u ./ abs(v).^(1 / beta);
   o = step;
end



end