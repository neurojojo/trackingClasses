classdef searchObj  < handle
    % Creating a search object
    
    properties
        Shortname
        Indices
        sc_string
        sc
        sc_table
        idx
        mergedsegments
        hmm_state1 % Returns a cell for each object containing the non-end fragments that are HMM components (state 1)
        hmm_state2 % Returns a cell for each object containing the non-end fragments that are HMM components (state 2)
        summarytable
        hmm_state1_Ntracks % Returns a cell for each object containing the non-end fragments that are HMM components (state 1)
        hmm_state2_Ntracks % Returns a cell for each object containing the non-end fragments that are HMM components (state 2)
        hmm_state1_Nsegs % Returns a cell for each object containing the non-end fragments that are HMM components (state 1)
        hmm_state2_Nsegs % Returns a cell for each object containing the non-end fragments that are HMM components (state 2)
        Ntracks
        Nsegs
        summarylifetimes_sc
        colors
        grpcolors
        scs_order_cell
        grpcolors_cell
        crossTable
    end
    
    properties( Access = private )
    end
    
    % Use cases:
    
    % 
    % 
    % 
    methods
        function obj = searchObj(resultsClassObj, query, varargin)
            
            if nargin>2
                
                if strcmp(varargin{1}, 'sequenceByTrackIdx' )
                    tosearch = structfun( @(x) x.sequenceByTrackIdx , resultsClassObj.sequencesTable, 'UniformOutput', false );
                    for objs = fields(tosearch)'
                        tmp = find( cellfun( @(x) numel(cell2mat(regexp( x, query ))), tosearch.(objs{1}).Sequence ) > 0 );
                        obj.hits.(objs{1}) = tosearch.(objs{1}).trackIdx(tmp);
                    end
                end
                
                if any(cell2mat(arrayfun(@(x) ischar(x{1}), varargin, 'UniformOutput', false)))
                    dummy = find( cell2mat(arrayfun(@(x) ischar(x{1}), varargin, 'UniformOutput', false)) == 1 );
                    sorting = varargin{dummy+1};
                end
                
            end
            
            % Check if it's a textual query
            scs = cell2mat( cellfun( @(x) multipleRegex( resultsClassObj.clustersTable.Clustertext, {x} ),...
                query, 'UniformOutput', false )' );
            
            % Store a variable for the summary which contains the index
            tmp = cellfun( @(x) multipleRegex( resultsClassObj.clustersTable.Clustertext, {x} ), query, 'UniformOutput', false );
            obj.scs_order_cell = arrayfun( @(y) [1:y]', arrayfun(@(x) numel(x{1}), tmp ), 'UniformOutput', false );
            scs_order = cell2mat(arrayfun( @(y) [1:y]', arrayfun(@(x) numel(x{1}), tmp ), 'UniformOutput', false )');
            
            % Store a variable that keeps track of which search query
            % produced the supercluser
            query_order = cell2mat(arrayfun( @(x) repmat(x,1,numel(tmp{x})), [1:numel(tmp)] , 'UniformOutput', false))';
            
            count = 1;
            
            VariableTypes = {'double','double','char','double','double','double','double','double','double','double'};
            
            obj.summarytable = table('Size',[0, numel(VariableTypes)], 'VariableTypes', VariableTypes );
            
            for i = scs' % Goes through each of the superclusters
                
                obj.sc_table{count} = resultsClassObj.subfoldersTable( ismember( resultsClassObj.subfoldersTable.Supercluster, i ), : );
                obj.idx{count} = resultsClassObj.subfoldersTable( ismember( resultsClassObj.subfoldersTable.Supercluster, i ), : ).AbsoluteIdxToSubfolders;
                obj.sc_string{count} = sprintf('%i. %s',count,obj.sc_table{count}(1,:).Shortname{1});
                obj.mergedsegments{count} = arrayfun( @(x) resultsClassObj.mergedSegmentsTable.(sprintf('obj_%i',x))(:,{'trackIdx_left','segIdx_left','hmmSegIdx','segType_combined','Lifetime_seg','Lifetime_hmmseg','multiSegmentTrack_identifier'}), obj.sc_table{count}.AbsoluteIdxToSubfolders, 'UniformOutput', false, 'ErrorHandler', @(x,y) [] );
                
                % This part takes ONLY those hmm_states that are
                % intermediate in a track (not beginning or ending)
                obj.hmm_state1{count} = cellfun( @(x) x( and(x.multiSegmentTrack_identifier==2, x.segType_combined==101), : ).Lifetime_hmmseg, obj.mergedsegments{count}, 'UniformOutput', false, 'ErrorHandler', @(x,y) NaN );
                obj.hmm_state2{count} = cellfun( @(x) x( and(x.multiSegmentTrack_identifier==2, x.segType_combined==102), : ).Lifetime_hmmseg, obj.mergedsegments{count}, 'UniformOutput', false, 'ErrorHandler', @(x,y) NaN  );
                
                obj.hmm_state1_Ntracks{count} = cell2mat(cellfun( @(x) numel(unique(x( and(x.multiSegmentTrack_identifier==2, x.segType_combined==101), : ).trackIdx_left) ), obj.mergedsegments{count}, 'UniformOutput', false, 'ErrorHandler', @(x,y) NaN ));
                obj.hmm_state2_Ntracks{count} = cell2mat(cellfun( @(x) numel(unique(x( and(x.multiSegmentTrack_identifier==2, x.segType_combined==102), : ).trackIdx_left) ), obj.mergedsegments{count}, 'UniformOutput', false, 'ErrorHandler', @(x,y) NaN  ));
                
                obj.hmm_state1_Nsegs{count} = cell2mat(cellfun( @(x) numel(unique(x( and(x.multiSegmentTrack_identifier==2, x.segType_combined==101), : ).segIdx_left) ), obj.mergedsegments{count}, 'UniformOutput', false, 'ErrorHandler', @(x,y) NaN ));
                obj.hmm_state2_Nsegs{count} = cell2mat(cellfun( @(x) numel(unique(x( and(x.multiSegmentTrack_identifier==2, x.segType_combined==102), : ).segIdx_left) ), obj.mergedsegments{count}, 'UniformOutput', false, 'ErrorHandler', @(x,y) NaN  ));
                
                obj.Ntracks{count} = arrayfun( @(x) max( obj.mergedsegments{count}{x}.trackIdx_left ), [1:numel(obj.idx{count})],  'ErrorHandler', @(x,y) 0 );
                obj.Nsegs{count} = arrayfun( @(x) max( obj.mergedsegments{count}{x}.segIdx_left ), [1:numel(obj.idx{count})],  'ErrorHandler', @(x,y) 0 );
                
                %t.sc_table{1}.AbsoluteIdxToSubfolders
                
                %for n = 1:numel( obj.hmm_state1{count} )
                %    [muhat(n),muci(n,:)] = expfit( obj.hmm_state1{count}{n} );
                %end
                
                obj.summarytable = [obj.summarytable ; table( ...
                                                        repmat(query_order(count),numel(obj.sc_table{count}.Supercluster),1),...
                                                        obj.sc_table{count}.Supercluster,...
                                                        obj.sc_table{count}.Shortname,...
                                                        obj.idx{count},...
                                                        obj.hmm_state1{count},...
                                                        obj.hmm_state2{count},...
                                                        cellfun( @(x) nanmean( x ), obj.hmm_state1{count} ),...
                                                        cellfun( @(x) nanmean( x ), obj.hmm_state2{count} ),...
                                                        cell2mat(cellfun( @(x) chi2gof( x, 'CDF', makedist('Exponential',nanmean(x)) ), obj.hmm_state1{count}, 'ErrorHandler', @(x,y) 0, 'UniformOutput', false )),...
                                                        cell2mat(cellfun( @(x) chi2gof( x, 'CDF', makedist('Exponential',nanmean(x)) ), obj.hmm_state2{count}, 'ErrorHandler', @(x,y) 0, 'UniformOutput', false )))];
               
                count=count+1;
                
            end
            
            
            %obj.totalTracks{count} = cell2mat( cellfun( @(x) max( obj.mergedsegments{x}.trackIdx_left ), 
            
            obj.summarytable.Idx = [1:size(obj.summarytable,1)]';
            obj.summarytable.Properties.VariableNames = {'Searchcluster','Supercluster','Shortname','AbsoluteIdxToSubfolders','Lifetime_hmmseg1','Lifetime_hmmseg2','Mean_hmmseg1','Mean_hmmseg2','chi2_hmmseg1','chi2_hmmseg2','Idx'};
            % END OF summarytable %
            
            % BEGIN of summarylifetimes_sc %
            obj.summarylifetimes_sc = table( ...
                            unique(obj.summarytable.Supercluster, 'stable'),...
                            arrayfun( @(x) unique(obj.summarytable( obj.summarytable.Supercluster==x,:).Shortname), unique(obj.summarytable.Supercluster, 'stable') ),...
                            arrayfun( @(x) nanmean( obj.summarytable( obj.summarytable.Supercluster==x,:).Mean_hmmseg1 ), unique(obj.summarytable.Supercluster, 'stable') ),...
                            arrayfun( @(x) nanmean( obj.summarytable( obj.summarytable.Supercluster==x,:).Mean_hmmseg2 ), unique(obj.summarytable.Supercluster, 'stable') ),...
                            arrayfun( @(x) nanstd( obj.summarytable( obj.summarytable.Supercluster==x,:).Mean_hmmseg1 )/sqrt(numel(obj.summarytable( obj.summarytable.Supercluster==x,:).Mean_hmmseg1)), unique(obj.summarytable.Supercluster, 'stable') ),...
                            arrayfun( @(x) nanstd( obj.summarytable( obj.summarytable.Supercluster==x,:).Mean_hmmseg2 )/sqrt(numel(obj.summarytable( obj.summarytable.Supercluster==x,:).Mean_hmmseg2)), unique(obj.summarytable.Supercluster, 'stable') ),...
                            arrayfun( @(x) sum(obj.summarytable(obj.summarytable.Supercluster==x,:).chi2_hmmseg1), unique(obj.summarytable.Supercluster, 'stable'), 'UniformOutput', true ),...
                            arrayfun( @(x) sum(obj.summarytable(obj.summarytable.Supercluster==x,:).chi2_hmmseg2), unique(obj.summarytable.Supercluster, 'stable'), 'UniformOutput', true ));
            
                
            obj.summarylifetimes_sc.Properties.VariableNames = {'InClusterIdx','Shortname','Lifetime_S1','Lifetime_S2','SE_Lifetime_S1','SE_Lifetime_S2','chi2_hmmseg1','chi2_hmmseg2'};
            
            if exist('sorting')
                if eq( size(obj.summarylifetimes_sc,1), numel(sorting) )
                    obj.summarylifetimes_sc = obj.summarylifetimes_sc(sorting,:);
                    obj.summarylifetimes_sc.InClusterIdx = scs_order;
                end
            end
            
            % END of summarylifetimes_sc %
            
            obj.sc = scs';
            obj.Shortname = obj.summarytable.Shortname;
            obj.Indices = obj.summarytable.AbsoluteIdxToSubfolders;
            
        end
        
        function setcolors(obj, colors)
           obj.colors =  colors;
           obj.grpcolors = [];
           obj.grpcolors_cell = [];
           for i = 1:numel(obj.scs_order_cell)
               thesecolors = palette(colors{i});
               obj.grpcolors = [obj.grpcolors; thesecolors( obj.scs_order_cell{i}, : )];
               obj.grpcolors_cell = [ obj.grpcolors_cell; repmat( {colors{i}}, numel( obj.scs_order_cell{i} ), 1 ) ];
           end
        end
        
        function plot(obj, varargin)
            
            figure('color','w');
            my_ax = axes();
            
            % crossObj( label, Nentries, x0, xcenter, x1, y0, ycenter, y1, color, maxColor, parent, legend, colors )
            
            Nrows = numel(obj.summarylifetimes_sc.Shortname);
            Nentries = arrayfun( @(x) numel(x{1}), obj.idx )';
            
            if nargin==1

                obj.crossTable = table( obj.summarylifetimes_sc.Shortname,...                                             %label
                                    Nentries,...                                                                      %Nentries
                                    (obj.summarylifetimes_sc.Lifetime_S1-obj.summarylifetimes_sc.SE_Lifetime_S1),...  %x0
                                    obj.summarylifetimes_sc.Lifetime_S1,...                                           %xcenter
                                    (obj.summarylifetimes_sc.Lifetime_S1+obj.summarylifetimes_sc.SE_Lifetime_S1),...  %x1
                                    (obj.summarylifetimes_sc.Lifetime_S2-obj.summarylifetimes_sc.SE_Lifetime_S2),...  %y0
                                    obj.summarylifetimes_sc.Lifetime_S2,...                                           %ycenter
                                    (obj.summarylifetimes_sc.Lifetime_S2+obj.summarylifetimes_sc.SE_Lifetime_S2),...  %y1
                                    obj.summarylifetimes_sc.InClusterIdx,...                                          %color
                                    nan(Nrows,1),...                                                                  %maxColor
                                    repmat(my_ax,Nrows,1),...                                                         %parent
                                    obj.summarylifetimes_sc.Shortname,...                                             %for the legend
                                    obj.grpcolors_cell );                                                             %colors
                obj.crossTable.Properties.VariableNames = {'Label','Nentries','x0','xcenter','x1','y0','ycenter','y1','Color','MaxColor','Parent','Legend','Palette'};
            
            end
            
            rowfun( @crossObj, obj.crossTable );
            set(gca,'Xlim',[0,75],'YLim',[0,100],'TickDir','out');
            set(gcf,'Position',[340,320,1230,470]);
            xlabel('Fast state lifetime (frames)');
            ylabel('Slow state lifetime (frames)');
            textToTop(gca);
            grid on;
            
        end
        
        
        function plotchi2(obj, varargin)
            
            figure('color','w');
            left_ax = subplot(1,2,1);
            right_ax = subplot(1,2,2); 
            set(left_ax, 'NextPlot','add');
            set(right_ax, 'NextPlot','add');
            
            % Collect chi2_hmmseg1
            chi2_hmmseg1 = arrayfun(@(x) sum(obj.summarytable( obj.summarytable.Supercluster==x,: ).chi2_hmmseg1), unique( obj.summarytable.Supercluster, 'stable' ) );
            chi2_hmmseg2 = arrayfun(@(x) sum(obj.summarytable( obj.summarytable.Supercluster==x,: ).chi2_hmmseg2), unique( obj.summarytable.Supercluster, 'stable' ) );
            N = arrayfun(@(x) numel((obj.summarytable( obj.summarytable.Supercluster==x,: ).chi2_hmmseg2)), unique( obj.summarytable.Supercluster, 'stable' ) );
            
            scs = unique( obj.summarytable.Supercluster, 'stable' );
            legends = unique( obj.summarytable.Shortname, 'stable' );
            
            legends = rowfun( @(x,y) sprintf('%s (N=%i)',x{1},y), table( legends, N ), 'OutputFormat', 'cell' );
            
            legends
            
            colors = lines(100);
            
            % Left plot
            arrayfun( @(x) plot( chi2_hmmseg1(x), chi2_hmmseg2(x) , '.', 'MarkerSize', 24, 'color', colors(x,:), 'parent', left_ax ), [1:numel(chi2_hmmseg1)] );
            xlim([0,10]); ylim([0,10]);
            line([0,10],[0,10], 'parent', left_ax );
            xlabel('# of cells with non-exponential fast state distributions', 'parent', left_ax);
            ylabel('# of cells with non-exponential fast state distributions', 'parent', left_ax);
            table( chi2_hmmseg1, chi2_hmmseg2, legends )
            %legend(legends)
            rowfun( @(x,y,t) text( x+1, y, t{1} , 'parent', left_ax ), table( chi2_hmmseg1, chi2_hmmseg2, legends ) );
            set(gcf, 'position', [140,320,1350,470] );
            
            % Right plot
            
            chi2_hmmseg1_pct = arrayfun(@(x) chi2_hmmseg1(x)/N(x), [1:numel(N)] )';
            chi2_hmmseg2_pct = arrayfun(@(x) chi2_hmmseg2(x)/N(x), [1:numel(N)] )';
            arrayfun( @(x) plot( chi2_hmmseg1_pct(x), chi2_hmmseg2_pct(x), '.', 'MarkerSize', 24, 'color', colors(x,:), 'parent', right_ax ), [1:numel(chi2_hmmseg1)] );
            xlim([0,1]); ylim([0,1]);
            line([0,1],[0,1], 'parent', right_ax );
            xlabel('% of cells with non-exponential fast state distributions', 'parent', right_ax);
            ylabel('% of cells with non-exponential slow state distributions', 'parent', right_ax);
            table( chi2_hmmseg1, chi2_hmmseg2, legends )
            legend(legends);
            table( chi2_hmmseg1_pct, chi2_hmmseg2_pct, legends )
            %rowfun( @(x,y,t) text( x+1, y, t{1} , 'parent', right_ax ), table( chi2_hmmseg1_pct, chi2_hmmseg2_pct, legends ) );
            set(gcf, 'position', [140,320,1350,470] );
            
        end
        
    end
    
end

