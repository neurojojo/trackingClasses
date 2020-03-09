function mytablearray = vectorizeTableText(input_table )

    atable = input_table;

    mynumel = @(x) numel( x{1} );
    maxLength = max( table2array(rowfun( mynumel, atable )) );
    mydouble = @(x) [double(x{1}), zeros( 1,maxLength - numel(double(x{1})) )];
    mytablearray = table2array( rowfun( mydouble, atable ) );

end