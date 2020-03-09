classdef segsTableClass < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        segsTable;
        metadata;
    end
    
    properties(GetAccess='private',Constant)    
            varTypes = {'uint8','uint8','uint8','uint8','uint8','uint8','cell','cell','logical'};
            varNames = {'segIdx','trackIdx','segStart','segEnd','Nframes','segType','x','y','nan'};
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%
        % CONSTRUCTOR FUNCTION %
        %%%%%%%%%%%%%%%%%%%%%%%%
        function obj = segsTableClass(varargin)
            
            if strcmp( class(varargin{1}),'double')
                obj.metadata.obj_idx = varargin{1};
                obj.metadata.fileStruct = {};
                obj.metadata.Type = 'tracks';
                obj.metadata.Comments = 'Empty tracks';
                obj.segsTable = table('Size',[0 numel(obj.varNames)],'VariableTypes',obj.varTypes,'VariableNames',obj.varNames);
                return
            end
            
            tracksTableObj = varargin{1};
            obj_idx = varargin{2};
            fileStruct = tracksTableObj.metadata.fileStruct;
            
            % Create default metadata
            obj.metadata = tracksTableObj.metadata;
            obj.metadata.Type = 'segs';
            obj.metadata.obj_idx = obj_idx;
            
            % Create a default table in case of premature return
            obj.segsTable = table('Size',[0 numel(obj.varNames)],'VariableTypes',obj.varTypes,'VariableNames',obj.varNames);
                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%% SEGMENTATION DATA PARSED HERE %%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Locate the Segmentation file in the Files cell
            SegmentationFile = fileStruct.address_results;
            if isempty( fileStruct.address_results ); obj.metadata.Comments = sprintf('No segmentation file found'); return; end
            if isempty( whos('-file',SegmentationFile,'results') ); obj.metadata.Comments = sprintf('Tracking file does not contain results variable'); return; end
            
            % If all errors pass, load segmentation results file
            results_ = load(SegmentationFile,'results');
            [trackIdx, segStart, segEnd, Nframes, segType] = obj.getSegments(results_.results);
            Nsegs = numel(trackIdx);
            
            % Altering the table variables will cause errors in rowfun
            % expressions below
            obj.segsTable = table('Size',[Nsegs numel(obj.varNames)],'VariableTypes',obj.varTypes,'VariableNames',obj.varNames);
            obj.segsTable.segIdx = [1:Nsegs]';
            [obj.segsTable.trackIdx, obj.segsTable.segStart, obj.segsTable.segEnd, obj.segsTable.Nframes, obj.segsTable.segType] = deal( trackIdx, segStart, segEnd, Nframes, segType );
            
            fprintf('Loaded segmentation file\n');
            % Optional, discarding NaN segments
            % obj.segsTable = obj.segsTable( isnan(obj.segsTable.segType)==0 ,:);
            % fprintf('Discarded %i NaN classified segments (out of total %i)\n', numel(trackIdx)-size(obj.segsTable,1), size(obj.segsTable,1) );

            tmp_x = tracksTableObj.tracksTable(obj.segsTable.trackIdx,'x');
            tmp_y = tracksTableObj.tracksTable(obj.segsTable.trackIdx,'y');

            [obj.segsTable.x,obj.segsTable.y,obj.segsTable.trackStart] = deal( tracksTableObj.tracksTable( obj.segsTable.trackIdx, : ).x,...
                tracksTableObj.tracksTable( obj.segsTable.trackIdx, : ).y,...
                tracksTableObj.tracksTable( obj.segsTable.trackIdx, : ).trackStart);
            
            fxn = @(segStart,segEnd,x,trackStart) { x{1}([segStart-trackStart+1:segEnd-trackStart+1]) };
            obj.segsTable.xSeg = table2array( rowfun(fxn, obj.segsTable(:, [3,4,7,10])) ); % rowfun outputs a table so to avoid creating a table in a table
            obj.segsTable.ySeg = table2array( rowfun(fxn, obj.segsTable(:, [3,4,8,10])) ); % use array2table
            obj.segsTable.nan = cellfun(@any, cellfun( @isnan, obj.segsTable.xSeg , 'UniformOutput', false));
            obj.segsTable.abs_segStart = obj.segsTable.segStart + tracksTableObj.tracksTable.trackStart( obj.segsTable.trackIdx ) - 1;
            obj.segsTable = obj.segsTable(:,{'trackIdx','segIdx','abs_segStart','segStart','segType','xSeg','ySeg','nan'}); % Rearrange
            obj.metadata.Comments = 'NA';
            
            
        end
        
        function getPositionStats(obj)
% Calculates min_x,mean_x,max_x,min_y,mean_y,mean_y,max_y,Lifetime for each segment            
            if and( ~isempty( obj.segsTable ), not(any(cell2mat(strfind( obj.segsTable.Properties.VariableNames, 'max_x' )))));
                output = cell2mat( rowfun( @(x,y) [ min(x{1}), nanmean(x{1}), max(x{1}), min(y{1}), nanmean(y{1}), max(y{1}), numel(x{1}) ] , obj.segsTable(:,{'xSeg','ySeg'}) ,'OutputFormat', 'cell') );
                output = array2table(output,'VariableNames',{'min_x','mean_x','max_x','min_y','mean_y','max_y', 'Lifetime'} );
            
                [obj.segsTable.min_x,obj.segsTable.mean_x,obj.segsTable.max_x] = deal( output.min_x,output.mean_x,output.max_x );
                [obj.segsTable.min_y,obj.segsTable.mean_y,obj.segsTable.max_y] = deal( output.min_y,output.mean_y,output.max_y );
                obj.segsTable.Lifetime = output.Lifetime;
                fprintf('Calculated position statistics\n');
            end
            
        end
        
        
        function plot(obj,segIdx,varargin)
            
           if nargin==1
               segIdx = unique(obj.segsTable.segIdx);
           end
           
           % Plot multiple tracks if they're present
           segcolors = [1.0000,0.5843,0.8392; % 6th color in pinks (I)
                        0.13,0.39,0.85; % 1st color in paleblues (C)
                        0, 0.5882, 0.4333; % 1st color in palegreens (D)
                        0, 0, 0; % Black (SuperD)
                        .9,.9, 0]; 
           these_segs_colors = obj.segsTable.segType+1; % Add one to bring index between 1:4
           these_segs_colors( isnan(obj.segsTable.segType) ) = 5; % Allow NaNs to be plotted
           titles = {'Immobile','Confined','Diffusing','Superdiffusing','NaNs'};
           
           sub_ax = arrayfun(@(x) subplot(1,5,x,'NextPlot','add'), [1:5] );
           arrayfun(@(x) set(sub_ax(x),'Title',text(0,0,titles{x})), [1:5] );
           if gt(numel( segIdx ),1)
               %thisplot = arrayfun(@(thisIdx) plot( obj.segsTable(thisIdx,:).xSeg{1},...
               %      obj.segsTable(thisIdx,:).ySeg{1}, 'color', segcolors(these_segs_colors(thisIdx),:),...
               %      'Parent', sub_ax(these_segs_colors(thisIdx)) ), segIdx,...
               %      'UniformOutput',false,'ErrorHandler', @(x,y) 0 ); 
               thisplot = arrayfun(@(thisIdx) patch( obj.segsTable(thisIdx,:).xSeg{1},...
                     obj.segsTable(thisIdx,:).ySeg{1}, [0,0,0], 'edgecolor', segcolors(these_segs_colors(thisIdx),:),...
                     'FaceColor','none','EdgeAlpha',.1,'Parent', sub_ax(these_segs_colors(thisIdx)) ), segIdx,...
                     'UniformOutput',false,'ErrorHandler', @(x,y) 0 );
           % Gather y-lims and standardize
           %axlims = cell2mat(arrayfun(@(x) [ get(sub_ax(x),'Xlim'), get(sub_ax(x),'Ylim') ], [1:5] , 'UniformOutput', false)');
           %axlims = [ min(axlims(:,1),[],1), max(axlims(:,2),[],1), min(axlims(:,3),[],1), max(axlims(:,4),[],1) ]; % Minimize the xmin, ymin
           arrayfun(@(x) set(sub_ax(x),'XLim',[obj.segsSummary.min_x,obj.segsSummary.max_x],...
                                        'YLim',[obj.segsSummary.min_y,obj.segsSummary.max_y] ), [1:5] );
           suptitle( obj.metadata.Fullname );
           
           else
               
               thisplot = plot( obj.segsTable(segIdx,:).x{1},...
                     obj.segsTable(segIdx,:).y{1} ); 
           end
           
           % Check for optional arguments
           if ~isempty(varargin)
                arrayfun( @(thisline) arrayfun( @(x) set( thisline, varargin{2*x-1}, varargin{2*x} ), [1:numel(varargin)/2] ), thisplot );
           end
           set(gca,'TickDir','out');
           
           
        end
        
        
        function head(obj,varargin)
            if nargin==1
                disp(obj.table([1:5],:));
            else
                disp(obj.table([1:varargin{1}],:));
            end
        end
        
        function summary(obj)
            means = '';
            for i = 1:size(obj.table,2)
                try
                means=strcat(means,sprintf(' %1.2f', mean(obj.table{:,i})));
                catch
                means=strcat(means,' N/A');
                end
            end
            disp(means)
        end
        
        function showFilename(obj)
            fprintf('%s\n',obj.filename);
        end
        
        
        
    % Overloaded functions %

    function hits = find(obj,search_query)

        equality_type = cell2mat(regexp(search_query,'(<=)|(>=)|==|(<>)|(<)|(>)','match'));
        value = regexp( search_query, '(\d)$', 'match' ); value = str2double(value{1});
        parameter = regexp( search_query, '[a-zA-Z]+', 'match' ); parameter = parameter{1};

        switch equality_type;
            case '<'
                hits = find( lt(obj.segsTable.(parameter), value) == 1 );
            case '>'
                hits = find( gt(obj.segsTable.(parameter), value) == 1 );
            case '<='
                hits = find( le(obj.segsTable.(parameter), value) == 1 );
            case '>='
                hits = find( ge(obj.segsTable.(parameter), value) == 1 );
            case '<>'
                hits = find( ne(obj.segsTable.(parameter), value) == 1 );
            case '=='
                hits = find( eq(obj.segsTable.(parameter), value) == 1 );
        end

    end
    
    end
    
        
        
    methods(Static)
        
        function output_tbl = expandFromCol(my_tbl, col)
           % Given a table with columns a,b,c, ...
           % 
           % a  b     c
           % =  =  =======
           %       [n x m]
           %
           % If c has elements of size [n x m]
           % then a new table is created
           % with n rows
           output_tbl = [];
           for i = 1:size(my_tbl,1)
              output_tbl = [ output_tbl; repmat(i, size( my_tbl(i,:).(sprintf('%s',col)){1} ,1), 1), my_tbl(i,:).(sprintf('%s',col)){1} ];
           end
        end
        
        function output_cell = parseStates(ML_states, Nstate)
            % Search tokens of repeating N's within ML_states which has
            % data like '11111' '1112222111' '222111' (or '11222333')
            % Find the start and end of each match and produce a table into
            % varargout
            fprintf('Parsing state %i\n',Nstate);
            parseFxn = @(x) [ regexp( num2str(x,'%i'), sprintf('[%i]{1,}',Nstate),'start' ); regexp( num2str(x,'%i'), sprintf('[%i]{1,}',Nstate),'end' ) ]';            
            output_cell = cellfun(parseFxn, ML_states, 'UniformOutput', false);

            addIdx = @(x) [ [1:size(x,1)]', x ]; % An index, the start frame, the end frame, and a column for the # of frames in the state
            output_cell = cellfun(addIdx, output_cell, 'UniformOutput', false);
            
        end
        
        
        function varargout = getSegments(results) % Works on a results variable from DC-MSS output
            [all_start,all_end,all_type,all_idx] = deal([],[],[],[]);
            
            for i = 1:numel(results)
                Nsegs = size(results(i).segmentClass.momentScalingSpectrum,1);
                % There is a potential issue here where
                % momentScalingSpectrum makes the ending of one segment the
                % same as the beginning of another segment
                [start_,end_,type_] = deal( results(i).segmentClass.momentScalingSpectrum(:,1),...
                                            results(i).segmentClass.momentScalingSpectrum(:,2),...
                                            results(i).segmentClass.momentScalingSpectrum(:,3) );
                all_idx = [all_idx;repmat(i,Nsegs,1)];
                all_start = [all_start;start_];
                all_end = [all_end;end_];
                all_type = [all_type;type_];
            end
            varargout{1} = all_idx; varargout{2} = all_start; varargout{3} = all_end; varargout{4} = all_end-all_start; varargout{5} = all_type;
        end
        
        
    end
end

