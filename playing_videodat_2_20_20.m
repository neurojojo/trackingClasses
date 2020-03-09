t = signeFolders.subfolderTable.Name;

%%

hits = cellfun( @(x) regexp(x,'170622.*03Ch1'), t, 'UniformOutput', false );
hits = find(cellfun( @(x) numel(x), hits )==1);

%% Data is 181

track1 = [signeFolders.tracks.obj_181.tracksTable(1,:).x{1}; signeFolders.tracks.obj_181.tracksTable(1,:).y{1}]';

%% Read in images

mydir = 'C:\u-track\#03Ch1\ImageData';
myfiles = dir(mydir);

for i = 3:numel(myfiles); 
   myimages(:,:,i-2) = imread(  fullfile(myfiles(i).folder,myfiles(i).name) );
end

%%

trackNum=4;
trackStart=signeFolders.tracks.obj_181.tracksTable(trackNum,:).trackStart;
track1 = [signeFolders.tracks.obj_181.tracksTable(trackNum,:).x{1}',signeFolders.tracks.obj_181.tracksTable(trackNum,:).y{1}'];
trackLength=size( track1, 1 );

extraFrames = 100;
theimages = [];
%v3 = VideoWriter('tmp2','Grayscale AVI');
%open(v3);

for i = trackStart:trackStart+trackLength+extraFrames
    if lt(i,trackLength)
        if isnan(track1(i,1)); theimages(:,:,i) = theimages(:,:,end); fprintf('NaN at %i\n',i); continue; end
        theimages(:,:,i-trackStart+1) = uint8( myimages(fix([track1(i,2)-6:track1(i,2)+5]),fix([track1(i,1)-6:track1(i,1)+5]),i ) );
    else
        theimages(:,:,i-trackStart+1) = uint8( myimages(fix([track1(end,2)-6:track1(end,2)+5]),fix([track1(end,1)-6:track1(end,1)+5]),i ) );
    end
end

figure('color','w');
ax1 = axes('Position',[0.1 0.1 .6 .6],'Box','on');
ax2 = axes('Position',[.5 .5 .3 .3],'Box','off','XTick',[],'YTick',[],'XColor','w','YColor','w');

[w,h] = deal( size(theimages,1),size(theimages,2) );
zscore2 = @(x) (x-mean2(x))./std2(x);

makeVideo = 0;

if makeVideo; myVideo = VideoWriter(sprintf('trajectory_%i',trackNum),'MPEG-4'); open(myVideo); end

for k = 1:(trackLength+extraFrames)
   ff=surf( theimages(:,:,k), theimages(:,:,k), 'CDataMapping', 'direct', 'parent', ax1 );
   [a,b] = max( theimages(:,:,k), [], 'all', 'linear' );
   [x,y] = ind2sub( [w,h] , b );
   line([y,y],[x,x],[0,300],'color','r', 'parent', ax1)
   line([w/2,w/2],[h/2,h/2],[100,300],'color','k', 'parent', ax1)
   line([w/2,y],[h/2,x],[300,300],'color','k', 'parent', ax1);
   imshow( zscore2(theimages(:,:,k)), [0,5], 'parent',ax2);
   images.roi.Circle(gca,'Center',[7 7],'Radius',2,'Parent',ax2);
   set(gca,'ZLim',[0,300]);
   if k<trackLength; text(1,-2,sprintf('Frame %i',k),'Color','k'); else; text(1,-2,sprintf('Frame %i',k),'Color','r'); end
   pause(0.01);
   if makeVideo; thisframe = getframe(gcf); writeVideo(myVideo,thisframe); end
end

if makeVideo; close(myVideo); end