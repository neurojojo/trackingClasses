%% Introduction
% Assigns common names to colors, call up this script within your script to utilise them further
% colors from:
% https://digitalsynopsis.com/design/color-thesaurus-correct-names-of-shades/
% flags to display the plots
plotsflag=1
% if enabled, pie charts showing the colours will be displayed
subplotsflag=1
% if enabled, the pie charts will be displayed as a plot with 12 subplots opposed to 5 seperate plots
if subplotsflag==1
    sizeoffont=7;
    % sets font size of legend for subplots
else
    sizeoffont=10;
    % sets font size of legend for seperate plots
end

%% Shades

%% Plots

if plotsflag==1
    % data for plots
    data=ones(20,1);
    pielabels={' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '};
    % white shade wheel
    figure(1);
    if subplotsflag==1
    subplot(3,4,1);
    end
    pie(data,pielabels);
    colormap(gca,[white;pearl;alabaster;snow;ivory;cream;eggshell;cotton;chiffon;salt;lace;coconut;linen;bone;daisy;powder;frost;porcelain;parchment;rice]);
    labels={'white';'pearl';'alabaster';'snow';'ivory';'cream';'eggshell';'cotton';'chiffon';'salt';'lace';'coconut';'linen';'bone';'daisy';'powder';'frost';'porcelain';'parchment';'rice'};
    legend(labels,'Location','eastoutside','orientation','vertical','FontSize',sizeoffont);
    title('white shade wheel');
    % tan shade wheel
    if subplotsflag==0
    figure(2);
    end
    if subplotsflag==1
    subplot(3,4,2);
    end
    pie(data,pielabels);
    colormap(gca,[tan;beige;macaroon;hazelwood;granola;fawn;oat;eggnog;fawn;sugarcookie;sand;sepia;latte;oyster;biscotti;parmesean;hazelnut;sandcastle;buttermilk;sanddollar;shortbread]);
    labels={'tan';'beige';'macaroon';'hazelwood';'granola';'fawn';'oat';'eggnog';'fawn';'sugarcookie';'sand';'sepia';'latte';'oyster';'biscotti';'parmesean';'hazelnut';'sandcastle';'buttermilk';'sanddollar';'shortbread'};
    legend(labels,'Location','eastoutside','orientation','vertical','FontSize',sizeoffont);
    title('tan shade wheel');
    % yellow shade wheel
    if subplotsflag==0
    figure(3);
    end
    if subplotsflag==1
    subplot(3,4,3);
    end
    pie(data,pielabels);
    colormap(gca,[yellow;canary;gold;daffodil;flaxen;butter;lemon;mustard;corn;medallion;dandelion;yellowfire;bumblebee;banana;butterscotch;dijon;honey;blonde;pineapple;tuscansun]);
    labels={'yellow';'canary';'gold';'daffodil';'flaxen';'butter';'lemon';'mustard';'corn';'medallion';'dandelion';'yellowfire';'bumblebee';'banana';'butterscotch';'dijon';'honey';'blonde';'pineapple';'tuscansun'};
    legend(labels,'Location','eastoutside','orientation','vertical','FontSize',sizeoffont);
    title('yellow shade wheel');
    % orange shade wheel
    if subplotsflag==0
    figure(4);
    end
    if subplotsflag==1
    subplot(3,4,4);
    end
    pie(data,pielabels);
    colormap(gca,[orange;tangerine;merigold;cider;rust;ginger;tiger;redfire;bronze;cantaloupe;apricot;clay;honey;carrot;squash;spice;marmalade;amber;sandstone;yam]);
    labels={'orange';'tangerine';'merigold';'cider';'rust';'ginger';'tiger';'redfire';'bronze';'cantaloupe';'apricot';'clay';'honey';'carrot';'squash';'spice';'marmalade';'amber';'sandstone';'yam'};
    legend(labels,'Location','eastoutside','orientation','vertical','FontSize',sizeoffont);
    title('orange shade wheel');
    % red shade wheel
    if subplotsflag==0
    figure(5);
    end
    if subplotsflag==1
    subplot(3,4,5);
    end
    pie(data,pielabels);
    colormap(gca,[red;cherry;rosered;jam;merlot;garnet;crimson;ruby;scarlet;winered;brick;apple;mahogany;blood;sangriared;berryred;currant;blushred;candy;lipstick]);
    labels={'red';'cherry';'rosered';'jam';'merlot';'garnet';'crimson';'ruby';'scarlet';'winered';'brick';'apple';'mahogany';'blood';'sangriared';'berryred';'currant';'blushred';'candy';'lipstick'};
    legend(labels,'Location','eastoutside','orientation','vertical','FontSize',sizeoffont);
    title('red shade wheel');
    % pink shade wheel
    if subplotsflag==0
    figure(6);
    end
    if subplotsflag==1
    subplot(3,4,6);
    end
    pie(data,pielabels);
    colormap(gca,[pink;rosepink;fuscia;punch;blushpink;watermelon;flamingo;rogue;salmon;coral;peach;strawberry;rosewood;lemonade;taffy;bubblegum;balletslipper;crepe;magentapink;hotpink]);
    labels={'pink';'rosepink';'fuscia';'punch';'blushpink';'watermelon';'flamingo';'rogue';'salmon';'coral';'peach';'strawberry';'rosewood';'lemonade';'taffy';'bubblegum';'balletslipper';'crepe';'magentapink';'hotpink'};
    legend(labels,'Location','eastoutside','orientation','vertical','FontSize',sizeoffont);
    title('pink shade wheel');
    % purple shade wheel
    if subplotsflag==0
    figure(7);
    end
    if subplotsflag==1
    subplot(3,4,7);
    end
    pie(data,pielabels);
    colormap(gca,[purple;mauve;violet;boysenberry;lavender;plum;magentapurple;lilac;grape;periwinkle;sangriapurple;eggplant;jam;iris;heather;amethlyst;rasin;orchid;mulberry;winepurple]);
    labels={'purple';'mauve';'violet';'boysenberry';'lavender';'plum';'magentapurple';'lilac';'grape';'periwinkle';'sangriapurple';'eggplant';'jam';'iris';'heather';'amethlyst';'rasin';'orchid';'mulberry';'winepurple'};
    legend(labels,'Location','eastoutside','orientation','vertical','FontSize',sizeoffont);
    title('purple shade wheel');
    % blue shade wheel
    if subplotsflag==0
    figure(8);
    end
    if subplotsflag==1
    subplot(3,4,8);
    end
    pie(data,pielabels);
    colormap(gca,[blue;slate;sky;navy;indigo;cobalt;teal;ocean;peacock;azure;cerulean;lapis;spruce;stone;aegean;blueberry;denim;admiral;sapphire;artic]);
    labels={'blue';'slate';'sky';'navy';'indigo';'cobalt';'teal';'ocean';'peacock';'azure';'cerulean';'lapis';'spruce';'stone';'aegean';'blueberry';'denim';'admiral';'sapphire';'artic'};
    legend(labels,'Location','eastoutside','orientation','vertical','FontSize',sizeoffont);
    title('blue shade wheel');    
    % green shade wheel
    if subplotsflag==0
    figure(9);
    end
    if subplotsflag==1
    subplot(3,4,9);
    end
    pie(data,pielabels);
    colormap(gca,[green;chartreuse;juniper;sage;lime;fern;olive;emerald;pear;moss;shamrock;seafoam;pine;parakeet;mint;seaweed;pickle;pistachio;basil;crocodile]);
    labels={'green';'chartreuse';'juniper';'sage';'lime';'fern';'olive';'emerald';'pear';'moss';'shamrock';'seafoam';'pine';'parakeet';'mint';'seaweed';'pickle';'pistachio';'basil';'crocodile'};
    legend(labels,'Location','eastoutside','orientation','vertical','FontSize',sizeoffont);
    title('green shade wheel'); 
    % brown shade wheel
    if subplotsflag==0
    figure(10);
    end
    if subplotsflag==1
    subplot(3,4,10);
    end
    pie(data,pielabels);
    colormap(gca,[brown;coffee;mocha;peanut;carob;hickory;wood;pecan;walnut;caramel;gingerbread;syrup;chocolate;tortilla;umber;tawny;brunette;cinnamon;penny;cedar]);
    labels={'brown';'coffee';'mocha';'peanut';'carob';'hickory';'wood';'pecan';'walnut';'caramel';'gingerbread';'syrup';'chocolate';'tortilla';'umber';'tawny';'brunette';'cinnamon';'penny';'cedar'};
    legend(labels,'Location','eastoutside','orientation','vertical','FontSize',sizeoffont);
    title('brown shade wheel'); 
    % grey shade wheel
    if subplotsflag==0
    figure(11);
    end
    if subplotsflag==1
    subplot(3,4,11);
    end
    pie(data,pielabels);
    colormap(gca,[grey;shadow;graphite;iron;pewter;cloud;silver;smoke;slate;anchor;ash;porpoise;dove;fog;flint;charcoal;pebble;lead;coin;fossil]);
    labels={'grey';'shadow';'graphite';'iron';'pewter';'cloud';'silver';'smoke';'slate';'anchor';'ash';'porpoise';'dove';'fog';'flint';'charcoal';'pebble';'lead';'coin';'fossil'};
    legend(labels,'Location','eastoutside','orientation','vertical','FontSize',sizeoffont);
    title('grey shade wheel');  
    % black shade wheel
    if subplotsflag==0
    figure(12);
    end
    if subplotsflag==1
    subplot(3,4,12);
    end
    pie(data,pielabels);
    colormap(gca,[black;ebony;crow;charcoal;midnight;ink;raven;oil;grease;onyx;pitch;soot;sable;jetblack;coal;metal;obsidian;jade;spider;leather]);
    labels={'black';'ebony';'crow';'charcoal';'midnight';'ink';'raven';'oil';'grease';'onyx';'pitch';'soot';'sable';'jetblack';'coal';'metal';'obsidian';'jade';'spider';'leather'};
    legend(labels,'Location','eastoutside','orientation','vertical','FontSize',sizeoffont);
    title('black shade wheel'); 
end
