%% PARAMETERS FOR FIGURES 1-5 

%% Figure 1
close all;
% Use two brackets to get this to concatenate
plot_options.query = {{'Gi1 D2 ins4a','not quinpirole','not sulpiride'};...
         {'Gi1 D2 ins4a', 'quinpirole'};...
         {'Gi1 D2 ins4a','Sulpiride'}};
plot_options.colors = {'blues';'greens';'tans'};
plot_options.sorting = [1,3,2];
plot_options.remove_ends = 1; 
plot_options.only1length = 0;
plot_options.splitbarstitle_top = 'Occupancy table (for all segments)';
plot_options.splitbarstitle_bottom = 'Occupancy table (for segments with ends removed)';
[plot_options.ygain,plot_options.y0,plot_options.x0,plot_options.w]=deal(25,65,50,5);
plot_options.filename = 'C:\\laptop_database\\signe_figures_jan14\\crosses_bars_ins4a_endsremoved.svg';
plot_options.x0 = 70;
plot_rc_obj_wrapper( rc_obj, plot_options );

%% Figure 2 (all tracks of length 1)

% Maybe do this for ONLY the ends
% Also add a bar graph for the occupancy of the crosses shown
close all;
% Same as above except with only1length segments
plot_options.remove_ends = 0; 
plot_options.only1length = 1;
plot_options.sorting = [1,3,2];
plot_options.splitbarstitle_top = 'Occupancy table (for all segments)';
plot_options.splitbarstitle_bottom = 'Occupancy table (for one length segments)';
plot_options.filename = 'C:\\laptop_database\\signe_figures_jan14\\crosses_bars_ins4a_only1length.svg';
plot_options.x0 = 70;

plot_rc_obj_wrapper( rc_obj, plot_options );

%% Figure 2 (ends removed)
close all;

plot_options.remove_ends = 1; 
plot_options.only1length = 0;
plot_options.colors = {'blues';'reds'}; 
plot_options.query = {{'2400 ng'};...
        {'Gi','not D2','not Lat'}};
plot_options.splitbarstitle_top = 'Occupancy table (for all segments)';
plot_options.splitbarstitle_bottom = 'Occupancy table (for segments with ends removed)';
plot_options.filename = 'C:\\laptop_database\\signe_figures_jan14\\crosses_Gi_endsremoved.svg';
plot_options.x0 = 70;

plot_rc_obj_wrapper( rc_obj, plot_options );

%% Figure 2 (only1length)
close all;

plot_options.remove_ends = 0; 
plot_options.only1length = 1;
plot_options.sorting = [];
plot_options.colors = {'blues';'reds'}; 
plot_options.query = {{'2400 ng'};...
        {'Gi','not D2','not Lat'}};
plot_options.splitbarstitle_top = 'Occupancy table (for all segments)';
plot_options.splitbarstitle_bottom = 'Occupancy table (for segments of only1length)';
plot_options.filename = 'C:\\laptop_database\\signe_figures_jan14\\crosses_Gi_only1length.svg';
plot_options.x0 = 70;

plot_rc_obj_wrapper( rc_obj, plot_options );


%% Figure 3

close all;
plot_options.remove_ends = 0; 
plot_options.only1length = 1;
plot_options.sorting = [];
plot_options.splitbarstitle_top = 'Occupancy table (for all segments)';
plot_options.splitbarstitle_bottom = 'Occupancy table (for segments of only1length)';
plot_options.colors = {'blues';'reds'}; 
plot_options.query = {{'D2','1200 ng', 'no treat', 'not PTXR'};
    {'PTXR','1200 ng', 'no treat'}};
plot_options.filename = 'C:\\laptop_database\\signe_figures_jan14\\crosses_D2_only1length.svg';

plot_rc_obj_wrapper( rc_obj, plot_options );

%% Figure 3

close all;
plot_options.remove_ends = 1; 
plot_options.only1length = 0;
plot_options.sorting = [];
plot_options.splitbarstitle_top = 'Occupancy table (for all segments)';
plot_options.splitbarstitle_bottom = 'Occupancy table (for segments with ends removed)';
plot_options.colors = {'blues';'reds'}; 
plot_options.query = {{'D2','1200 ng', 'no treat', 'not PTXR'};
    {'PTXR','1200 ng', 'no treat'}};
plot_options.filename = 'C:\\laptop_database\\signe_figures_jan14\\crosses_D2_endsremoved.svg';

plot_rc_obj_wrapper( rc_obj, plot_options );

%% Figure 4 (ends removed)

close all;
plot_options.remove_ends = 1; 
plot_options.only1length = 0;
plot_options.sorting = [];
plot_options.splitbarstitle_top = 'Occupancy table (for all segments)';
plot_options.splitbarstitle_bottom = 'Occupancy table (for segments with ends removed)';
plot_options.query = {{'Gi','D2','not ins4a', 'no treat'};...
         {'Myr'};...
         {'Gi1 D2 Quinpirole'};...
         {'Gi1 D2 PTXR Quinpirole'}};
plot_options.colors = {'blues';'reds';'greens';'grays'}
plot_options.filename = 'C:\\laptop_database\\signe_figures_jan14\\crosses_noins4a_myr_endsremoved.svg';
    
plot_rc_obj_wrapper( rc_obj, plot_options );

%% Figure 4 (only1length)

close all;
plot_options.remove_ends = 0; 
plot_options.only1length = 1;
plot_options.sorting = [];
plot_options.splitbarstitle_top = 'Occupancy table (for all segments)';
plot_options.splitbarstitle_bottom = 'Occupancy table (for segments with only1length)';
plot_options.query = {{'Gi','D2','not ins4a', 'no treat'};...
         {'Myr'};...
         {'Gi1 D2 Quinpirole'};...
         {'Gi1 D2 PTXR Quinpirole'}};
plot_options.colors = {'blues';'reds';'greens';'grays'}
plot_options.filename = 'C:\\laptop_database\\signe_figures_jan14\\crosses_noins4a_myr_only1length.svg';
    
plot_rc_obj_wrapper( rc_obj, plot_options );


%% Figure 5 (only1length)

close all; 
plot_options.remove_ends = 0; 
plot_options.only1length = 1;
plot_options.sorting = [];
plot_options.splitbarstitle_top = 'Occupancy table (for all segments)';
plot_options.splitbarstitle_bottom = 'Occupancy table (for segments with only1length)';

plot_options.colors = {'blues';'greens';'tans';'reds'}
plot_options.query = { {'Gi','not D2','not ins4a', 'no treat'};...
          {'Gi','not D2','not ins4a', 'quinpirole'};...
          {'Gi','D2','2400'};...
          {'Myr'} };
plot_options.filename = 'C:\\laptop_database\\signe_figures_jan14\\crosses_noins4a_PTXR_myr_only1length.svg';

plot_rc_obj_wrapper( rc_obj, plot_options );

%% Figure 5 (ends removed)

close all; 
plot_options.remove_ends = 1; 
plot_options.only1length = 0;
plot_options.sorting = [];
plot_options.splitbarstitle_top = 'Occupancy table (for all segments)';
plot_options.splitbarstitle_bottom = 'Occupancy table (for segments with only1length)';

plot_options.colors = {'blues';'greens';'tans';'reds'}
plot_options.query = { {'Gi','not D2','not ins4a', 'no treat'};...
          {'Gi','not D2','not ins4a', 'quinpirole'};...
          {'Gi','D2','2400'};...
          {'Myr'} };
plot_options.filename = 'C:\\laptop_database\\signe_figures_jan14\\crosses_noins4a_PTXR_myr_endsremoved.svg';

plot_rc_obj_wrapper( rc_obj, plot_options );
%% Figure 6

close all; 
plot_options.remove_ends = 0; 
plot_options.only1length = 1;
plot_options.sorting = [];
plot_options.splitbarstitle_top = 'Occupancy table (for all segments)';
plot_options.splitbarstitle_bottom = 'Occupancy table (for segments with only1length)';

plot_options.colors = {'grays';'tans'}
plot_options.query = { {'Gi','D2','2400'};...
          {'ins4a','1200'} };
plot_options.filename = 'C:\\laptop_database\\signe_figures_jan14\\crosses_Gi_ins4a_only1length.svg';

plot_rc_obj_wrapper( rc_obj, plot_options );

%% Figure 6 (ends removed)


figure;
plot_options.remove_ends = 1; 
plot_options.only1length = 0;
plot_options.sorting = [];
plot_options.splitbarstitle_top = 'Occupancy table (for all segments)';
plot_options.splitbarstitle_bottom = 'Occupancy table (for segments with ends removed)';

plot_options.colors = {'grays';'tans'}
plot_options.query = { {'Gi','D2','2400'};...
          {'ins4a','1200'} };
plot_options.filename = 'C:\\laptop_database\\signe_figures_jan14\\crosses_Gi_ins4a_endsremoved.svg';

plot_rc_obj_wrapper( rc_obj, plot_options );
