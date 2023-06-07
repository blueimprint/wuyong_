function Bomb(n,mm)
close;
if nargin ~= 2
    n = [25,18];%长和宽
    mm = 80;%雷个数
end
if mm + 1 > n(1) * n(2) || mm < 1 || any(n <= 1)
    error('Setting error');
end

f1 = figure('Name','Bombs','NumberTitle','off','MenuBar','none', ...
    'Color',[1,1,1],'Position',[350,130,900,600],'WindowButtonDownFcn', ...
    @BDF,'WindowButtonMotionFcn',@BMF,'WindowButtonUpFcn',@BUF);
ax = axes(f1,'XTick',[],'YTick',[],'XColor',[1,1,1],'YColor',...
    [1,1,1],'Color',[1,1,1],'Parent',f1,'Position',[0,0.01,...
    17/19,0.99],'XTickLabel',[],'YTickLabel',[],'XLim',[0,n(1)+1],...
    'YLim',[0,n(2)+1],'DataAspectRatio',[1,1,1]);
T = uicontrol(f1,'Style','text','BackgroundColor',[1,1,1],'String',...
    num2str(mm),'Units','normalized','Position',[13/14,0.80,1/14,0.1],...
    'FontSize',18,'FontWeight','bold');
hold on

for i = n(1):-1:1
    for j = n(2):-1:1
        M(i,j) = patch(ax,[i,i+1,i+1,i]-0.5,[j,j,j+1,j+1]-0.5,...
            [0.8,0.8,0.8],'EdgeColor',[0.7,0.7,0.7]);
        F(i,j) = image(ax,[i-0.4,i+0.4],[j-0.4,j+0.4],[]);
    end
end

xd = 1; yd = 1;
xm = 1; ym = 1;
xu = 1; yu = 1;
PC = [0.8,0.8,0.8]; % last color
CD = uint8([0,0,225;2,129,2;253,7,7;20,20,158;...
    128,1,1;0,128,128;10,10,10;128,128,128]); % CData of Number
MT = 0; Endbuttom = '';

FLAG = zeros(9,9,3,'uint8'); % Draw Flag
FLAG(:,:,1) = [204 204 204 204 204 204 204 204 204;
    204 0 0 0 0 0 0 0 204;
    204 204 0 0 0 0 0 204 204;
    204 204 204 204 0 204 204 204 204;
    204 204 204 204 255 204 204 204 204;
    204 204 255 255 255 204 204 204 204;
    204 204 204 255 255 204 204 204 204;
    204 204 204 204 255 204 204 204 204;
    204 204 204 204 204 204 204 204 204];
FLAG(:,:,2) = [204 204 204 204 204 204 204 204 204;
    204 0 0 0 0 0 0 0 204;
    204 204 0 0 0 0 0 204 204;
    204 204 204 204 0 204 204 204 204;
    204 204 204 204 0 204 204 204 204;
    204 204 0 0 0 204 204 204 204;
    204 204 204 0 0 204 204 204 204;
    204 204 204 204 0 204 204 204 204;
    204 204 204 204 204 204 204 204 204];
FLAG(:,:,3) = [204 204 204 204 204 204 204 204 204;
    204 0 0 0 0 0 0 0 204;
    204 204 0 0 0 0 0 204 204;
    204 204 204 204 0 204 204 204 204;
    204 204 204 204 0 204 204 204 204;
    204 204 0 0 0 204 204 204 204;
    204 204 204 0 0 204 204 204 204;
    204 204 204 204 0 204 204 204 204;
    204 204 204 204 204 204 204 204 204];

BOMB = zeros(15,15,3,'uint8'); % draw the Bomb
BOMB(:,:,1) = [
    255 255 255 255 255 255 255 255 255 255 255 255 255 255 255;
    255 255 255 255 255 255 255 0 255 255 255 255 255 255 255;
    255 255 255 255 255 255 255 0 255 255 255 255 255 255 255;
    255 255 255 0 255 0 0 0 0 0 255 0 255 255 255;
    255 255 255 255 0 0 0 0 0 0 0 255 255 255 255;
    255 255 255 0 0 0 0 0 0 0 0 0 255 255 255;
    255 255 255 0 0 0 0 0 0 0 0 0 255 255 255;
    255 0 0 0 0 0 0 0 0 0 0 0 0 0 255;
    255 255 255 0 0 255 255 0 0 0 0 0 255 255 255;
    255 255 255 0 0 255 255 0 0 0 0 0 255 255 255;
    255 255 255 255 0 0 0 0 0 0 0 255 255 255 255;
    255 255 255 0 255 0 0 0 0 0 255 0 255 255 255;
    255 255 255 255 255 255 255 0 255 255 255 255 255 255 255;
    255 255 255 255 255 255 255 0 255 255 255 255 255 255 255;
    255 255 255 255 255 255 255 255 255 255 255 255 255 255 255];
BOMB([9,10],[6,7],[2,3]) = 255;

MDATA = zeros(n,'logical'); % If this position was open
BF = zeros(n,'logical'); % Bombs found
NClick = true; % First protect
BDATA = zeros(n); % locate of Bomb
Ndata = zeros(n); % Map information
aa = 1; bb = 1;
cc = false;
dd = true;

    function BDF(~,~)
        m = get(ax,'CurrentPoint');
        xd = round(m(1,1));
        yd = round(m(1,2));
        MT = length(get(f1,'SelectionType'));
        if xd>=1 && xd<=n(1) && yd>=1 && yd<=n(2) && MDATA(xd,yd) &&...
                Ndata(xd,yd)>0 && (MT==6 || MT==3)
            [a,b] = specialgrid(xd,yd);
            C = zeros(n,'logical');
            C(a,b) = true;
            [aa,bb] = find(C & ~MDATA & ~BF);
            for ii = [aa,bb].'
                M(ii(1),ii(2)).FaceColor = [0.6,0.6,0.6];
            end
            cc = true;
        end
        if NClick
            Bset = randperm(n(1) * n(2) - 1,mm) + 1;
            Npoint = (yd - 1) * n(1) + xd;
            if ismember(Npoint,Bset)
                Bset(Bset <= Npoint) = Bset(Bset <= Npoint) - 1;
            end
            BDATA(Bset) = 1;
            Ndata = conv2(BDATA,[1,1,1;1,0,1;1,1,1],'same');
            Ndata(BDATA == 1) = -1;
            NClick = false;
        end
    end

    function BMF(~,~)
        if dd
            M(xm,ym).FaceColor = PC;
            M(xm,ym).FaceAlpha = 1;
        end
        m = round(get(ax,'CurrentPoint'));
        if m(1) < 1 || m(1) > n(1) || m(3) < 1 || m(3) > n(2)
            dd = false;
        else
            dd = true;
            xm = m(1); ym = m(3);
            PC = M(xm,ym).FaceColor;
            M(xm,ym).FaceColor = [0.8,0.8,0.8];
            M(xm,ym).FaceAlpha = 0.5;
        end
    end

    function BUF(~,~)
        if cc
            for ii = [aa,bb].'
                M(ii(1),ii(2)).FaceColor = [0.8,0.8,0.8];
            end
            cc = false;
        end
        m = get(ax,'CurrentPoint');
        xu = round(m(1,1));
        yu = round(m(1,2));
        if xd==xu && yd==yu && xu>=1 && yu>=1 && xu<=n(1) && yu<=n(2)
            if ~MDATA(xu,yu)
                if MT == 6
                    if ~BF(xu,yu)
                        if Ndata(xu,yu) == -1
                            BF(xu,yu) = true;
                            M(xu,yu).FaceColor = [1,0,0];
                            PC = [1,0,0];
                            F(xu,yu).CData = BOMB;
                            T.String = num2str(str2double(T.String) - 1);
                            if length(Endbuttom) ~= 3
                                ENDq(false)
                            end
                        else
                            MDATA(xu,yu) = true;
                            M(xu,yu).FaceColor = [1,1,1];
                            PC = [1,1,1];
                            if Ndata(xu,yu) == 0
                                swap(xu,yu)
                            else
                                TEXT(xu,yu)
                            end
                        end
                    end
                elseif MT == 3
                    if ~BF(xu,yu)
                        BF(xu,yu) = true;
                        F(xu,yu).CData = FLAG;
                        T.String = num2str(str2double(T.String) - 1);
                    else
                        BF(xu,yu) = false;
                        F(xu,yu).CData = [];
                        T.String = num2str(str2double(T.String) + 1);
                    end
                end
            elseif Ndata(xu,yu) > 0
                [a,b] = specialgrid(xu,yu);
                if sum(BF(a,b),'all') == Ndata(xu,yu) &&...
                        sum(BF(a,b),'all') < sum(~MDATA(a,b),'all')
                    C = zeros(n,'logical');
                    C(a,b) = true;
                    [a,b] = find(C & ~MDATA & ~BF);
                    for ii = [a,b].'
                        MDATA(ii(1),ii(2)) = true;
                        if Ndata(ii(1),ii(2)) == -1
                            BF(ii(1),ii(2)) = true;
                            MDATA(ii(1),ii(2)) = false;
                            M(ii(1),ii(2)).FaceColor = [1,0,0];
                            F(ii(1),ii(2)).CData = BOMB;
                            T.String = num2str(str2double(T.String) - 1);
                            if length(Endbuttom) ~= 3
                                ENDq(false)
                            end
                        else
                            M(ii(1),ii(2)).FaceColor = [1,1,1];
                            PC = [1,1,1];
                            if Ndata(ii(1),ii(2)) == 0
                                swap(ii(1),ii(2))
                            else
                                TEXT(ii(1),ii(2))
                            end
                        end
                    end
                end
            end
        end
        if (all(BDATA == ~MDATA,'all') ||...
                all(BDATA == BF,'all')) && length(Endbuttom) ~= 3
            ENDq(true)
        end
    end

    function swap(x,y)
        C = zeros(n(1),n(2),'logical');
        C_ = C;
        C(x,y) = true;
        while ~all(C == C_,'all')
            C_ = C;
            [x,y] = find((~Ndata | BF) & C);
            for ii = [x,y].'
                if Ndata(ii(1),ii(2)) == 0
                    [a,b] = specialgrid(ii(1),ii(2));
                    C(a,b) = ~BF(a,b);
                end
            end
        end
        [x,y] = find(C);
        for ii = [x,y].'
            MDATA(ii(1),ii(2)) = true;
            M(ii(1),ii(2)).FaceColor = [1,1,1];
            if Ndata(ii(1),ii(2)) ~= 0
                TEXT(ii(1),ii(2))
            end
        end
    end

    function [a,b] = specialgrid(x,y)
        if x == 1
            a = [1,2];
        elseif x == n(1)
            a = [n(1)-1,n(1)];
        else
            a = x-1:x+1;
        end
        if y == 1
            b = [1,2];
        elseif y == n(2)
            b = [n(2)-1,n(2)];
        else
            b = y-1:y+1;
        end
    end

    function TEXT(x,y)
        text(x,y,num2str(Ndata(x,y)),'FontSize',15,'FontWeight',...
            'bold','Color',CD(Ndata(x,y),:),'HorizontalAlignment','center');
    end

    function ENDq(a)
        if a
            Endbuttom = questdlg('You Win !','YouWin',...
                'restart','close','restart');
        else
            Endbuttom = questdlg('You Lose.',...
                'YouLose','restart','close','restart');
        end
        if isempty(Endbuttom)
            Endbuttom = 'end';
        end
        if length(Endbuttom) == 7
            Bomb;
        elseif length(Endbuttom) == 5
            close; clear;
        end
    end

end
