function plot_rc_obj_wrapper( rc_obj, plot_options )

    
    query = plot_options.query;
    colors = plot_options.colors;
    sorting = plot_options.sorting;
    remove_ends = plot_options.remove_ends; 
    only1length = plot_options.only1length;
    splitbarstitle_top = plot_options.splitbarstitle_top;
    splitbarstitle_bottom = plot_options.splitbarstitle_bottom;
    only1length = plot_options.only1length;
    
    [ygain,y0,x0,w]= deal( plot_options.ygain, plot_options.y0, plot_options.x0, plot_options.w );
    filename = plot_options.filename;
    
    % Constants %
    xlims = [0, 100]; ylims = [0, 100]; newfig=0;
    Quantity1 = 'Lifetime1'; 
    Quantity2 = 'Lifetime2'; 
    minlength = 0; % This means that there is 1 F and 1 S. The real minlength is 2.
    figdetails = 'Lifetime_xy_';
    
    % This plots the crosses AND collects the data for the rc_obj property
    % which is located at rc_obj.consolidatedLifetimes
    myoutput = rowfun( @(query, colors) plot_rc_obj( rc_obj, remove_ends, minlength, Quantity1, Quantity2, figdetails, xlims, ylims, sorting, colors{1}, query{1}, newfig, only1length ),...
        table( query, colors ) );

    set(gcf,'Position',[1921,221,1440,783]);
    textToTop(gca)

    % In superclusters, a cell array
    % this allows us to take the average of the superclusters in each cell
    superclusters = cellfun( @(query) multipleRegex( rc_obj.clustersTable.Clustertext, query ), query, 'UniformOutput', false );
    if ~isempty(sorting)
        superclusters = cell2mat( cellfun(@(x) x(sorting), superclusters, 'ErrorHandler',@(x,y) y,'UniformOutput',false) );
    else
        superclusters = cell2mat( cellfun(@(x) x, superclusters, 'ErrorHandler',@(x,y) y,'UniformOutput',false) );
    end
    
    % This plots the bars for the occupancy table
    barHeights = arrayfun( @(supercluster) ...
        nanmean(rc_obj.diffusionTableNaNs( ismember( rc_obj.diffusionTableNaNs.Supercluster, supercluster ), : ).Occupancy1), superclusters );

    % We need to know how to color the bars %
    % We want the color information to match up with the other graph %
    % The output of the other graph is in myoutput so use it here %
    
    % Collect all the colors here
    for grps = 1:numel(myoutput) % The number of groups returned from the regexp queries
        if grps==1;
            color_collect = myoutput( grps, : ).Var1{1};
        else
            color_collect = [ color_collect; myoutput( grps, : ).Var1{1} ];
        end
    end
    
    barOnAxis( barHeights, ygain, y0-40, x0, w, color_collect.Color, splitbarstitle_top );

    filtered_barHeights = arrayfun( @(supercluster) ...
        nanmean(rc_obj.consolidatedLifetimes.Occupancy1( ismember( rc_obj.subfoldersTable.Supercluster, supercluster ))), superclusters );

    barOnAxis( filtered_barHeights, ygain, y0, x0, w, color_collect.Color, splitbarstitle_bottom );
    xlabel('Fast state lifetime');ylabel('Slow state lifetime');

    print(gcf,filename,'-dsvg');

end

