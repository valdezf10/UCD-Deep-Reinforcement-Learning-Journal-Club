%% Example 5.1 (First-visit MC prediction)
clc,clear,close all
addpath('library')

% Initialization
N_episodic = 5e6;

% Define the state space
current_sum_range = 12:21; % 12~21
dealer_show_range = 1:10;  % ace~10
usable_ace_range  = 0:1;   % {0,1}
    
% Value functions
V = zeros(length(current_sum_range),...
          length(dealer_show_range),...
          length(usable_ace_range));  
C = 0*V;

% Player's policy matrix (0 means stick, 1 means hit)
player_policy = ones(length(1:21), length(1:10), length(0:1));
player_policy(end-1:end,:,:) = 0;

% Start the loop
for i = 1:N_episodic
    i
    [State, ~, Reward] = blackjack(player_policy, [], []);
    G     = 0;
    gamma = 1;
    
    % First-visit MC method
    State_first = true(length(current_sum_range),...
                       length(dealer_show_range),...
                       length(usable_ace_range));  

    for t = size(State,1):-1:1
        G = gamma*G + Reward(t);
        if ismember(State(t,1), current_sum_range)
            % index
            a = State(t,1) - current_sum_range(1) + 1;
            b = State(t,2);
            c = State(t,3) + 1;
            % only update the first-visit states
            if State_first(a,b,c)
                % Update value function
                C(a,b,c) = C(a,b,c) + 1;
                V(a,b,c) = V(a,b,c) + (G - V(a,b,c))/C(a,b,c);
                State_first(a,b,c) = false;
            end
        end
    end
end

% Plot
figure(1)
subplot(2,2,1)
plot_policy(dealer_show_range, 11:21, player_policy(:,:,1)')
title('No usable ace')

subplot(2,2,3)
plot_policy(dealer_show_range, 11:21, player_policy(:,:,2)')
title('Usable ace')

[X,Y] = meshgrid(current_sum_range, dealer_show_range);
subplot(2,2,2)
surf(X,Y,V(:,:,1)','Facealpha',0,'Linewidth',1.0)
axis equal
xlabel('Player sum'), xticks([12,21])
ylabel('Dealer showing'), yticks([1,10])
zlim([-1,1]), zticks([-1,1])
title('No usable ace')

subplot(2,2,4)
surf(X,Y,V(:,:,2)','Facealpha',0,'Linewidth',1.0)
axis equal
xlabel('Player sum'), xticks([12,21])
ylabel('Dealer showing'), yticks([1,10])
zlim([-1,1]), zticks([-1,1])
title('Usable ace')
