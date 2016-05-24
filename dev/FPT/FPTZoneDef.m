function FPTZoneDef(varargin)
%
%
%
%

fd = pwd;
fn = FindFiles('*-HEADxy.mat');
id = false(length(fn),1);
for iF=1:length(fn)
    fd0 = fileparts(fn{iF});
    id(iF) = strncmpi(fd,fd0,length(fd));
end
fn = fn(id);
process_varargin(varargin);

theta = linspace(-pi,pi,500);
SoM_x = nan;
SoM_y = nan;
CP_x = nan;
CP_y = nan;
LF_x = nan;
LF_y = nan;
RF_x = nan;
RF_y = nan;
for iF=1:length(fn);
    fd = fileparts(fn{iF});
    idDelim = regexpi(fd,'\');
    SSN = fd(max(idDelim)+1:end);
    disp(fd);
    pushdir(fd);
    load(fn{iF});
    
    answer = 'N';
    if ~isnan(SoM_x)
        colormap bone
        imagesc(Head.BLframe)
        hold on
        plot(Head.x.data,Head.y.data,'k.','markersize',1)
        plot(SoM_x+75*cos(theta),SoM_y+75*sin(theta),'g-')
        plot(CP_x+75*cos(theta),CP_y+75*sin(theta),'c-')
        plot(LF_x+75*cos(theta),LF_y+75*sin(theta),'r-')
        plot(RF_x+75*cos(theta),RF_y+75*sin(theta),'r-')
        hold off
        axis([0 720 0 480])
        axis ij
        answer = '';
        while ~strncmpi(answer,'Y',1)&&~strncmpi(answer,'N',1)
            answer = input('Use last? (Yes/[N]o): ','s');
            if isempty(answer)
                answer = 'N';
            end
        end
    end
        
    if strncmpi(answer,'N',1)
        disp('Start of maze.')
        clf
        colormap bone
        hold on
        if length(unique(Head.BLframe(:)))>10
            imagesc(Head.BLframe)
        end
        plot(Head.x.data,Head.y.data,'k.','markersize',1)
        axis([0 720 0 480])
        axis ij
        title('SoM')
        b = 3;
        while b~=1
            [x,y,b]=ginput(1);
            clf
            colormap bone
            hold on
            if length(unique(Head.BLframe(:)))>10
                imagesc(Head.BLframe)
            end
            plot(Head.x.data,Head.y.data,'k.','markersize',1)
            title('SoM')
            plot(x,y,'bo')
            plot(x+75*cos(theta),y+75*sin(theta),'b-')
            axis([0 720 0 480])
            axis ij
        end
        SoM_x = x;
        SoM_y = y;

        disp('Choice point.')
        clf
        colormap bone
        hold on
        if length(unique(Head.BLframe(:)))>10
            imagesc(Head.BLframe)
        end
        plot(Head.x.data,Head.y.data,'k.','markersize',1)
        plot(SoM_x+75*cos(theta),SoM_y+75*sin(theta),'g-')
        title('CP')
        axis([0 720 0 480])
        axis ij
        b = 3;
        while b~=1
            [x,y,b]=ginput(1);
            clf
            colormap bone
            hold on
            if length(unique(Head.BLframe(:)))>10
                imagesc(Head.BLframe)
            end
            plot(Head.x.data,Head.y.data,'k.','markersize',1)
            plot(SoM_x+75*cos(theta),SoM_y+75*sin(theta),'g-')
            title('CP')
            plot(x,y,'bo')
            plot(x+75*cos(theta),y+75*sin(theta),'b-')
            axis([0 720 0 480])
            axis ij
        end
        CP_x = x;
        CP_y = y;

        disp('Left feeder.')
        clf
        colormap bone
        hold on
        if length(unique(Head.BLframe(:)))>10
            imagesc(Head.BLframe)
        end
        plot(Head.x.data,Head.y.data,'k.','markersize',1)
        plot(SoM_x+75*cos(theta),SoM_y+75*sin(theta),'g-')
        plot(CP_x+75*cos(theta),CP_y+75*sin(theta),'c-')
        axis([0 720 0 480])
        axis ij
        title('Left feeder')
        b = 3;
        while b~=1
            [x,y,b]=ginput(1);
            clf
            colormap bone
            hold on
            if length(unique(Head.BLframe(:)))>10
                imagesc(Head.BLframe)
            end
            plot(Head.x.data,Head.y.data,'k.','markersize',1)
            plot(SoM_x+75*cos(theta),SoM_y+75*sin(theta),'g-')
            plot(CP_x+75*cos(theta),CP_y+75*sin(theta),'c-')
            title('Left feeder')
            plot(x,y,'bo')
            plot(x+75*cos(theta),y+75*sin(theta),'b-')
            axis([0 720 0 480])
            axis ij
        end
        LF_x = x;
        LF_y = y;

        disp('Right feeder.')
        clf
        colormap bone
        hold on
        if length(unique(Head.BLframe(:)))>10
            imagesc(Head.BLframe)
        end
        plot(Head.x.data,Head.y.data,'k.','markersize',1)
        plot(SoM_x+75*cos(theta),SoM_y+75*sin(theta),'g-')
        plot(CP_x+75*cos(theta),CP_y+75*sin(theta),'c-')
        plot(LF_x+75*cos(theta),LF_y+75*sin(theta),'r-')
        axis([0 720 0 480])
        axis ij
        title('Right feeder')
        b = 3;
        while b~=1
            [x,y,b]=ginput(1);
            clf
            colormap bone
            hold on
            if length(unique(Head.BLframe(:)))>10
                imagesc(Head.BLframe)
            end
            plot(Head.x.data,Head.y.data,'k.','markersize',1)
            plot(SoM_x+75*cos(theta),SoM_y+75*sin(theta),'g-')
            plot(CP_x+75*cos(theta),CP_y+75*sin(theta),'c-')
            plot(LF_x+75*cos(theta),LF_y+75*sin(theta),'r-')
            axis([0 720 0 480])
            axis ij
            title('Right feeder')
            plot(x,y,'bo')
            plot(x+75*cos(theta),y+75*sin(theta),'b-')
        end
        RF_x = x;
        RF_y = y;
    end
    
    Coord.SoM_x = SoM_x;
    Coord.SoM_y = SoM_y;
    Coord.CP_x = CP_x;
    Coord.CP_y = CP_y;
    Coord.LF_x = LF_x;
    Coord.LF_y = LF_y;
    Coord.RF_x = RF_x;
    Coord.RF_y = RF_y;
    save([SSN '-MazeCoord.mat'],'Coord');
    
    popdir;
end
