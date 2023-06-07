import pyautogui as pag
import time
import random
#网格边长
d=16;
#左上角坐标
stx,sty=420,449;
#行数和列数
h,l=16,30;
#参考对比图像
img=[];
img.append([47168,47168,47168]);
img.append([39488,39488,49688]);
img.append([34688,43008,34688]);
img.append([51074,35264,35264]);
img.append([36416,36416,43584]);
img.append([42688,33728,33728]);
img.append([33344,42560,42560]);
img.append([38720,38720,38720]);
img.append([42304,42304,42304]);
img.append([49098,49098,49098]);
img.append([45945,41610,41610]);
#游戏运行状况
gamestate=[0];
#雷区地图
mp=[];
for i in range(h):
    mp+=[[]];
    for j in range(l):
        mp[i]+=[9];
#遍历标记
vis=[];
for i in range(h):
    vis+=[[]];
    for j in range(l):
        vis[i]+=[0];
#迭代加深层数
maxd=3;
#迭代加深路径
path=[[0,0,0]];
for i in range(maxd):
    path.append([0,0,0]);

#更新点
def update_point(X,Y):
    im=pag.screenshot(region=(stx+d*Y,sty+d*X,d,d));
    r1,g1,b1=im.getpixel((8,8));
    if r1<10 and g1<10 and b1<10:
        mp[X][Y]=-1;
        gamestate[0]=-1;
        return;
    R,G,B=0,0,0;
    for x in range(0,16):
        for y in range(0,16):
            r1,g1,b1=im.getpixel((x,y));
            R+=r1;G+=g1;B+=b1;
    for k in range(11):
        now=(R-img[k][0])**2+(G-img[k][1])**2+(B-img[k][2])**2;
        if now<100:
            mp[X][Y]=k;
            return;
#更新整个地图
def update_whole_map():
    im=pag.screenshot();
    for i in range(h):
        for j in range(l):
            if mp[i][j]==9:
                r1,g1,b1=im.getpixel((stx+j*d+8,sty+i*d+8));
                if r1<10 and g1<10 and b1<10:
                    mp[i][j]=-1;
                    gamestate[0]=-1;
                    continue;
                R,G,B=0,0,0;
                for x in range(0,16):
                    for y in range(0,16):
                        r1,g1,b1=im.getpixel((stx+j*d+x,sty+i*d+y));
                        R+=r1;G+=g1;B+=b1;
                for k in range(11):
                    now=(R-img[k][0])**2+(G-img[k][1])**2+(B-img[k][2])**2;
                    if now<100:
                        mp[i][j]=k;
                        break;
#点出大片空地后更新地图
def map_dfs(X,Y):
    if X<0 or X>=h or Y<0 or Y>=l:
        return;
    if mp[X][Y]!=9:
        return;
    update_point(X,Y);
    if mp[X][Y]==9:
        return;
    if mp[X][Y]==0:
        map_dfs(X-1,Y-1);
        map_dfs(X-1,Y);
        map_dfs(X-1,Y+1);
        map_dfs(X,Y-1);
        map_dfs(X,Y+1);
        map_dfs(X+1,Y-1);
        map_dfs(X+1,Y);
        map_dfs(X+1,Y+1);
#模拟鼠标点击清除草地
def clear_grass(X,Y):
    pag.click(x=stx+d/2+d*Y,y=sty+d/2+d*X,button='left');
    update_point(X,Y);
    if mp[X][Y]==0:
        update_whole_map();
#模拟鼠标点击插旗子
def make_flag(X,Y):
    pag.click(x=stx+d/2+d*Y,y=sty+d/2+d*X,button='right');
    mp[X][Y]=10;
#输出整个地图
def print_map():
    for i in range(h):
        for j in range(l):
            if mp[i][j]==10:
                print("*",end=" ");
            elif mp[i][j]==-1:
                print("!",end=" ");
            elif mp[i][j]==9:
                print("?",end=" ");
            elif mp[i][j]==0:
                print(" ",end=" ");
            else:
                print(mp[i][j],end=" ");
        print("");
#匹配点
def match_point(X,Y,num):
    if X<0 or X>=h or Y<0 or Y>=l:
        return False;
    elif mp[X][Y]==num:
        return True;
    else:
        return False;
#暴力检验
def bruteforce():
    changed=False;
    for x in range(h):
        for y in range(l):
            if mp[x][y]>0 and mp[x][y]<9 and vis[x][y]==0:
                unknow=0;
                boomnum=0;
                for i in range(-1,2):
                    for j in range(-1,2):
                        if match_point(x+i,y+j,9):
                            unknow+=1;
                        if match_point(x+i,y+j,10):
                            boomnum+=1;
                if mp[x][y]==boomnum:
                    changed=True;
                    vis[x][y]=1;
                    for i in range(-1,2):
                        for j in range(-1,2):
                            if match_point(x+i,y+j,9):
                                clear_grass(x+i,y+j);
                if mp[x][y]==boomnum+unknow:
                    changed=True;
                    vis[x][y]=1;
                    for i in range(-1,2):
                        for j in range(-1,2):
                            if match_point(x+i,y+j,9):
                                make_flag(x+i,y+j);
    return changed;
#判断某点数字是否可行
def check_point_num(X,Y):
    if X<0 or X>=h or Y<0 or Y>=l:
        return True;
    if mp[X][Y]<0 or mp[X][Y]>8:
        return True;
    unknow=0;
    boomnum=0;
    for i in range(-1,2):
        for j in range(-1,2):
            if match_point(X+i,Y+j,9):
                unknow+=1;
            if match_point(X+i,Y+j,10) or match_point(X+i,Y+j,-1):
                boomnum+=1;
    return mp[X][Y]>=boomnum and mp[X][Y]<=boomnum+unknow;
#判断某点是否有雷
def check_point_boom(X,Y):
    for i in range(-1,2):
        for j in range(-1,2):
            if not check_point_num(X+i,Y+j):
                return False;
    return True;
#检验搜索路径是否可行
def check_path(D):
    for i in range(D+1):
        if path[i][2]==1:
            mp[path[i][0]][path[i][1]]=-1;
        else:
            mp[path[i][0]][path[i][1]]=-2;
    yes=True;
    for i in range(D+1):
        if not check_point_boom(path[i][0],path[i][1]):
            yes=False;
    for i in range(D+1):
        mp[path[i][0]][path[i][1]]=9;
    return yes;
#迭代加深
def dfs(X,Y,state,D,md):
    #print(X,Y,state,D);
    if X<0 or X>=h or Y<0 or Y>=l or mp[X][Y]!=9:
        return check_path(D-1);
    path[D]=[X,Y,state];
    if D==md:
        return check_path(D);
    else:
        f1=dfs(X-1,Y  ,1,D+1,md) or dfs(X-1,Y  ,0,D+1,md);
        f2=dfs(X+1,Y  ,1,D+1,md) or dfs(X+1,Y  ,0,D+1,md);
        f3=dfs(X  ,Y-1,1,D+1,md) or dfs(X  ,Y-1,0,D+1,md);
        f4=dfs(X  ,Y+1,1,D+1,md) or dfs(X  ,Y+1,0,D+1,md);
        return f1 and f2 and f3 and f4;
#判断是否为数字块
def is_num(X,Y):
    if X<0 or X>=h or Y<0 or Y>=l:
        return False;
    return mp[X][Y]>=0 and mp[X][Y]<9;
#判断是否为边界未知块
def near_num(X,Y):
    if mp[X][Y]!=9:
        return False;
    for i in range(-1,2):
        for j in range(-1,2):
            if is_num(X+i,Y+j):
                return True;
    return False;
#搜索
def search(md):
    for i in range(h):
        for j in range(l):
            if near_num(i,j):
                if not dfs(i,j,1,0,md):
                    clear_grass(i,j);
                    return True;
                elif not dfs(i,j,0,0,md):
                    make_flag(i,j);
                    return True;
    return False;
#随机
def rand_try():
    while 1:
        x=random.randint(0,h-1);
        y=random.randint(0,l-1);
        if mp[x][y]!=9:
            continue;
        else:
            clear_grass(x,y);
            break;
    return mp[x][y]!=-1;
#检验游戏是否完成
def win():
    for i in range(h):
        for j in range(l):
            if mp[i][j]==9:
                return False;
    gamestate[0]=1;
    return True;

pag.hotkey('alt','tab');
time.sleep(1);
update_whole_map();
while 1:
    if win():
        break;
    if gamestate[0]==-1:
        break;
    if not bruteforce():
        flag=False;
        for md in range(2,maxd+1):
            if search(md):
                flag=True;
                break;
        if not flag:
            if not rand_try():
                break;
print_map();
if gamestate[0]==1:
    pag.alert('successful');
elif gamestate[0]==0:
    pag.alert('unfinished');
else:
    pag.alert('failed');