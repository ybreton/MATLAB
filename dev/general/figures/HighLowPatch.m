function h = HighLowPatch(X,H,L,varargin)
%
%
%
%

X = X(:);
H = H(:);
L = L(:);
FaceColor = [0.8 0.8 0.8];
FaceAlpha = 0.3;
LineStyle = '-';
LineWidth = 0.5;
ah = gca;
fh = gcf;
process_varargin(varargin);
EdgeColor = FaceColor;
process_varargin(varargin);
set(0,'CurrentFigure',fh);
set(fh,'CurrentAxes',ah);
assert(length(H)==length(L)&&length(X)==length(H),'Length of high, low, and X must all be equal.')

[X,idSort] = sort(X);
H = H(idSort);
L = L(idSort);


idnan = isnan(X)|isnan(L)|isnan(H);
X(idnan) = [];
H(idnan) = [];
L(idnan) = [];
n = length(X);
if any(H<L)
    for iPt = 1 : n
        if H(iPt)<L(iPt)
            Lo = H(iPt);
            Hi = L(iPt);
            H(iPt) = Hi;
            L(iPt) = Lo;
        end
    end
end

assert(all(diff(X))>0,'X values must be unique.')

patchX = [X' (X(end:-1:1))'];
patchY = [H' (L(end:-1:1))'];
hold on
ph(1) = patch(patchX,patchY,FaceColor,'FaceAlpha',FaceAlpha,'EdgeColor','none');
if isempty(regexpi(LineStyle,'none'))
    if ischar(EdgeColor)
        if isempty(regexpi(EdgeColor,'none'))
            ph(2) = plot(X,H,LineStyle,'Color',EdgeColor,'LineWidth',LineWidth);
            ph(3) = plot(X,L,LineStyle,'Color',EdgeColor,'LineWidth',LineWidth);
        end
    else
        ph(2) = plot(X,H,LineStyle,'Color',EdgeColor,'LineWidth',LineWidth);
        ph(3) = plot(X,L,LineStyle,'Color',EdgeColor,'LineWidth',LineWidth);
    end
else
    ph(2:3) = nan;
end
if nargout>0
    h = ph;
end

hist = com.mathworks.mlservices.MLCommandHistoryServices.getSessionHistory;
last = char(hist(end));
History = get(ah,'UserData');
History{end+1} = last;
set(ah,'UserData',History);
