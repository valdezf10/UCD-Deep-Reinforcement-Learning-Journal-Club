%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Description: this is a script to create a 10-armed bandit problem using %
%             the epsilon-greedy and UCB algoritmhs to reproduce fig. 2.4 %
%             from the RL book by Richard Sutton.                         %                     
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear;
tic

% Parameters
k = 10;         % total number of k-armed bandits
runs = 2000;    % total number of runs
steps = 1000;   % total number of steps
epsilon = 0.1;  % exploration probability in epsilon-greedy 
c = 2;          % degree of exploration in UCB

% Initialization
Reward1_sum = zeros(steps,1); 
Reward2_sum = zeros(steps,1); 

% Start the iteration
for test = 1:runs
    q_true = randn(k,1);       % true action values
    [~, qStar] = max(q_true);  % select best (greedy) action
    
    q_actual = @(a) q_true(a) + randn(1); % a normal distibution with q_true(a) mean and unity variance

%% 1) Epsilon-Greedy Method
        [Reward] = egreedy(epsilon, k, steps, q_actual);
   
        Reward1_sum(:,:) = Reward1_sum(:,:) + Reward;
    
%% 2) Upper-Confidence-Bound Method
        [Reward] = UCB(c, k, steps, q_actual);
    
        Reward2_sum(:,:) = Reward2_sum(:,:) + Reward;
        
end

% Take the average reward over total number of runs
Reward1_avg = Reward1_sum / runs;
Reward2_avg = Reward2_sum / runs;

%% Plot
close all

figure
hold on
plot(Reward1_avg(:,1),'r-')
plot(Reward2_avg(:,1),'b-')
hold off
xlabel('Steps')
ylabel('Average reward')
legend(['\epsilon-greedy',' with \epsilon=',num2str(epsilon)],['UCB',' with c=',num2str(c)],'Location','Southeast')

toc
%% Epsilon-Greedy Function

function [Reward] = egreedy(epsilon, k, steps, q_actual)

% Initialization
Q = zeros(k,1);      % sample-average 
N = zeros(k,1);      % number of selections
Reward = zeros(steps,1); % reward history

for t = 1:steps
    % (1-?) exploration , (?) exploitation
    if rand <= epsilon
        action = randi(k,1);
    else
        [~,action] = max(Q);
    end
  
    reward  = q_actual(action);

    N(action) = N(action) + 1;
    Q(action) = Q(action) + 1/N(action)*(reward - Q(action));
    
    Reward(t) = reward;
end

end

%% Upper Confidence Bound Function

function [Reward] = UCB(c, K, steps, q_actual)
% Upper-Confidence-Bound Action Selection

% Initialization
Q      = zeros(K,1); % sample-average 
N      = zeros(K,1); % number of selections
Reward = zeros(steps,1); % reward history

for t = 1:steps
    if t <= K
        action = t;
    else
        [~,action] = max(Q + c.*sqrt(log(t)./N));
    end
  
    reward  = q_actual(action);

    N(action) = N(action) + 1;
    Q(action) = Q(action) + 1/N(action)*(reward - Q(action));
    
    Reward(t) = reward;
end

end