function [next_state, reward] = cliff_gridworld(current_state, action)
% action = {1:up, 2:down, 3:right, 4:left}

% Take action
switch action
    case 1
        next_state = current_state + [1,0];
    case 2
        next_state = current_state + [-1,0];
    case 3
        next_state = current_state + [0,1];
    case 4
        next_state = current_state + [0,-1];
end
reward = -1;

% If in the cliff region
if ismember(next_state(1),1) && ismember(next_state(2),2:11)
    reward = -100;
    next_state = [1,1];
    return;
end

next_state(1) = min(max(next_state(1),1),4);
next_state(2) = min(max(next_state(2),1),12); 
end

