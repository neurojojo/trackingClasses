classdef findFoldersClass < handle

    % Demo:
    %
    % options.TLD = 'Z:/#BackupMicData';
    % options.search_folder = '_SM';
    % options.search_subfolder = 'analysis_output.mat';
    % options.optional_args = {'FilesToFind','signe'};
    % tic; signeFolders = findFoldersClass(options); toc;
    %
    % signeFolders.makeTrackObjs;
    % signeFolders.makeSegObjs; 
    % signeFolders.makeHMMSegObjs;
    %
    % To parse filenames:
    % signeFolders.assignNames();
    %
    % Extra processing for HMM:
    % signeFolders.switchHMMstates;
    % signeFolders.patchTracks;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor method takes one structure as an argument (options)         %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %   options fields:
    %       TLD: The top level directory where all folders are located
    %           search_folder: This specifies the text of the FOLDERS to return
    %           ie. "_SM_" will return all folders containing those initials
    %       search_subfolder: This specifies the FILENAME to look for within the
    %           subfolders, and will return a table with locations to every such
    %           filename (use analysis_output.m for Bayesian, results.m for
    %           Tracking, etc)
    %       savelocation: This specifies the location to save the tables that
    %           are output
    %       optional_args: Goes only to makeTrackObjs and makeHMMSegObjs
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   In-place methods:                                                    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %       .makeTrackObjs() produces tracks from Tracking.m files
    %       .makeSegObjs() produces segs from results.m files
    %       [HMM only] .makeHMMSegObjs() produces hmmsegs from 
    %       [HMM only] .switchHMMstates() goes into each hmmsegs object and determines
    %       whether to switch the data in the State1 and State2 fields
    %
    
    properties
        % DATA containing Tracking output
        tracks = struct();
        % DATA containg DC-MSS output
        segs = struct(); 
        % DATA containing Bayesian output
        hmmsegs = struct();
        
        % CELL ARRAY containing top-level directories containing each cell
        folderTable;
        
        % TABLE containing directories from within each top-level directory
        subfolderTable;
        
        % TABLE containing all of the parameters (first call collectParameters function)
        trackingParametersTable;
        
        % Creates readable names for the subfolders (first call assignNames and *CUSTOM* parseFilename.m)
        namesTable;
        
        % A structure with two fields (options and logs)
        metadata;
            % options: TLD, search_folder, search_subfolder, optional_args
            % logs: tracks,segs,hmmsegs (output of loading)
        
    end
    
    properties(Constant)
        
        Nstates = 2; % This will inform the hmmsegs routines about the number of states being parsed, if no Bayesian or HMM analysis has been done then this can be ignored
        nparams = 18; % Deprecate eventually, currently gives you a table
        
    end
    
    methods
        function obj = findFoldersClass(options)
% Constructor function            
            TLD = options.TLD;
            folder_regexpstring = options.search_folder;
            file_regexpstring = options.search_subfolder;
            
            obj.metadata.options = options;

            ALL_files=dir(TLD);
            
            % Restrict to DIRECTORIES:
            ALL_files=ALL_files( arrayfun( @(x) and( gt(numel(x.name),2), x.isdir ), ALL_files ), : );
            
            % Checking for 
            fprintf('Checking for %s\n', folder_regexpstring );
            fprintf('within subfolders of:\n')
            arrayfun(@(x) fprintf('%s\\%s\\\n', x.folder, x.name), ALL_files );
                        
            % Check each folders of the TLD to find folder_regexpstring matches
            % Result goes to obj.folderTable
            subdirectories = arrayfun(@(x) dir( sprintf('%s\\%s',x.folder,x.name) ), ALL_files, 'UniformOutput', false );
            
            %% Contents of those directories
            subdirectory_contents = arrayfun( @(x) dir( sprintf('%s\\%s\\',x.folder,x.name) ), ALL_files  , 'UniformOutput', false);
            
            allresults = [];
            for these_contents = subdirectory_contents'
                all_files_this_subdirectory = arrayfun(@(y) regexp( y{1}.name, folder_regexpstring ),...
                                                              arrayfun(@(x) x, these_contents{1}, 'UniformOutput', false), 'UniformOutput', false );
                allresults = [ allresults; arrayfun(@(x) sprintf( '%s\\%s', x.folder, x.name),...
                                                         these_contents{1}( find(arrayfun( @(x) numel(x{1}), all_files_this_subdirectory )==1) ),'UniformOutput',false) ];
            end
            
            obj.folderTable = allresults;
            
            % Check each subfolder from above for file_regexpstring matches
            % Result goes to obj.subfolderTable
            mytable = table();
            for i = 1:size(allresults)
               myt = rdir( sprintf('%s\\**\\%s', allresults{i}, file_regexpstring ) ); % For Bayesian: use analysis_output.mat
               if ~isempty(myt); mytable = [mytable; cell2table( extractfield(myt,'name')' )]; end
               fprintf('Currently located %i folders containing the file you want\n',size( mytable, 1 ));
            end
            
            obj.subfolderTable = mytable;
            obj.subfolderTable.Properties.VariableNames={'Name'};
            
        end
        
        function collectParameters(obj)
% Creates trackingParametersTable (We need to have found a tracking file, so every tracksTableClass object will have parameters)
            %
            % The best way to locate these tracking files is through the
            % linked metadata within each tracks object
            output_cell = struct2cell( structfun(@(x) sprintf('%s\\Tracking.mat',x.metadata.Directory), obj.tracks , 'UniformOutput', false, 'ErrorHandler', @(x,y) obj.doNothing() ) );
            
            parameters_out = cellfun(@(x) load(x,'costMatrices','gapCloseParam'), output_cell, 'UniformOutput', false, 'ErrorHandler', @(x,y) obj.doNothing() );
            
            % Retrieve all the parameters from the cell arrays created in
            % the loading step
            parameters_table = cellfun( @(x) struct2table( x.costMatrices(2).parameters, 'AsArray', true ), parameters_out, 'ErrorHandler', @(x,y) obj.doNothing(), 'UniformOutput', false );
            
            for i = 1:numel(parameters_table); 
                if numel(parameters_table{i})<18; [parameters_table{i}.gapExcludeMS,parameters_table{i}.strategyBD] = deal(nan,nan); 
                end
            end
            all_parameters = table(); for this_table = parameters_table'; if istable(this_table{1}); all_parameters = [ all_parameters; this_table{1} ]; 
                else
                    emptyrow = array2table( nan(1, obj.nparams), 'VariableNames', all_parameters.Properties.VariableNames );
                    [emptyrow.brownScaling, emptyrow.ampRatioLimit,emptyrow.linScaling] = deal( [nan, nan], [nan, nan], [nan, nan] );
                    all_parameters = [ all_parameters; emptyrow ]; 
                end
            end
            all_parameters.brownStdMult = rowfun(@(x) {num2str(x{1}')}, all_parameters(:,4) );
            all_parameters.linStdMult = rowfun(@(x) {num2str(x{1}')}, all_parameters(:,11) );
            
            obj.trackingParametersTable = all_parameters;
            
        end
        %output = arrayfun( @(year) rowfun(@(x) ~isempty( regexp(x{1}, sprintf('%i',year) ) ), obj.subfolderTable(:,1) ), [2016:2019], 'UniformOutput', false );
            %output = cellfun( @(x) obj.subfolderTable( find( x.Var1==1 ), : ), output, 'UniformOutput', false );
            %1
        
        function switchHMMstates(obj)
% This function checks whether the metadata containing the diffusion coefficient requires the diffusion states to be switched, switchDC will be added to the metadata if data from state1 was switched with data from state2

           mydiff = @(x) any( gt( diff(x.metadata.DiffCoeff), 0 )); % Is positive only if DC1 < DC2 
           % Our assumption is that DC1 should be > DC2
           toswitch = find( structfun( mydiff, obj.hmmsegs, 'UniformOutput', true ) == 1);
           for i = toswitch'
               tmp=obj.hmmsegs.(sprintf('obj_%i',i)).brownianTable.State1; obj.hmmsegs.(sprintf('obj_%i',i)).brownianTable.State1 = obj.hmmsegs.(sprintf('obj_%i',i)).brownianTable.State2; 
               obj.hmmsegs.(sprintf('obj_%i',i)).brownianTable.State2 = tmp;
               obj.hmmsegs.(sprintf('obj_%i',i)).metadata.DiffCoeff = fliplr( obj.hmmsegs.(sprintf('obj_%i',i)).metadata.DiffCoeff );
               obj.hmmsegs.(sprintf('obj_%i',i)).metadata.switchDC = 1;
           end
           not_toswitch = find( structfun( mydiff, obj.hmmsegs, 'UniformOutput', true ) == 0);
           for i = not_toswitch'
               obj.hmmsegs.(sprintf('obj_%i',i)).metadata.switchDC = 0;
           end
        end
        
        function makeTrackObjs(obj,varargin)
% Function that fills the tracks structure with tracksTableClass objects
            if nargin>1; mystr = varargin{1}; else; mystr = ''; end
            
            for i = 1:size(obj.subfolderTable)
               searchquery = regexp( obj.subfolderTable(i,:).Name{1}, sprintf('.*%s.*[Ch1]',mystr), 'match'); 
               try
                   tmp_ = tracksTableClass( searchquery{1}, i, obj.metadata.options.optional_args );
                   obj.tracks.(sprintf('obj_%i',i)) = tmp_;
                   obj.metadata.logs.tracks{i} = sprintf('Success');
               catch
                   obj.tracks.(sprintf('obj_%i',i)) = tracksTableClass(i);
                   obj.metadata.logs.tracks{i} = sprintf('%i failed: %s (%s)', i, lasterr, datetime()); % Tell on the failing file
                   fprintf('Created an empty table for obj_%i',i);
               end
            end
            
        end
        
        function makeSegObjs(obj)
% Function that fills the segs structure with segsTableClass objects
            for i = 1:size(obj.subfolderTable) % Leave where you left off power
                try
                    tmp_ = segsTableClass( obj.tracks.(sprintf('obj_%i',i)), i, obj.metadata.options.optional_args );
                    obj.segs.(sprintf('obj_%i',i)) = tmp_;
                    obj.metadata.logs.segs{i} = sprintf('Success');
                catch
                    obj.segs.(sprintf('obj_%i',i)) = segsTableClass(i);
                    obj.metadata.logs.segs{i} = sprintf('%i failed: %s (%s)', i, lasterr, datetime()); % Tell on the failing file
                end
            end
        end
        
        function computeRelativeSegIdx(obj)
% Runs expand_DC_MSS_Segs within each seg object
            obj.segs = structfun( @(x) obj.expand_DC_MSS_Segs(x), obj.segs,'ErrorHandler',@(x,y) obj.doNothing ,'UniformOutput',false);
        end
        
        function output = expand_DC_MSS_Segs(obj,input_structure)
% Runs from within computeRelativeSegIdx (currently runs within a try-catch-end) - identifies the segment in a segsTable as either being first, intermediate, or last
            try
                toexpand = histc( input_structure.segsTable.trackIdx, [1:max(input_structure.segsTable.trackIdx)] ); % Find tracks with multiple segments (they will not be 1 entries in histogram)
                input_structure.segsTable.segIdx_relative = cell2mat(arrayfun( @(x) [1:x]', toexpand,'UniformOutput',false ) ); % Give each segment its relative index
                input_structure.segsTable.singleSegmentTrack_identifier = [ eq( diff( input_structure.segsTable.segIdx_relative,1 ), 0 ); 0 ];
                
                % This next line does a lot of work %
                % Segment is the ONLY segment in a track: zero
                % Segment is the FIRST segment in a track: negative one
                % Segment is MIDDLE segment in a track: two
                % Segment is the LAST segment in a track: positive one
                
                input_structure.segsTable.multiSegmentTrack_identifier = cell2mat( arrayfun( @(x) [repmat(ne(x,1),1,min(1,x)),repmat(2,1,x-2),repmat(-1,1,min(1,x-1))]', toexpand,'UniformOutput',false) );
                output = input_structure;
            catch
                output = input_structure;
            end
        end
        % End of 12/5 additions
        
        function makeHMMSegObjs(obj)
% Function that fills the hmmsegs structure with brownianTableClass objects
            for i = 1:size(obj.subfolderTable) % Leave where you left off power
                try
                    tmp_ = brownianTableClass( obj.segs.(sprintf('obj_%i',i)), i, '' );
                    obj.hmmsegs.(sprintf('obj_%i',i)) = tmp_;
                    obj.metadata.logs.hmmsegs{i} = sprintf('Success for obj %i',i);
                catch
                    obj.hmmsegs.(sprintf('obj_%i',i)) = brownianTableClass(i);
                    obj.hmmsegs.(sprintf('obj_%i',i)).metadata.logs.hmmsegs{i} = sprintf('%i failed: %s (%s)', i, lasterr, datetime()); % Tell on the failing file
                    fprintf('Failure for obj %i',i);
                end
            end
            
        end
       
        function calculatePositionStats(obj)
% Runs segs subfunction (getPositionStats) which calculates min_x,mean_x,max_x,min_y,mean_y,mean_y,max_y,Lifetime for each segment
            structfun( @(x) x.getPositionStats(), obj.segs, 'ErrorHandler', @(x,y) [] );
        end
        
        function assignNames(obj)
% Runs the custom parseFilename function on the subfolderTable and fills in namesTable with readable titles for each subfolder 
            mynames = rowfun( @parseFilename, obj.subfolderTable );
            mynames = struct2table( mynames.Var1 );
            mynames = rowfun( @convertRowToStr, mynames );
            mynames = table( [1:numel(mynames)]', table2array( mynames ) , 'VariableNames', {'AbsoluteIdxToSubfolders','Shortname'} )
            obj.namesTable = mynames;
            
            for i = obj.namesTable.AbsoluteIdxToSubfolders'
                if ~isempty( obj.segs.(sprintf('obj_%i',i)) )
                    obj.segs.(sprintf('obj_%i',i)).metadata.Fullname = sprintf('%s (%i)', obj.namesTable(i,:).Shortname{1}, i);
                end
            end
            
        end
        
        function clearTables(obj, varargin)
% Removes brownianTableClass objects if an object number and reason for deletion are specified
            if nargin==3
                objToClear = varargin{1};
                comment = varargin{2};
                if and( isnumeric(objToClear) , ischar(comment) )
                    obj.hmmsegs.(sprintf('obj_%i',objToClear)) = brownianTableClass( objToClear, comment);
                    fprintf('Cleared out Brownian Table object %i for reason: %s\n', objToClear, comment);
                end
            end
            
            if ~isempty( strfind( varargin{1},'.csv' ) )
                myt = readtable(varargin{1},'delimiter',',');
                myfxn = @(x) sum(find( ismember( obj.subfolderTable.Name , x ) == 1 ))
                toremove = rowfun( myfxn , myt, 'OutputFormat', 'uniform' );
                comment = sprintf('Removed through %s',varargin{1});
                for i = toremove'; if i>0; obj.hmmsegs.(sprintf('obj_%i',i)) = brownianTableClass( i, comment); fprintf('Emptied obj_%i Browniantables\n',i); end; end
            end
        end
        
        function patchTracks(obj)
% Creates the tracksInSeg column of the State1 and State2 tables, containing the number in the sequence of that track (for the respective State)
            myobjs = fields( obj.hmmsegs );
            
            for I = myobjs'
                thisObj = I{1};
                % Currently this only works for two state models
                if and( ~strcmp( obj.hmmsegs.(thisObj).metadata.Type, 'Error' ), isfield( obj.hmmsegs.(thisObj).brownianTable, 'State1' ) ); 
                    tmp = [ obj.hmmsegs.(thisObj).brownianTable.State1;obj.hmmsegs.(thisObj).brownianTable.State2];
                    segs = tmp.segIdx;
                    segs_histogram = table( unique(segs), histc( segs, unique(segs) ) , 'VariableNames', {'segIdx','NumSegs'} );
                    segNumber = zeros( size(tmp,1), 1 );

                    for i = unique(segs_histogram.NumSegs)'
                        theseSegs = segs_histogram.segIdx( ismember( segs_histogram.NumSegs, i ) ); % The indices of segments 
                        segNumber( find(ismember( tmp.segIdx, theseSegs ) == 1) ) = i;
                    end
                    
                    try
                        obj.hmmsegs.(thisObj).brownianTable.State1.tracksInSeg = segNumber([1:numel( obj.hmmsegs.(thisObj).brownianTable.State1.tracksInSeg )]);
                        obj.hmmsegs.(thisObj).brownianTable.State2.tracksInSeg = segNumber([numel( obj.hmmsegs.(thisObj).brownianTable.State1.tracksInSeg )+1:numel(segNumber)]);
                    catch
                        1
                    end
                end
            end
            
        end
               
        function getTrackBoundaries( obj )
% Calls on getTrackBoundaries from the tracksTableClass to output x,y positions of a mask encompassing all tracks, stored as a property of tracksTableClass (trackBoundaries)
            structfun( @(x) x.getTrackBoundaries(), obj.tracks );
        end
        
        function getBoundaryStats( obj )
% Calls getBoundaryStats on every object in the tracks structure, which retrieves the area and perimeter of a masked version of the track boundaries, stores the rest as a table in the boundaryStats property
            structfun( @(x) x.getBoundaryStats(), obj.tracks, 'ErrorHandler', @(x,y) table(nan,nan,'VariableNames',{'Area','Perimeter'} ), 'UniformOutput', false);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Length parsing functions %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function getTrackLengths( obj )
% Computes the lifetime for every object in the tracks structure
            structfun( @(x) x.getTrackLengths(), obj.tracks, 'ErrorHandler', @(x,y) [] );
        end
        
        function getSegLengths( obj )
% Computes the lifetime for every object in the segs structure
            structfun( @(x) x.getSegLengths(), obj.segs, 'ErrorHandler', @(x,y) [] );
        end
        
        function getHMMsegLengths( obj )
% Computes the lifetime for every HMM object in the hmmsegs structure
            structfun(@(x) getPositionStats(x), obj.hmmsegs, 'ErrorHandler', @(x,y) [] )
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Data aggregation functions %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function varargout = gather_boundaryStats( obj )
% Returns two vectors: the area and perimeter of tracks and places them into two cells (varargout 1 and 2) (takes no arguments)
            result = struct2array(structfun( @(x) [x.boundaryStats.Area,x.boundaryStats.Perimeter], obj.tracks,...
                'UniformOutput', false, 'ErrorHandler', @(x,y) [nan,nan]));
            result = reshape( result, 2, numel(result)/2 )';
            varargout{1} = result(:,1); %Area
            varargout{2} = result(:,2); %Perimeter
        end
      
        function result = gather_trackDensity( obj )
% Returns a vector: density of tracks (which is the # of rows in tracksTable divided by the boundaryStats.Area) (takes no arguments)
            result = struct2array(structfun( @(x) size(x.tracksTable,1)/x.boundaryStats.Area, obj.tracks,...
                'UniformOutput', false, 'ErrorHandler', @(x,y) nan));
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%        
        % House-keeping functions %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%

        function cleanUp( obj ) % (no arguments)
% Runs brownianTableClass function addEmpty to the hmmsegs structure
            structfun( @(x) addEmpty(x), obj.hmmsegs );
        end
        
        function varargout = doNothing(obj) % (no arguments)
% Deprecated function that returns empty
            varargout{1}=[];
        end
        
        function varargout = returnNaN(obj,varargin) % (one argument: length of nan array)
% Function that returns nan's with length specified in varargin{1}
            varargout{1}=repmat(NaN,1,varargin{1});
        end
        
    end
    
end