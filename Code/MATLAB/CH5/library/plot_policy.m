function plot_policy(x_range, y_range, policy_matrix)
% 0 means stick, 1 means hit
    hold on
    for i = x_range
        for j = y_range
            if policy_matrix(i,j) == 0
                scatter(i,j,20,'bo')
            else
                scatter(i,j,20,'ro')
            end
        end
    end
    hold off
    set(gca,'yaxislocation','right');
    xlim([x_range(1)-0.5,x_range(end)+0.5]), xticks(x_range)
    ylim([y_range(1)-0.5,y_range(end)+0.5]), yticks(y_range)
end