classdef resultsClusterClass < handle
    
    properties
        
        lifetimesTable
        logTable
        clustersTable
        clusterStructure
        consolidatedLifetimes
        diffusionTable
        diffusionTableNaNs
        segmentsTable
        sequencesTable
        subfoldersTable
        Id
        markovLetters
        mergedSegmentsTable
        
    end
    
    % Constructor method takes one input (findFoldersClass object)
    %
    % In-place methods:
    %   .getConsolidatedLifetimes(foldersObject) produces lifetimesTable
    %   .computeSegInfo() updates lifetimesTable
    %   .makeDiffusionTable() pulls the diffusion coeffs from each object
    %   .showTrees() shows the cluster structures
    %
    % Static methods:
    %   textIntersections( 1-D table of text ) outputs a distance matrix
    %   clusterTableList( 1-D table of text ) outputs a clustering based on
    %       the distance matrix
    
                    
    methods

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %        CONSTRUCTOR FUNCTION           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = resultsClusterClass( findFoldersObj )
            
            % Default Markov letters %
            obj.markovLetters = ['I','C','D','V']; % Immobile, confined, diffusing, fast diffusing
            
            findFoldersObj.subfolderTable.Properties.VariableNames={'Name'};
            myTable = findFoldersObj.subfolderTable(:,1); 
            
            % Make sure all folders have #(two digit number)
            % as in #03Ch1 etc
            myf = @(x) isempty( regexp(x,'\#[0-9][0-9]','match') );
            myTable( find(cellfun( myf, myTable.Name)==1), :) = repmat( {'NO\Empty\#'}, sum(cellfun( myf, myTable.Name)==1), 1 );
            full_filename_Table = myTable;
            % Take all filename info before the #Ch %
            
            myregexp_1 = @(x) regexp(x{1}, '(?<=[A-Z]{2,3}).*(?=\#)','match');
            tld_table = rowfun( myregexp_1, myTable );
            
            % Remove batch # (Signe data) %
            myregexp_2 = @(x) regexprep( x ,  '[B|b]atch.*?(?<=\\)', '' );
            tld_table = rowfun( myregexp_2, tld_table );
            
            % Save this as myTable
            myTable = tld_table;
            % 
            
            myregexp_3 = @(x) regexp( x{1}, '^.*?(?=\\)', 'match');
            tld_table = rowfun( myregexp_3, tld_table);
            
            clusteredTable = resultsClusterClass.clusterTableList( tld_table );
            
            %%%%%%%%%%%%% END PARSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            subfoldersTable = table('Size',[1,5],...
                                'VariableTypes',{   'double',       'double',   'double',       'double',                   'cell'},...
                                'VariableNames', {  'AbsoluteIdxToSubfolders', 'Cluster',  'Subcluster',   'Supercluster','Filename'});
            count=1;
            for i = 1:max(clusteredTable)
                thisCluster = find(clusteredTable==i);
            
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % This analyzes the subdirectories in the folder tree %
                    %                                                     %
                    % It parses a filename:                               %
                    % C:/Directory1/Directory2/Batch/Directory3/#Ch1/Etc  %
                    % Into                                                %
                    % Directory2/Directory3                               %
                    %                                                     %
                    % Thus, Directory2 and Directory3 should contain info %
                    % about the experimental conditions                   %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    thisGroup = resultsClusterClass.clusterTableList( myTable( thisCluster, : ) );
                    
                    for j = 1:max(thisGroup)
                       mySubCluster = find(thisGroup==j); 
                       
                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                       %Create a subtable to be merged with the main table%
                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                       
                       myTable.Properties.VariableNames={'Name'};
                       
                       mySubTable = table( count*ones(numel(mySubCluster),1), ...
                                            i*ones(numel(mySubCluster),1),...
                                            j*ones(numel(mySubCluster),1),...
                                            thisCluster(mySubCluster),...
                                            full_filename_Table( thisCluster(mySubCluster), : ).Name,...
                           'VariableNames', {'Supercluster','Cluster','Subcluster','AbsoluteIdxToSubfolders','Filename'}); % TABLE VARIABLE NAMES %
                       subfoldersTable = [ subfoldersTable; mySubTable ];
                       count=count+1;
                    end

            end 
            obj.subfoldersTable = sortrows( subfoldersTable(2:end,:), 'AbsoluteIdxToSubfolders','ascend');
            
            obj.Id = regexprep( datestr(now), '-|\s|:', '_' );
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%
        % Modifying parameters %
        %%%%%%%%%%%%%%%%%%%%%%%%
        
        function setMarkovLetters(obj, letters_)
            obj.markovLetters = letters_;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Table modifying functions             %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function newgroup(obj,AbsoluteIdxForGroup,varargin)
           
           % AbsoluteIdxToSubfolders contains values to be used for AbsoluteIdxGorGrp
           % - This is a column in rc_obj.subfoldersTable
           % - Also shows up in the far right in showTrees() method figures
           
           % varargin{1} is the subcluster numbers
           if nargin>2; newSubclusters = varargin{1}; end
           
           myfind = @(myobj,x) find( ismember(myobj.subfoldersTable.AbsoluteIdxToSubfolders,x) == 1 );
           [lastSCluster,lastCluster] = deal( max( obj.subfoldersTable.Supercluster ), max( obj.subfoldersTable.Cluster ) );
           
           idxes_in_table = myfind(obj,AbsoluteIdxForGroup);
           
           obj.subfoldersTable( idxes_in_table, : ).Supercluster = repmat( lastSCluster+1, numel( AbsoluteIdxForGroup ), 1 );
           obj.subfoldersTable( idxes_in_table, : ).Cluster = repmat( lastCluster+1, numel( AbsoluteIdxForGroup ), 1 );
           if exist('newSubclusters'); obj.subfoldersTable( idxes_in_table, : ).Subcluster = newSubclusters; 
           else; obj.subfoldersTable( idxes_in_table, : ).Subcluster = repmat( 1, numel( AbsoluteIdxForGroup ), 1 ); end
           
        end
        
        function integrityCheck(obj)
            for i = 1:max( obj.subfoldersTable.Cluster );
                X = obj.subfoldersTable( obj.subfoldersTable.Cluster==i, :).Subcluster;
                [sortedValue_X , X_Ranked] = sort(X,'ascend');
                [~, ~, X_Ranked]=unique(sortedValue_X);
                obj.subfoldersTable( obj.subfoldersTable.Cluster==i, :).Subcluster = X_Ranked;
            end
        end
        
        
        function saveTables(obj,varargin)
        
            if nargin>1; mystr = sprintf('_%s_',varargin{1}); else mystr=''; end
            save( sprintf('rc_obj%s_%s.mat',mystr,date), 'obj' );
        
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %    END CONSTRUCTOR FUNCTION           %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
        
        
        function makeDiffusionTable(obj, findFoldersObj)
            
            errH = @(a,b) 0;
            getDC_1 = @(x) x.metadata.DiffCoeff(1);
            getDC_2 = @(x) x.metadata.DiffCoeff(2);

            dc1=cellfun(@double,struct2cell(structfun( getDC_1, findFoldersObj.hmmsegs, 'UniformOutput', false, 'ErrorHandler', errH )));
            dc2=cellfun(@double,struct2cell(structfun( getDC_2, findFoldersObj.hmmsegs, 'UniformOutput', false, 'ErrorHandler', errH )));
            
            myre = @(x) str2double(regexp(x,'(?<=_).*','match'));
            myobjs = cellfun(myre, fields(findFoldersObj.hmmsegs));
            
            obj.diffusionTable = table( myobjs, dc1, dc2, 'VariableNames', {'AbsoluteIdxToSubfolders','DC1','DC2'} );
            missed_objs = setxor( [1:max( obj.subfoldersTable.AbsoluteIdxToSubfolders )], myobjs );
            tmp = table( missed_objs, repmat(0,numel(missed_objs),1), repmat(0,numel(missed_objs),1), 'VariableNames', {'AbsoluteIdxToSubfolders','DC1','DC2'} );
            obj.diffusionTable = [obj.diffusionTable;tmp];
            
            % Occupancy calculation
            % This goes through the hmmsegs so a for loop is necessary
            occupancies = [];
            for i = obj.diffusionTable.AbsoluteIdxToSubfolders'
                mynumel = @(x) numel(x{1});
                
                try
                    state1_tmp = findFoldersObj.hmmsegs.(sprintf('obj_%i',i)).brownianTable.State1(:,6);
                    state2_tmp = findFoldersObj.hmmsegs.(sprintf('obj_%i',i)).brownianTable.State2(:,6); 
                    [state1_lts,state2_lts] = deal( table2array(rowfun( mynumel, state1_tmp )), table2array(rowfun( mynumel, state2_tmp )) );
                catch
                    if or( numel( state1_tmp.hmm_xSeg ), numel( state2_tmp.hmm_xSeg ) ); occupancies(i,:) = [0,0]; end % If there are no 
                end
                
                occupancies(i,1) = sum( state1_lts ) / (sum(state1_lts)+sum(state2_lts));
                occupancies(i,2) = sum( state2_lts ) / (sum(state1_lts)+sum(state2_lts)); 
            end
            
            obj.diffusionTable.Occupancy1 = occupancies(:,1);
            obj.diffusionTable.Occupancy2 = occupancies(:,2);
            tmp = join(  obj.subfoldersTable, obj.diffusionTable, 'Keys', 'AbsoluteIdxToSubfolders' );
            obj.diffusionTable = tmp;
            
            % Remove bad entries
            obj.diffusionTableNaNs = obj.diffusionTable;
            badEntries = find( (le(obj.diffusionTableNaNs.DC1,0) | le(obj.diffusionTableNaNs.DC2,0)) == 1 );
            obj.diffusionTableNaNs(badEntries,'DC1') = table(nan( numel(badEntries) ,1));
            obj.diffusionTableNaNs(badEntries,'DC2') = table(nan( numel(badEntries) ,1));
            
        end
        
        function getConsolidatedLifetimes(obj, findFoldersObj)
            count=1;
            
            masterTable = obj.subfoldersTable;
            
            % Initialize a 0-entry table
            col_headings = {'Supercluster','Obj','Status','Filename'};
            
            logTable = table('Size',[0, 4],'VariableNames',col_headings,'VariableTypes',{'double','cell','cell','cell'});
            
            results = struct();       
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Start by making a table here that will accumulate data from %
            % within each supercluster                                    %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            data_col_headings = {'Supercluster','Cell','Obj_Idx','trackIdx','segIdx','hmmSegIdx','State','hmmSegStart','Lifetime','tracksInSeg'};
            varTypes = {'double','double','double','double','double','double','double','double','double','double'};
            this_supercluster_level_table = table('Size',[0,numel(data_col_headings)],'VariableNames',data_col_headings,...
                                'VariableTypes',varTypes);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Loop over superclusters %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            for i = 1:max( masterTable.Supercluster ) 
                % Each of these defines a super cluster, or a cluster of  %
                % cells within a given experiment                         %
                % This does not mean ALL the cells of a certain           %
                % genotype+treatment                                      %
                %                                                         %
                % Rather, just the cells that have the same genotype AND  %
                % the same treatment
                % 
                cluster_string = sprintf('Cluster_%i',i);
                myobjs = masterTable( find(masterTable.Supercluster==i), :).AbsoluteIdxToSubfolders;
                
                State1_lts = []; State2_lts = []; State1_Cell_ID = []; State2_Cell_ID = [];
                
                % This is ONE supercluster %
                % It looks over each state within a cluster %
                Nstates = []; count = 1;
                while isempty(Nstates) & count<=numel(myobjs)
                    obj_string = sprintf('obj_%i',myobjs(count));
                    if isfield( findFoldersObj.hmmsegs, obj_string); Nstates = findFoldersObj.hmmsegs.(sprintf('obj_%i',myobjs(count))).Nstates; end
                    count=count+1;
                end
                % When no non-empty object could be found within the
                % supercluster, pass on to the next supercluster
                if isempty(Nstates)
                    logTable = [logTable; table( i, {sprintf('%s',cluster_string)} ,{sprintf('Number of states unspecified for objects %s',num2str(myobjs'))}, trackingFile_string, 'VariableNames',col_headings )];
                    results.(cluster_string).ErrorMsg = 'Failed to get any data';
                    continue 
                end
                
                this_state_level_table = table('Size',[0, numel(data_col_headings)],'VariableNames',data_col_headings,'VariableTypes',varTypes);
                    
                for j = 1:Nstates
                    % By default, fill in an empty entry for each element of
                    % the Supercluster list
                    state_string = sprintf('State%i',j); % This is used to tell you which state you are pulling from
                    lasterr='';
                    
                    State_lts = []; Cell_IDs = []; SC_ids = []; StateNum_ids = []; tracksInSeg = []; Obj_Ids = [];% Initialize all necessary variables for appending
                    [hmmSegStart,trackIdx,segIdx,hmmSegIdx] = deal([],[],[],[]);
                    % Retrieve the values for each of the cells and each state
                    Ncells = numel(myobjs); % Each object is a cell
                    
                    this_cell_level_table = table('Size',[0, numel(data_col_headings)],'VariableNames',data_col_headings,'VariableTypes',varTypes);
                    
                    for k = 1:Ncells % Find all the state-j entries within the object
                        %fprintf('SC%i State%i Cell%i\n',i,j,k)
                        %fprintf('%i ',myobjs);
                        try
                            myobj = findFoldersObj.hmmsegs.(sprintf('obj_%i',myobjs(k)));
                            trackingFile_string = regexp(myobj.metadata.fileStruct.address_Tracking,'.*?(?=Tracking.mat)','match');
                            Nsegs = numel(myobj.brownianTable.(state_string).hmm_xSeg);
                            
                            State_lts = [       cellfun(@numel, myobj.brownianTable.(state_string).hmm_xSeg ) ];
                            Obj_Ids = [         myobjs(k)*ones( Nsegs, 1 ) ];
                            SC_ids = [          i*ones( Nsegs, 1 ) ];
                            StateNum_ids = [    j*ones( Nsegs, 1 ) ];
                            Cell_IDs = [        k*ones( Nsegs, 1 ) ];
                            tracksInSeg = [     myobj.brownianTable.(state_string).tracksInSeg ];
                            hmmSegStart = [     myobj.brownianTable.(state_string).hmmSegStart ];
                            [trackIdx,segIdx,hmmSegIdx] = deal( myobj.brownianTable.(state_string).trackIdx, myobj.brownianTable.(state_string).segIdx,myobj.brownianTable.(state_string).hmmSegIdx );
                            
                            logTable = [logTable; table( i, {sprintf('obj_%i',myobjs(k))} ,{sprintf('Loaded %s',state_string)}, trackingFile_string, 'VariableNames',col_headings )];
                        catch
                            %fprintf('Error in SC%i State%i Cell%i\n',i,j,k);
                            if ~isfield( findFoldersObj.hmmsegs, sprintf('obj_%i',myobjs(k))); lasterr = sprintf('No object exists in the hmmsegs (obj_%i state %i)',myobjs(k),j); end
                            if isfield( findFoldersObj.hmmsegs, sprintf('obj_%i',myobjs(k))) & isempty( myobj.brownianTable ); lasterr = sprintf('No Brownian table (obj_%i state %i)',myobjs(k),j); end
                            results.(cluster_string).(sprintf('%s_Lifetimes',state_string)) = [];
                            results.(cluster_string).(sprintf('%s_Cell_ID',state_string)) = [];
                            results.(cluster_string).ErrorMsg = 'Error here';
                            logTable = [logTable; table( i, {sprintf('obj_%i',myobjs(k))}, {lasterr}, trackingFile_string, 'VariableNames',col_headings )];
                            fprintf('%s\n',lasterr);
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % THIS IS THE MOST IMPORTANT TABLE %
                        % Fields are expanded to show      %
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    this_cell_level_table = [this_cell_level_table; table( SC_ids,...
                        Cell_IDs,...
                        Obj_Ids,...
                        trackIdx,...
                        segIdx,...
                        hmmSegIdx,...
                        StateNum_ids,... % Identifies the state # (1,2,etc)
                        hmmSegStart,...
                        State_lts,...
                        tracksInSeg,...
                        'VariableNames',data_col_headings )];
                    end
                    
                    this_state_level_table = [ this_state_level_table; this_cell_level_table ];
                    results.(cluster_string).(sprintf('%s_Lifetimes',state_string)) = State_lts;
                    results.(cluster_string).(sprintf('%s_Cell_ID',state_string)) = Cell_IDs;
                    results.(cluster_string).ErrorMsg = []; % If it ran this far, no serious errors to report
                    count=count+1;
                    
                end
                this_supercluster_level_table = [ this_supercluster_level_table; this_state_level_table ];
            end
            obj.logTable = sortrows( logTable, 3 );
            obj.clusterStructure = results; % The results is an interpretable structure
            obj.lifetimesTable = this_supercluster_level_table;
            
        end
        
        function consolidateSuperclusterLifetimes( obj, varargin )
            
            occupancy = @(x,y) nansum( x ) / (nansum(x)+nansum(y));
            SCstable = table('Size',[ size(obj.subfoldersTable,1) , 8 ],'VariableNames',{'Supercluster','Obj_Idx','Lifetime1','Lifetime2','Occupancy1','Occupancy2','State1Tracks','State2Tracks'},'VariableTypes',repmat({'double'},1,8) );
            
            % Check for remove_ends flag
            if sum(strcmp(varargin,'remove_ends'))>0
                remove_ends_flag = 1;
                % This is the minimum, both state 1 and state 2 must have %
                % this many occurances within a segment to be included %
                
                remove_ends_min = varargin{ find(strcmp(varargin,'remove_ends')==1)+1 };
                mytable = obj.lifetimesTable( (obj.lifetimesTable.tracksInSeg>remove_ends_min) & (obj.lifetimesTable.Identifier==0) , : );
                fprintf('consolidatedSuperclusterLifetimes: Removed end tracks from consolidated lifetimes variable and only took tracks longer than %i\n', remove_ends_min);
            else 
                mytable = obj.lifetimesTable;
            end
            
            % Check for only1length flag
            if sum(strcmp(varargin,'only1length'))>0
                mytable = obj.lifetimesTable( (obj.lifetimesTable.tracksInSeg==1 ), : );
                fprintf('consolidatedSuperclusterLifetimes: Using only single tracks\n');
            end
            
            count=1;
            for i = unique( mytable.Supercluster )'
                my_objs = unique(mytable( find( mytable.Supercluster == i ), : ).Obj_Idx);
                for j = my_objs'
                    my_lts1 = mytable( find( (mytable.State == 1)&(mytable.Obj_Idx == j) ), : ).Lifetime;
                    my_lts2 = mytable( find( (mytable.State == 2)&(mytable.Obj_Idx == j) ), : ).Lifetime;
                    
                    SCstable(j,:) = table( i, j, mean(my_lts1), mean(my_lts2),...
                                                       occupancy(my_lts1,my_lts2), occupancy(my_lts2,my_lts1),...
                                                       numel(my_lts1), numel(my_lts2) );
                end
            end
            
            SCstable.Properties.VariableNames={'Supercluster','Obj_Idx','Lifetime1','Lifetime2','Occupancy1','Occupancy2','State1Tracks','State2Tracks'};
            %SCstable = sortrows(SCstable,'Obj_Idx');
            SCstable.Obj_Idx = [1:size( obj.subfoldersTable,1 )]';
            obj.consolidatedLifetimes = SCstable;
            
            % For generating table_all_lengths.csv
            % 
            % SCstable.Properties.VariableNames{ strcmp(SCstable.Properties.VariableNames,'Obj_Idx') } = 'AbsoluteIdxToSubfolders';
            % T = join( SCstable, obj.subfoldersTable(:,{'AbsoluteIdxToSubfolders','Shortname'}), 'Keys', 'AbsoluteIdxToSubfolders' );
            % T = T(:,{'Shortname','AbsoluteIdxToSubfolders','State1Tracks','State2Tracks','Occupancy1','Occupancy2','Lifetime1','Lifetime2'});
            % writetable(T,'C:\\laptop_database\\signe_figures_jan20\\table_removed_ends_lengths.csv');
            
        end
        
        function computeSegInfo( obj )
            
            obj.lifetimesTable.Index = [1:size(obj.lifetimesTable,1)]';
            obj.lifetimesTable.Identifier = zeros( size(obj.lifetimesTable,1), 1 );
            myobjs = unique( obj.lifetimesTable.Obj_Idx ); % Compute over every object

            for i = myobjs'

                search = intersect( find( obj.lifetimesTable.Obj_Idx == i ), find( obj.lifetimesTable.tracksInSeg > 2 ) );
                tmp = sortrows( obj.lifetimesTable( search, : ), {'Supercluster','Cell','segIdx','hmmSegStart'} );

                [starts, ends] = deal([],[]);
                for j = unique( tmp.segIdx )'
                    tmp2 = tmp( find(tmp.segIdx == j), :);
                    starts = [starts, tmp2(1,:).Index];
                    ends = [ends, tmp2(end,:).Index];
                end

                obj.lifetimesTable( starts, : ).Identifier = -1*ones( numel(starts), 1 );
                obj.lifetimesTable( ends, : ).Identifier = 1*ones( numel(ends), 1 );

            end
        obj.lifetimesTable = sortrows( obj.lifetimesTable, {'Supercluster','Cell','segIdx','hmmSegStart'} );
        end
        
        function computeClusters( obj, findFoldersObj )
           
            % Join parsed filenames from findFoldersObj with clustered data
            tmp = join( obj.subfoldersTable, findFoldersObj.namesTable, 'key', 'AbsoluteIdxToSubfolders' );
            
            [Superclusters,IdxInNamesTable,IdxToSubfolders] = unique( tmp.Supercluster );
            
            obj.clustersTable = table( Superclusters, findFoldersObj.namesTable( IdxInNamesTable, : ).Shortname );
            obj.clustersTable.Properties.VariableNames = {'Supercluster','Shortname'};
            
            obj.subfoldersTable = join(  obj.subfoldersTable, obj.clustersTable , 'key', 'Supercluster' );
            obj.subfoldersTable = obj.subfoldersTable(:,{'Supercluster','Shortname','AbsoluteIdxToSubfolders','Subcluster','Filename'});
        end
        
        function getSequences( obj, findFoldersObj )
            
            accumulator_table = struct();

            for objectnames = fields( findFoldersObj.segs )'
                
                accumulator_tables.(objectnames{1}).sequenceByTrackIdx = table( [],...
                                                                 {},...
                                                                    'VariableNames', {'trackIdx','Sequence'} );
                % Place an empty entry  for data consistency %
                
                accumulator_tables.(objectnames{1}).dictionaryTable = table( {''},...
                                                                 NaN,...
                                                                 NaN, ...
                                                                    'VariableNames', {'States','Count','Length'} );
                                                                                    
                try
                    
                    if ~isempty( findFoldersObj.hmmsegs.(objectnames{1}).brownianTable )
                        
                        tmp = sortrows( outerjoin( findFoldersObj.segs.(objectnames{1}).segsTable(:,[1,2,5]),...
                            [findFoldersObj.hmmsegs.(objectnames{1}).brownianTable.State1(:,[1,2,4,8]); findFoldersObj.hmmsegs.(objectnames{1}).brownianTable.State2(:,[1,2,4,8])],...
                            'Keys', {'trackIdx','segIdx'} ), {'trackIdx_left','segIdx_left','hmmSegStart'} );

                        % Initialize the column based on the output of DC-MSS
                        tmp.segType_combined = tmp.segType_left; 
                        % If DC-MSS returns a NaN value, set this value to -1
                        tmp.segType_combined( isnan(tmp.segType_left) ) = -1;
                        % If DC-MSS returns 2, but contains a NaN value in the x- or y-coordinates
                        tmp.segType_combined( and(tmp.segType_left==2, isnan(tmp.trackIdx_right)) ) = -2; 
                        % If the DC-MSS returns 2, does not contain a NaN value
                        % imputes the segment type from the segType_right column
                        tmp.segType_combined( and(tmp.segType_left==2, ~isnan(tmp.trackIdx_right)) ) = tmp.segType_right( and(tmp.segType_left==2, ~isnan(tmp.trackIdx_right)) );
                        tmp.segType_letters = repmat({''}, size(tmp,1), 1);

                        % There are two sources of error tracks
                        % (1) Segment < 20 in length and gets categorized as NaN
                        % (2) Segment x or y has NaN entries (due to gap closing)
                        % We combine them into one here
                        transtable = table( ['G';'N';'I';'C';'F';'S';'V'], [-2;-1;0;1;101;102;3] );
                        
                        for i = 1:size( transtable, 1 )
                            toreplace = ( tmp.segType_combined == transtable(i,:).Var2 );
                            tmp( toreplace,:).segType_letters = repmat({transtable(i,:).Var1}, sum( toreplace ), 1);
                        end
                        
                        mytables = arrayfun( @(x) cellstr(cell2mat(tmp( tmp.trackIdx_left == x,:).segType_letters)'), unique( tmp.trackIdx_left ), 'UniformOutput', false );
                        
                        fprintf('%s %1.5f\n', objectnames{1}, 100*numel(find( cellfun( @(x) numel(x), cellfun( @(x) regexp( x{1}, 'II' ), mytables , 'UniformOutput', false))==1 )) / size(mytables,1))
                        %bad_tracks = cellfun(@(x) or( strcmp(x{1},'E'), isempty(x{1}) ), mytables , 'UniformOutput', true);
                        %out = arrayfun( @(x) mytables{x}, find(bad_tracks==0) );

                        out = mytables;
                        % Use a for loop to create a structure (for now)
                        accumulator = struct();
            
                        for i = 1:size(out,1)
                               if ~isfield( accumulator, out{i} )
                                   accumulator.( sprintf('%s',out{i}{1}) ) = 1;
                               else
                                   accumulator.( sprintf('%s',out{i}{1}) ) = accumulator.( sprintf('%s',out{i}{1}) )+1;
                               end
                        end
                        
                        
                        
                        % Replace the empty entry if there is something to
                        % enter %
                        accumulator_tables.(objectnames{1}).sequenceByTrackIdx = table( unique(tmp.trackIdx_left), mytables, 'VariableNames', {'trackIdx','Sequence'} );
                        accumulator_tables.(objectnames{1}).dictionaryTable = table( fields( accumulator ),...
                                                                                     struct2array(accumulator)',...
                                                                                     cellfun( @(x) numel(x), fields( accumulator ) ), ...
                                                                                        'VariableNames', {'States','Count','Length'} );
                    end
                    
                catch
                   fprintf('Failed for %s\n',objectnames{1}); 
                   fprintf('%s\n',lasterr);

                end
            end

            obj.sequencesTable = accumulator_tables;
            
        end
        
        function mergeAllSegments(obj, findFoldersObj)
            
            for objectnames = fields( findFoldersObj.segs )'
                
                try
                    
                    tmp = sortrows( outerjoin( findFoldersObj.segs.(objectnames{1}).segsTable(:,{'trackIdx','segIdx','segType','xSeg'}),...
                                    [findFoldersObj.hmmsegs.(objectnames{1}).brownianTable.State1(:,{'trackIdx','segIdx','hmmSegIdx','hmmSegStart','segType','hmm_xSeg'});...
                                    findFoldersObj.hmmsegs.(objectnames{1}).brownianTable.State2(:,{'trackIdx','segIdx','hmmSegIdx','hmmSegStart','segType','hmm_xSeg'})],...
                                    'Keys', {'trackIdx','segIdx'} ), {'trackIdx_left','segIdx_left','hmmSegStart'} );


                    % Initialize the column based on the output of DC-MSS
                    tmp.segType_combined = tmp.segType_left; 
                    % If DC-MSS returns a NaN value, set this value to -1
                    tmp.segType_combined( isnan(tmp.segType_left) ) = -1;
                    % If DC-MSS returns 2, but contains a NaN value in the x- or y-coordinates
                    tmp.segType_combined( and(tmp.segType_left==2, isnan(tmp.trackIdx_right)) ) = -2; 
                    % If the DC-MSS returns 2, does not contain a NaN value
                    % imputes the segment type from the segType_right column
                    tmp.segType_combined( and(tmp.segType_left==2, ~isnan(tmp.trackIdx_right)) ) = tmp.segType_right( and(tmp.segType_left==2, ~isnan(tmp.trackIdx_right)) );
                    tmp = tmp(:,{'trackIdx_left','segIdx_left','xSeg','hmm_xSeg','hmmSegIdx','segType_combined'});

                    toexpand = histc( tmp.trackIdx_left, [1:max(tmp.trackIdx_left)] ); % Find tracks with multiple segments (they will not be 1 entries in histogram)
                    tmp.mergedIdx = cell2mat(arrayfun( @(x) [1:x]', toexpand,'UniformOutput',false ) ); % Give each segment its relative index
                    
                    tmp.Lifetime_seg = cellfun( @(x) numel(x), tmp.xSeg ); 
                    tmp.Lifetime_hmmseg = cellfun( @(x) numel(x), tmp.hmm_xSeg );
                    % This next line does a lot of work %
                    % Segment is the ONLY segment in a track: zero
                    % Segment is the FIRST segment in a track: negative one
                    % Segment is MIDDLE segment in a track: two
                    % Segment is the LAST segment in a track: positive one

                    tmp.multiSegmentTrack_identifier = cell2mat( arrayfun( @(x) [repmat(ne(x,1),1,min(1,x)),repmat(2,1,x-2),repmat(-1,1,min(1,x-1))]', toexpand,'UniformOutput',false) );

                    obj.mergedSegmentsTable.(objectnames{1}) = tmp;

                catch
                    
                    obj.mergedSegmentsTable.(objectnames{1}) = table();
                    
                end
            end
            
        end
        
        function makeMarkovTables( obj )
            
            letters = obj.markovLetters;
            
            % This slow step computes the Markov matrix for each of the
            % objects
            objects_ = fields( obj.sequencesTable );
            
            % Within each structure we want to:

            % (1) Compute the transitions for this object and place
            % them into a matrix of size: 
            % (# sequences observed x num letters x num letters)
            % (2) Take the average of the transition matrices over all
            % the unique sequences
            %
            % This assumes that the distribution of transitions is the
            % same:
            % (1) Across sequences
            % (2) At different points in a sequence
            for object_ = fields( obj.sequencesTable )'
                
                tmp = cell2mat( rowfun(@(states,count,length) obj.transitionTable( states{1}, letters ) .* count, obj.sequencesTable.(object_{1}).dictionaryTable, 'OutputFormat', 'cell' ) );
                obj.sequencesTable.(object_{1}).markov = squeeze(sum( reshape( tmp, numel(letters), size(tmp,1)/numel(letters), numel(letters) ), 2 ));
                
            end
            
        end
        
        function markovResult = queryMarkov( obj, transitionType )
           
            letters = obj.markovLetters;
            % Make a dictionary %
            [x,y] = meshgrid([1:numel(letters)]);
            
            % This creates a cell of strings, which identifies each
            % transition type
            transition_dict = arrayfun( @(x,y) sprintf('%s%s',x,y), letters(x(:)),letters(y(:)) ,'UniformOutput',false);
            transition_dict = reshape( transition_dict, numel(letters), numel(letters) );
            
            [state1,state2] = find( cellfun( @(x) ~isempty(x), strfind( transition_dict, transitionType ) ) == 1 );
            
            markovResult = structfun( @(x) x.markov(state1,state2), obj.sequencesTable )
            
        end
        
        function makeBoxplot( obj, data )
            
            figure('color','w');
            % Ensure sorting by absoluteidx
            mysubfolderstable = sortrows(obj.subfoldersTable,'AbsoluteIdxToSubfolders');
            
            appended_table = table( data,mysubfolderstable.Supercluster,mysubfolderstable.Shortname, 'VariableNames', {'Data','Supercluster','Shortname'} );
            
            grps = unique( appended_table.Supercluster );
            grpmeans = arrayfun( @(x) nanmedian( appended_table( appended_table.Supercluster == x, : ).Data ), grps );
            
            for i = 1:numel( grpmeans ); appended_table.GrpMean( ismember(appended_table.Supercluster, i ) ) = grpmeans(i); end
            appended_table = sortrows(appended_table,'GrpMean');
            [~,~,c] = unique( appended_table.GrpMean );
            
            appended_table.Rank = nan(size(appended_table,1),1);
            appended_table.Rank( find(c<=numel(grps)) ) = c( find(c<=numel(grps)) );
            
            boxplot ( appended_table.Data, appended_table.Rank ); 
            hold on;
            scatter( appended_table.Rank, appended_table.Data, 'jitter', 'on', 'jitteramount', 0.1, 'markerfacecolor', 'w'  ); 
            camroll(-90);
            set(gca,'TickDir','out'); box off;
            
            % Check for empty boxes %
            boxes = findobj(gca,'Tag','Box');
            
            % Add labels %
            [~,b] = sort(grpmeans);
            mylabels = unique( appended_table.Shortname );
            mylabels = mylabels(b);
            set(gca,'XTickLabel',mylabels);
            
            % Change x-label 
            myscatter=findobj(gca,'Type','Scatter');
            ylim([min( myscatter.YData ),max( myscatter.YData )]);
            
        end
        
        function showTrees( obj )
            w = warning('off','all');
                for i = unique(obj.subfoldersTable.Supercluster)'

                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   % A subcluster is defined as all the clusters that match a cluster   %
                   % number; this can be a set of cells that got a particular treatment %
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                   theseSubclusters = obj.subfoldersTable.Subcluster( find( obj.subfoldersTable.Supercluster == i ), : );
                   subTable = obj.subfoldersTable( find( obj.subfoldersTable.Supercluster == i ), :);

                   if size(subTable,1) > 1
                       y = histc(theseSubclusters,[1:1:max(theseSubclusters)]);
                       v = [];
                       for j = 1:numel(y)
                          v = [v, j*ones( 1, y(j) )+numel(v)];
                       end

                       N = max(theseSubclusters) + numel(theseSubclusters);
                       w = setxor( [1:N], v);

                       % Can't do much with cell arrays so start from a table %
                       myTmp = table('Size',[ N ,2 ],'VariableTypes',{'char','double'});

                       col=5;

                       tmptable = obj.subfoldersTable( find( obj.subfoldersTable.Supercluster == i ), :);

                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                       % Vectorize and find common text across filename                       %
                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                       atable = vectorizeTableText( subTable(:,5) );
                       mysearch = find(std(atable,1)>0);
                       if ~isempty(mysearch); cutoff = mysearch(1); else; cutoff = 1; end;
                       
                       myTmp(w,1) = rowfun( @cellstr, table( char( atable(:,[cutoff:end]) ) ) ); % Cleaned up filenames
                       myTmp(w,2) = subTable(:,4); % Supercluster index for these filenames
                       myTmp(setxor([1:N],w),2) = table( unique( tmptable.Supercluster ) );

                       newf = @(Var1, Var2) { sprintf('%s %i',Var1{1},Var2) };
                       myTmpLabels = table2cell( rowfun(newf, myTmp) );

                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                       % End vectorizing and find common text across filename                 %
                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                       % Replace empty with blank %
                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%

                       %empties = find( cellfun(@isempty, myTmp) == 1);
                       %for i = empties'; myTmp{i} = ''; end

                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                       % End replacing empties    %
                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%

                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                       % Remove common path and place it in the title of the figure %
                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                       myTitle = cellstr(char( atable(1,[1:cutoff-1] ) ));
                       myTitle = regexprep(myTitle{1},'\\','\\\');
                       myTitle = sprintf('%s (Figure %i)',myTitle,i);

                       figure('Name',myTitle,'Color','w'); G = graph( v,w ); h=plot(G, 'NodeLabel', myTmpLabels); box off; set(gca,'XColor','w','YColor','w'); camroll(90)
                       set(gcf,'WindowState','maximized');
                       title(myTitle);
                       %fprintf('%s\n',myTitle);
                       pos = get(gca,'Position');
                       set(gca,'Position',pos.*[1,2,.2,1]);
                   end
                end
        end
        
        function sc = superclusters(obj, varargin)
           
           switch nargin
               case 1
                   
                   sc = obj.clustersTable.Supercluster;
                   
               case 2
                   
                   query = varargin{1};
                   sc = obj.clustersTable( find(cell2mat( cellfun(@(x) numel(regexpi(x,query)), ...
                       obj.clustersTable.Clustertext , 'UniformOutput', false) )==1), : ).Supercluster;
                   
               case 3
                   
                   query = varargin{1};
                   sc = obj.clustersTable( find(cell2mat( cellfun(@(x) numel(regexpi(x,query)), ...
                       obj.clustersTable.Clustertext , 'UniformOutput', false) )==1), : ).Supercluster;
                   
                   if strcmp(varargin{2},'not')
                        sc = setxor( obj.clustersTable.Supercluster, sc );
                   end
                   
           end
        end

    end
    
    methods(Static)
        
            function transitions = transitionTable( sequence, letters )
                
                % Takes a sequence and generates a transition matrix based
                % on the letters specified
                [x,y] = meshgrid([1:numel(letters)]);
                transitions = rowfun(@(x,y) numel(regexp( sequence, sprintf('%s%s',x,y),'match' )), table( letters(x(:)), letters(y(:)) ) , 'OutputFormat', 'uniform');
                transitions = reshape( transitions, sqrt(numel(transitions)), sqrt(numel(transitions)) );
                
            end
        
        
            function clustered = clusterTableList( myTable )
                
                if eq(1,numel(myTable)); clustered = 1; return; end;
                mytablearray_setdist = resultsClusterClass.textIntersections(myTable, 'method', 1);
                l = linkage(mytablearray_setdist,'single');
                clustered = cluster(l,'cutoff',.00001);
                
            end
            
            function mydistance = textIntersections( input_table, varargin )
                
                method_ = varargin{ find(strcmp(varargin,'method')==1)+ 1 };
                if isempty(method_); method_ = 1; end
                switch method_
                    case 1
                        %fprintf('Method 1');
                        atable = input_table;
                        if size(atable,1)<size(atable,2); atable = atable'; end;
                        if strcmp( class(atable),'table' ); atable = table2cell(atable); end;

                        distance_table = table( repmat( atable, numel(atable), 1 ), reshape( repmat( atable, 1, numel(atable))', numel(atable)^2, 1), ...
                            'VariableNames', {'Text1','Text2'} );
                        mydistance = @(x,y) numel( intersect( x{1},y{1} ) )/min( numel( x{1} ), numel( y{1} ) );
                        mydistance = reshape( rowfun( mydistance, distance_table(:,[1:2]),'OutputFormat','Uniform' ), numel( atable ), numel( atable ) );
                    case 2
                        %fprintf('Method 2');
                        atable = input_table;
                        mydouble = @(x) {double(x{1})};
                        mytablearray = table2array( rowfun( mydouble, atable ) );
                        mydistance = zeros( size(mytablearray,1), size(mytablearray,1) );

                        for i = 1:size(mytablearray,1)
                            for j = 1:size(mytablearray,1)
                                mydistance(i,j) = numel( intersect(mytablearray{i},mytablearray{j}) )/min( numel(mytablearray{i}), numel(mytablearray{j}) );
                            end
                        end
                
                end
            
            
    end
        
end
end
