%% Patching OLD signeFolders 


signeFolders.computeRelativeSegIdx();
signeFolders.collectParameters(); % Failed 1/22/2020

%%

% Have to add segType to all of the hmmsegs brownianTables

for i = fields(signeFolders.hmmsegs)'
    
   if isfield( signeFolders.hmmsegs.(i{1}).brownianTable, 'State1' )
       
       try
       tmp1 = signeFolders.hmmsegs.(i{1}).brownianTable.State1;
       tmp1.segType = repmat( 101, size(tmp1,1), 1 );
       signeFolders.hmmsegs.(i{1}).brownianTable.State1 = tmp1;
       
       tmp2 = signeFolders.hmmsegs.(i{1}).brownianTable.State2;
       tmp2.segType = repmat( 102, size(tmp2,1), 1 );
       signeFolders.hmmsegs.(i{1}).brownianTable.State2 = tmp2;
       catch
        i
       end
       
   end
   
end

%%


rc_obj.getConsolidatedLifetimes( signeFolders );
rc_obj.computeSegInfo();
rc_obj.makeDiffusionTable( signeFolders );
rc_obj.consolidateSuperclusterLifetimes( signeFolders );

rc_obj.getSequences( signeFolders );