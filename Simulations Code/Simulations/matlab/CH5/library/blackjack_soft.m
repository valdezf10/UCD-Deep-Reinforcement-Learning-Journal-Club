function [State, Action, Reward] = blackjack_soft(player_policy, ES_state, ES_action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Blackjack game
% Input: 
%   1) Player's policy possibility
%   2) ES_state = [player_sum, dealer_show, player_usable_ace, dealer_hide]
%   3) ES_action
% Output:
%   1) State (e.g., [player_sum, dealer_show, player_usable_ace])
%   2) Action
%   3) Reward
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    % Initialization
    card_pool         = [1:10,10,10,10];
    player_end        = false;
    dealer_end        = false;
    player_sum        = 0;
    dealer_sum        = 0;
    player_usable_ace = 0;
    dealer_usable_ace = 0;
    State             = [];
    Action            = [];
    Reward            = [];
    if isempty(ES_action)
        force_action  = false;
    else
        force_action  = true;
    end
    
    %% Game begin
    if isempty(ES_state)
        player_init = datasample(card_pool,2);
        dealer_init = datasample(card_pool,2);
        
        % Check if has usable ace
        if ismember(1,player_init)
            player_usable_ace = 1;
            player_sum = sum(player_init) + 10;
        else
            player_sum = sum(player_init);
        end
        
        if ismember(1,dealer_init)
            dealer_usable_ace = 1;
            dealer_sum = sum(dealer_init) + 10;
        else
            dealer_sum = sum(dealer_init);
        end
        
        % Record dealer's showing card
        dealer_show = dealer_init(2);
        
    else
        player_sum  = ES_state(1);
        dealer_show = ES_state(2);
        if ES_state(3) == 1
            player_usable_ace = 1;
        end
        
        if ismember(1,ES_state([2,4]))
            dealer_usable_ace = 1;
            dealer_sum = sum(ES_state([2,4])) + 10;
        else
            dealer_sum = sum(ES_state([2,4]));
        end
    end

    % Update State
    S_new = [player_sum, dealer_show, player_usable_ace];
    State = [State; S_new];

    % Check if draw or win at the beginning
    if player_sum == 21
        if dealer_sum == 21
            Reward = 0; % -> draw, game end
        else
            Reward = 1; % -> win, game end
        end
        
        if isempty(ES_action)
            Action = 0;
        else
            Action = ES_action;
        end
        return
    end   

    %% Player's round
    while ~player_end
        if force_action
            player_action = ES_action; % using exploring action
            force_action = false;
        else
            
            if rand <= player_policy(player_sum, dealer_show, player_usable_ace+1)
                player_action = 1;
            else
                player_action = 0;
            end
            
        end
        Action = [Action; player_action]; % record the action
        
        switch player_action
            case 0 
                % 1) player stick
                player_end = true; % -> dealer's turn
            case 1
                % 2) player hit
                new_card = datasample(card_pool,1);
                if new_card == 1
                    if player_sum < 11
                        player_usable_ace = 1;
                        player_sum = player_sum + 11;
                    else
                        player_sum = player_sum + 1;
                    end
                else
                    player_sum = player_sum + new_card;
                end

                % check if bust
                if player_sum > 21
                    if player_usable_ace == 1 && (player_sum-10) <= 21
                        player_usable_ace = 0;
                        player_sum = player_sum -10;
                    else
                        Reward = [Reward; -1];
                        return % -> lose, game end
                    end
                end
                
                Reward = [Reward; 0];
                S_new = [player_sum, dealer_show, player_usable_ace];
                State = [State; S_new];
                
            otherwise
                error('Unknown action from player!')
        end
    end

    %% Dealer's round
    while ~dealer_end
        dealer_action = dealer_policy(dealer_sum);
        
        switch dealer_action
            case 0 
                % dealer stick
                if player_sum > dealer_sum 
                    Reward = [Reward; 1]; % -> win, game end
                elseif player_sum == dealer_sum
                    Reward = [Reward; 0]; % -> draw, game end
                else 
                    Reward = [Reward; -1]; % -> lose, game end
                end  
                return
            case 1 
                % dealer hit
                new_card = datasample(card_pool,1);
                if new_card == 1
                    if dealer_sum < 11
                        dealer_usable_ace = 1;
                        dealer_sum = dealer_sum + 11;
                    else
                        dealer_sum = dealer_sum + 1;
                    end
                else
                    dealer_sum = dealer_sum + new_card;
                end

                % check if bust
                if dealer_sum > 21 
                    if dealer_usable_ace == 1 && (dealer_sum-10) <= 21
                        dealer_usable_ace = 0;
                        dealer_sum = dealer_sum -10;
                    else
                        Reward = [Reward; 1]; 
                        return % -> win, game end
                    end
                end
        end
    end
end

%% Dealer's strategy (fixed in our problem)
function action = dealer_policy(dealer_sum)
    if dealer_sum >= 17 
        action = 0; % dealer stick
    else
        action = 1; % dealer hit
    end    
end