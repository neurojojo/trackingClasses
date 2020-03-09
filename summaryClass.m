classdef summaryClass
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ClusterText
        logTable
        metadata
        query
        filteredTable
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % List of current methods %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % resultsClusterClass: Constructor
    % 
    % showCDFs: Creates CDF plots for all the data clusters 
    % 10/29 - currently no support for mix+match
    % showBoxplot: Creates box plots
    % 
    % 
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %        CONSTRUCTOR FUNCTION           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        function obj = summaryClass( resultsClusterObj, findFoldersObj, options)
            % Each summary object has a query 
            % Which specifies exactly what part of the data to keep
            
            [Identifier, MinTracks,State,SC,Cell] = deal( options.search.Identifier, options.search.MinTracks, options.search.State, options.search.SC, options.search.Cell );
            
            fullset = [1:size(resultsClusterObj.lifetimesTable,1)];
            
            if ~isempty(MinTracks); set1 = find( resultsClusterObj.lifetimesTable.tracksInSeg > MinTracks ); else; set1 = fullset; end;
            if ~isempty(State); set2 = find( ismember(resultsClusterObj.lifetimesTable.State, State) == 1 ); else; set2 = fullset; end;
            if ~isempty(SC); set3 = find( ismember(resultsClusterObj.lifetimesTable.Supercluster, SC) == 1 ); else; set3 = fullset; end;
            if ~isempty(Identifier); set4 = find( ismember(resultsClusterObj.lifetimesTable.Identifier, Identifier) == 1 ); else; set4 = fullset; end;
            if ~isempty(Cell); set5 = find( ismember(resultsClusterObj.lifetimesTable.Cell, Cell) == 1 ); else; set5 = fullset; end;
            
            obj.query = intersect(set5,intersect(set4, intersect(set3, intersect(set2,set1))));
            obj.ClusterText = readtable( options.thisClusterText_location ,'HeaderLines',0,'Delimiter',',');
            obj.filteredTable = resultsClusterObj.lifetimesTable( obj.query, : );
            
        end
        
        function switchLabels(obj) % If the label of the graph is Cluster 1,2,3...etc -- this helper function will switch those out
            
            curr_labels = get(gca,'XTickLabel');
            thisClusterText = table2cell( obj.ClusterText );
            switchlabel = @(x) thisClusterText{ str2double(cell2mat(regexp( x, '\d+', 'match' ))) };
            set(gca, 'XTickLabel', cellfun( switchlabel, curr_labels , 'UniformOutput', false));

        end
        
        
        %%%%%%%%%%%%%%%%%%%%
        % PLOTTING OPTIONS %
        %%%%%%%%%%%%%%%%%%%%
         
    end
    
    methods(Static)

        function SuperclustersToPlot = getSuperclusters(rc_obj, options)

            % Check if this field has data
            myf = @(x) ~isempty( x.(options.VariableToShow) );

            % Pull out superclusters of interest
            if strcmp(options.Superclusters, 'All'); 
                myf = @(x) strcmp(x.ErrorMsg,'Failed to get any data');
                test_for_errors = structfun(myf, rc_obj.clusterStructure);
                SuperclustersToPlot = find(test_for_errors==0); 
            else; 
                SuperclustersToPlot = options.Superclusters'; 
            end

            if isfield(options,'Search') & ~isempty(options.Search);
                string = options.Search;
                myre_f = @(x) regexpi( x, string);
                mycell_f = @(x) numel(x{1});
                SuperclustersToPlot = table2array(unique(rc_obj.clustersTable( find( table2array(rowfun( mycell_f, rowfun(myre_f,rc_obj.clustersTable(:,5))))>0), 1))); % A monstrosity
            end

        end
        
        function savePlot(options)
            if numel(options.Superclusters)<6; scs_ = num2str( options.Superclusters ); else; scs_ = 'Many'; end
            filename = sprintf('%s\\%s SCs %s %s',options.Savefolder, options.VariableToShow, scs_, options.PlotType);
            if options.Logdata; filename = strcat( filename, '(logscale)'); end
            %filename = strcat( filename, '.', options.Format );
            %print( gcf, filename, sprintf('-d%s',options.Format));
            %fprintf('Saved file to %s\n',filename);
        end
        
    end
    
end