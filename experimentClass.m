classdef experimentClass
    
    properties
        Keys;
        Genotype;
        Drug;
        Lifetimes;
        State1_Total;
        State2_Total;
    end
    
    properties(GetAccess='private',Constant)
        datadir = 'C:/MATLAB/signeData/';
        datatable = 'C:/MATLAB/signeData/metadata/signeMATLABtableExperiments.mat';
        savedir = 'C:/MATLAB/signeData/savefiles/';
        dataname = 'signeMATLABtableExperiments';
    end
    
    methods
        
        function obj = experimentClass(varargin)
            
            % Load the database
            datatable_contents = load( obj.datatable, obj.dataname);
            datatable_contents = datatable_contents.(obj.dataname);
            
            % Check whether to load one experiment or all experiments
            if nargin==0
                
                Nexps = size( datatable_contents, 1);
                answer = input( sprintf('No experiment ID specified -- all %i experiments in the database will be loaded\nType y to continue: ',Nexps), 's' );
                
                if strcmp(answer,'y')
                    % Load every experiment in the datatable
                    for i = 1:Nexps
                        
                        expNumber = i;
                        tmp_Genotype = datatable_contents( expNumber, :).Genotype;
                        tmp_Drug = datatable_contents( expNumber, :).Drug;
                        
                        try
                            myobj=loadData( obj, datatable_contents, expNumber );
                            save(myobj);
                            fprintf('Successfully loaded (%i) %s %s\n\n', expNumber, tmp_Genotype, tmp_Drug)
                            fprintf('---------------------------------------------------------------------------\n');
                        catch
                            msg = lastwarn;
                            fprintf('Could not load %s %s\n', tmp_Genotype, tmp_Drug)
                            fprintf('---------------------------------------------------------------------------\n');
                            %fprintf('Error given: %s\n', msg);
                        end
                    end
                else
                    return
                end
                
            else
                
                expNumber = varargin{1};
                obj = loadData( obj, datatable_contents, expNumber );
                
            end
            
        end
        
        function obj = loadData(obj, datatable_contents, expNumber)
            
            obj.Keys = datatable_contents( expNumber, :).Keys;
            obj.Genotype = datatable_contents( expNumber, :).Genotype;
            obj.Drug = datatable_contents( expNumber, :).Drug;
            
            Lifetimes = [];
            
            for i = 1:numel(obj.Keys{1})
                try
                    brownian_obj = load( fullfile( obj.datadir, 'brownian', sprintf('brownian_%s.mat', obj.Keys{1}{i} ) ), 'obj' );
                    tmp_lt_1 = lifetimes(brownian_obj.obj,'State1');
                    tmp_lt_2 = lifetimes(brownian_obj.obj,'State2');
                    Lifetimes = [Lifetimes; i*ones(numel(tmp_lt_1),1), 1*ones(numel(tmp_lt_1),1), tmp_lt_1];
                    Lifetimes = [Lifetimes; i*ones(numel(tmp_lt_2),1), 2*ones(numel(tmp_lt_2),1), tmp_lt_2];
                    
                    fprintf('Loaded KEY %s (%s %s) for Experiment %i \n', obj.Keys{1}{i}, obj.Genotype, obj.Drug, expNumber);
                catch
                    msg = lasterror;
                    if strcmp(msg.identifier,'MATLAB:load:couldNotReadFile')
                       fprintf('-------Beginning file read error----------\n\n');
                        fprintf('Error reading %s. It does not exist. Continuing to load.\n', obj.Keys{1}{i}); 
                       % Investigate the error
                       f = load(sprintf('segs_%s.mat',obj.Keys{1}{i}));
                       segsTable = f.obj.segsTable;
                       % Check the number of segments
                       diffusingSegs = numel( find( not( segsTable.nan) & ...% (1) HAVE NO NANS and 
                                                segsTable.segType==2));  % (2) BE TYPE 2
                       fprintf('Number of segments from segsTable: %i ',diffusingSegs);
                       
                       hmm_output_loc = f.obj.metadata.fileStruct.address_analysis_output;
                       if exist(hmm_output_loc)>0
                           myload = load( hmm_output_loc ); N_ML_segs = size( myload.results.ML_states,2 );
                       else
                          fprintf('\nHMM output file %s does not exist\n', hmm_output_loc);
                       end
                       
                       fprintf('Number of segments in HMM output: %i\n',N_ML_segs);
                       fprintf('-------End of this error----------\n\n');
                    end
                end
            end
            
            obj.Lifetimes = array2table( Lifetimes, 'VariableNames', {'Cell','State','Lifetime'} );
            obj.State1_Total = sum( obj.Lifetimes( obj.Lifetimes.State == 1 , : ).Lifetime );
            obj.State2_Total = sum( obj.Lifetimes( obj.Lifetimes.State == 2 , : ).Lifetime );
        
        end
        
        function save(obj)
            cleanuptext = @(x) cell2mat(regexprep( cellstr(x), '[\.|\s]', '_' ));
            filename = fullfile( obj.savedir, sprintf( '%s_%s.mat', ...
                cleanuptext(obj.Genotype),...
                cleanuptext(obj.Drug)));
            save( filename, 'obj' );
        end
        
    end
    
end