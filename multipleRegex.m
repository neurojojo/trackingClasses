function [hits,figname] = multipleRegex( cellarray, varargin )

    hits = [1:numel(cellarray)]'; % All entries are hits before query
    figname = '';
    if nargin==1
        figname='all';
        return
    else
        try; queries = varargin{1}{1}; catch; queries = varargin{1}; end
        for i = 1:numel( queries )

            figname = [figname, ' ', queries{i}];
            
            if regexpi( queries{i}, 'not')
                removeflag = regexpi(queries{i},'(?<=not\s).*','match');
                query = sprintf('^((?!%s).)*$', removeflag{1}); myre = @(x) numel( regexpi(x,query) ); 
            else
                query = sprintf('%s',queries{i}); myre = @(x) numel( regexpi(x,query) ); 
            end

            hits = intersect( hits, find( cellfun( myre, cellarray ) > 0 ) );

        end

        figname = regexprep( figname, '\s', '_' );
    end
    
end

