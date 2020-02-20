%% Example 6.5
clc,clear,close all

% Initialization
N_episode = 170;
epsilon   = 0.1;
alpha     = 0.5;
state0    = [4,1];
goal      = [4,8];
Q         = zeros(7,10,4);
gamma     = 1;

% Sarsa (on-policy TD control)
for i = 1:N_episode
    current_state = state0;
    action = take_action(Q, current_state, epsilon);
    
    while ~isequal(current_state, goal)
      [next_state, reward] = wind_gridworld(current_state, action);
      next_action = take_action(Q, next_state, epsilon);
      
      Q(current_state(1),current_state(2),action) = Q(current_state(1),current_state(2),action) + ...
                                                    alpha*(reward + gamma*Q(next_state(1),next_state(2),next_action) - Q(current_state(1),current_state(2),action));     
                                                 
      current_state = next_state;  
      action = next_action;
    end
end

figure(1)
hold on
current_state = state0;
H = plot(current_state(2),current_state(1),'b-*');
while ~isequal(current_state, goal)
    action = take_action(Q, current_state, epsilon);
    [current_state, reward] = wind_gridworld(current_state, action);
    H.XData = [H.XData, current_state(2)];
    H.YData = [H.YData, current_state(1)];
end
xlim([1,10])
ylim([1,7])
set(gca,'ydir','reverse')
hold off, grid on


%%%%% epsilon-greedy method
function action = take_action(Q, state, epsilon)   
    if rand <= epsilon
        action = randi(4,1);
    else
        [~,action] = max(Q(state(1),state(2),:));
    end
end

