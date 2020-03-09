myobjs = fields( signeFolders.hmmsegs );

for I = myobjs'
    thisObj = I{1};
    %thisState = sprintf('State%i',K);

    if ~isempty( signeFolders.hmmsegs.(thisObj).brownianTable )
        tmp = [ signeFolders.hmmsegs.(thisObj).brownianTable.State1;signeFolders.hmmsegs.(thisObj).brownianTable.State2];
        segs = tmp.segIdx;
        segs_histogram = table( unique(segs), histc( segs, unique(segs) ) , 'VariableNames', {'segIdx','NumSegs'} )
        segNumber = zeros( size(tmp,1), 1 );

        for i = unique(segs_histogram.NumSegs)'
            theseSegs = segs_histogram.segIdx( ismember( segs_histogram.NumSegs, i ) ); % The indices of segments 
            segNumber( find(ismember( tmp.segIdx, theseSegs ) == 1) ) = i;
        end

        signeFolders.hmmsegs.(thisObj).brownianTable.State1.tracksInSeg = segNumber([1:numel( signeFolders.hmmsegs.(thisObj).brownianTable.State1.tracksInSeg )]);
        signeFolders.hmmsegs.(thisObj).brownianTable.State2.tracksInSeg = segNumber([numel( signeFolders.hmmsegs.(thisObj).brownianTable.State1.tracksInSeg )+1:numel(segNumber)]);
    end
end

%% Set the first and last segments of each to -1 and 1 respectively. All others are zeros.
