function  [next_state, reward] = wind_gridworld(current_state, action)

% action = {1:up, 2:down, 3:right, 4:left}

% Take action
switch action
    case 1
        next_state = current_state + [-1,0];
    case 2
        next_state = current_state + [1,0];
    case 3
        next_state = current_state + [0,1];
    case 4
        next_state = current_state + [0,-1];
end
reward = -1;

% Wind effect
if ismember(current_state(2), [4,5,6,9])
    next_state = next_state + [-1,0];
end

if ismember(current_state(2), [7,8])
    next_state = next_state + [-2,0];
end

next_state(1) = min(max(next_state(1),1),7);
next_state(2) = min(max(next_state(2),1),10);

% Check if reach the goal
if isequal(next_state, [4,8])
    reward = 0;
end

end