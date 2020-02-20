%% Example 5.4 (epsilon-soft policy)
clc,clear,close all
addpath('library')

% Initialization
N_episodic = 3e6;
epsilon    = 0.1;

% Define the state space
current_sum_range = 12:21; % 12~21
dealer_show_range = 1:10;  % ace~10
usable_ace_range  = 0:1;   % {0,1}
action_range      = 0:1;   % {0:stick, 1:hit}
card_pool         = [1:10,10,10,10];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Value functions (state-action pair)
% V = zeros(length(current_sum_range),...
%           length(dealer_show_range),...
%           length(usable_ace_range),...
%           length(action_range));  
% C = 0*V;
% 
% % Player's policy possiblity matrix (0: 0% hit, 1: 100% hit)
% player_policy_pos = 0.5*ones(length(1:21), length(1:10), length(0:1));
% player_policy_pos(1:11,:,:) = 1;
% 
% % Optimal policy matrix
% player_policy_optimal = ones(length(1:21), length(1:10), length(0:1));
% player_policy_optimal(end-1:end,:) = 0;

% % To speed up, use pre-stored matrix (has been run for many episodes)
load('V.mat')
load('C.mat')
load('player_policy_pos.mat')
load('player_policy_optimal.mat')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

% Start the loop
for i = 1:N_episodic
    [State, Action, Reward] = blackjack_soft(player_policy_pos, [], []);
    G     = 0;
    gamma = 1;
    
    % First-visit MC method
    State_first = true(length(current_sum_range),...
                       length(dealer_show_range),...
                       length(usable_ace_range),...
                       length(action_range));  

    for t = size(State,1):-1:1
        G = gamma*G + Reward(t);
        if ismember(State(t,1), current_sum_range)
            % index
            a = State(t,1) - current_sum_range(1) + 1;
            b = State(t,2);
            c = State(t,3)+1;
            d = Action(t)+1;
            
            % only update the first-visit states
            if State_first(a,b,c,d)
                % Update value function
                C(a,b,c,d) = C(a,b,c,d) + 1;
                V(a,b,c,d) = V(a,b,c,d) + (G - V(a,b,c,d))/C(a,b,c,d);
                State_first(a,b,c,d) = false;
                
                % Update epsilon-soft policy
                [~,k] = max(V(a,b,c,:));
                player_policy_optimal(State(t,1), State(t,2), State(t,3)+1) = k-1;
                
                % Updata policy
                if Action(t) == k-1
                    %since our matrix only saves possiblity for hit
                    if Action(t) == 1
                        player_policy_pos(State(t,1), State(t,2), State(t,3)+1) = 1 - epsilon + epsilon/length(action_range);
                    else
                        player_policy_pos(State(t,1), State(t,2), State(t,3)+1) = 1-(1 - epsilon + epsilon/length(action_range));
                    end
                else
                    if Action(t) == 1
                        player_policy_pos(State(t,1), State(t,2), State(t,3)+1) = epsilon/length(action_range);
                    else
                        player_policy_pos(State(t,1), State(t,2), State(t,3)+1) = (1-epsilon/length(action_range));
                    end
                end  
            end  
        end
    end
end

% Obtain V_optimal
for i = 1:size(V,1)
    for j = 1:size(V,2)
        for k = 1:size(V,3)
            V_optimal(i,j,k) = V(i,j,k,player_policy_optimal(i+current_sum_range(1)-1,j,k)+1);
        end
    end
end

% Plot
figure(1)
subplot(2,2,1)
plot_policy(dealer_show_range, 11:21, player_policy_optimal(:,:,1)')
title('No usable ace')

subplot(2,2,3)
plot_policy(dealer_show_range, 11:21, player_policy_optimal(:,:,2)')
title('Usable ace')

[X,Y] = meshgrid(current_sum_range, dealer_show_range);
subplot(2,2,2)
surf(X,Y,V_optimal(:,:,1)','Facealpha',0,'Linewidth',1.0)
axis equal
xlabel('Player sum'), xticks([12,21])
ylabel('Dealer showing'), yticks([1,10])
zlim([-1,1]), zticks([-1,1])
title('No usable ace')

subplot(2,2,4)
surf(X,Y,V_optimal(:,:,2)','Facealpha',0,'Linewidth',1.0)
axis equal
xlabel('Player sum'), xticks([12,21])
ylabel('Dealer showing'), yticks([1,10])
zlim([-1,1]), zticks([-1,1])
title('Usable ace')
