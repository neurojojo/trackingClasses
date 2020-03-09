function palette_out = palette(color, varargin)

palettes.reds = [
    167 0   0
    255 0   0
    255 82  82
    255 123 123
    255 186 186]/255;
palettes.pinks = [
  150   48  76
  180   71  114
  205   90  145
  231   110 177
  255   128 206
  255   149 214
]/255;
palettes.oranges = [
    240 117 15
    244 128 32
    240 149 55
    240 161 80]/255;

palettes.blueolives = [
    58  96  110
    96  123 125
    130 142 130
    170 174 142
    224 224 224]/255;

palette.magentas = [
    195 0   118
    255 0   155
    255 103 196
    255 180 226
]/255;

palettes.greens = [
    0   98  3
    15  146 0
    48  203 0
    74  229 74
    164 251 166 ]/255;

palettes.palegreens = [
    0    0.5882    0.4333
    0.3294    0.6980    0.6627
    0.5137    0.8157    0.7882];
palettes.grays = flipud([    
    153,153,153
    119,119,119
    85,85,85
    51,51,51,
    17,17,17]/255);
palettes.tans = [
    0.5529    0.3333    0.1412
    0.7765    0.5255    0.2588
    0.8784    0.6745    0.4118
    0.9451    0.7608    0.4902
    1.0000    0.8588    0.6745
    ];
palettes.blues = [
    0   5   159
    44  44  255
    78  145 253
    186 194 255
    ]/255;
palettes.paleblues = [
    0.1314    0.3902    0.8471
    0.3922    0.6314    0.9569
    0.7490    0.8392    0.9647
    ];

if isfield(palettes,color)
    palette_out = palettes.(color);
else if isfield(palette,color)
    palette_out = palette.(color);
end
end

if nargin>1
   Ncolors = size( palette_out, 1 );
   figure;
   rowfun( @(x,c) patch( [0,1,1,0,0],[x,x,x+1,x+1,x],c,'edgecolor','none' ), table( [1:Ncolors]', palette_out ) );
   camroll(-90);
   set(gca,'XColor','none','YColor','none');
end
    
end

