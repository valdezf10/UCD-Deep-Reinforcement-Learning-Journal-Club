%% Example 6.6 (Q-learning)
clc,clear,close all

% Initialization
N_episode   = 30000;
epsilon     = 0.1;
gamma       = 1;
state0      = [1,1];
goal        = [1,12];
Q           = zeros(4,12,4);
reward_sum  = [];

%% Sarsa
for i = 1:N_episode
    current_state = state0;
    action = take_action(Q, current_state, epsilon);
    tmp = 0;
    while ~isequal(current_state, goal)
        [next_state, reward] = cliff_gridworld(current_state, action);
        next_action = take_action(Q, next_state, epsilon);

        Q(current_state(1),current_state(2),action) = Q(current_state(1),current_state(2),action) + ...
                                                    0.5*(reward + gamma*Q(next_state(1),next_state(2),next_action) - Q(current_state(1),current_state(2),action));     

        current_state = next_state;  
        action = next_action;
        tmp = tmp + reward;
    end
    reward_sum = [reward_sum,tmp];
end

%% Q-learning
Q2           = ones(4,12,4)*(-1e6);
Q2(1,12,:)   = 0;
reward_sum2  = [];
for i = 1:N_episode
    current_state = state0;
    tmp = 0;
    while ~isequal(current_state, goal)
        action = take_action(Q2, current_state, epsilon);
        [next_state, reward] = cliff_gridworld(current_state, action);
        
        Q2(current_state(1),current_state(2),action) = Q2(current_state(1),current_state(2),action) + ...
                                                       1*(reward + gamma*max(Q2(next_state(1),next_state(2),:)) - Q2(current_state(1),current_state(2),action));     

        current_state = next_state;  
        tmp = tmp + reward;
    end
    reward_sum2 = [reward_sum2,tmp];
end

%
figure(1)
hold on
current_state = state0;
State = current_state;
H = plot(current_state(2),current_state(1),'b-*');
while ~isequal(current_state, goal)
    action = take_action(Q, current_state, epsilon);
    [current_state, reward] = cliff_gridworld(current_state, action);
    State = [State; current_state];
    H.XData = [H.XData, current_state(2)];
    H.YData = [H.YData, current_state(1)];
end

current_state = state0;
State = current_state;
H2 = plot(current_state(2),current_state(1),'r-*');
while ~isequal(current_state, goal)
    action = take_action(Q2, current_state, epsilon);
    [current_state, reward] = cliff_gridworld(current_state, action);
    State = [State; current_state];
    H2.XData = [H2.XData, current_state(2)];
    H2.YData = [H2.YData, current_state(1)];
end
xlim([1,12]), ylim([1,4])
hold off, grid on   

% figure(2)
% hold on
% plot(reward_sum(5:end))
% plot(reward_sum2(5:end))
% hold off
% legend('Sarsa','Q-learning')
    

%%%%% epsilon-greedy method
function action = take_action(Q, state, epsilon) 
    pool = [];
    if state(1) ~= 4
        pool = [pool, 1];
    end
    if state(1) ~= 1
        pool = [pool, 2];
    end
    if state(2) ~= 12
        pool = [pool, 3];
    end
    if state(2) ~= 1
        pool = [pool, 4];
    end
    
    if rand <= epsilon
        action = datasample(pool,1);
    else
        [~,index] = max(Q(state(1),state(2),pool));
        action = pool(index);
    end
end
