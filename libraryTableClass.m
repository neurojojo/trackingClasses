classdef libraryTableClass
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        sequenceLibrary
        
    end
    
    methods

        %% Make a table for parsing each track into all seg types
        function obj = libraryTableClass( findFoldersClass )
            
            sequenceLibrary = struct();
            mytable = rowfun( @(x,y) obj.translateSegs(x,y), table( struct2cell( findFoldersClass.segs ), struct2cell( findFoldersClass.hmmsegs ) ), 'ErrorHandler', @(x,y) findFoldersClass.doNothing );

            for i = 1:size(mytable,1)
                   if ~isfield( accumulator, out{i} )
                       accumulator.( sprintf('%s',out{i}{1}) ) = 1;
                   else
                       accumulator.( sprintf('%s',out{i}{1}) ) = accumulator.( sprintf('%s',out{i}{1}) )+1;
                   end
            end
            
            sequenceLibrary.(objectnames{1}) = table( fields( accumulator ), struct2array(accumulator)', 'VariableNames', {'States','Count'} );
            sequenceLibrary.(objectnames{1}) = table( 'Size', [0,2], 'VariableNames', {'States','Count'} );
            
        end
        
        function mytables = translateSegs(obj,segs,hmmsegs)
            
            %hmmsegs{1}.brownianTable.State1.segType = repmat(1, size(
            tmp = sortrows( outerjoin( segs{1}.segsTable(:,[1,2,5]),...
                            [hmmsegs{1}.brownianTable.State1(:,[1,2,4,8]);hmmsegs{1}.brownianTable.State2(:,[1,2,4,8])],...
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
            tmp( tmp.segType_combined==-2,:).segType_letters = repmat({'G'}, sum( tmp.segType_combined==-2 ), 1);
            tmp( tmp.segType_combined==-1,:).segType_letters = repmat({'N'}, sum( tmp.segType_combined==-1 ), 1);
            tmp( tmp.segType_combined==0,:).segType_letters = repmat({'I'}, sum(tmp.segType_combined==0), 1 );
            tmp( tmp.segType_combined==1,:).segType_letters = repmat({'C'}, sum(tmp.segType_combined==1), 1 );
            tmp( tmp.segType_combined==101,:).segType_letters = repmat({'F'}, sum(tmp.segType_combined==101), 1 );
            tmp( tmp.segType_combined==102,:).segType_letters = repmat({'S'}, sum(tmp.segType_combined==102), 1 );
            tmp( tmp.segType_combined==3,:).segType_letters = repmat({'V'}, sum(tmp.segType_combined==3), 1 );

            mytables = { arrayfun( @(x) cellstr(cell2mat(tmp( tmp.trackIdx_left == x,:).segType_letters)'), unique( tmp.trackIdx_left ), 'UniformOutput', false ) };
            fprintf('Parsed %i\n', segs{1}.metadata.obj_idx );
            
        end
        
    end
    
end

