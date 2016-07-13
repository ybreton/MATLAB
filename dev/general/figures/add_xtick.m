function th = add_xtick(x,label,varargin)
%
%
%
%
y = zeros(size(x));
fh = gcf;
ah = gca;
Interpreter = 'tex';
Rotation = 0;
Color = [0 0 0];
FontSize = 10;
FontAngle = 'normal';
FontWeight = 'normal';
FontName = 'Helvetica';
FontUnits = 'points';
HorizontalAlignment = 'center';
VerticalAlignment = 'top';
process_varargin(varargin);

if size(Color,1)<numel(x)
    Color = repmat(Color,[numel(x) 1]);
end
if numel(y)<numel(x)
    y = repmat(y,[numel(x) 1]);
end

th = nan(size(x));
for iTick=1:numel(x)
    if ~isnan(x)
        th(iTick) = text(x(iTick),y(iTick),label(iTick),...
        'interpreter',Interpreter,...
        'rotation',Rotation,...
        'color',Color(iTick,:),...
        'fontsize',FontSize,...
        'fontangle',FontAngle,...
        'fontweight',FontWeight,...
        'fontname',FontName,...
        'fontunits',FontUnits);
        set(th(iTick),'HorizontalAlignment',HorizontalAlignment)
        set(th(iTick),'VerticalAlignment',VerticalAlignment)
    end
end