% Reads data files from BBT and returns processed data

clc; clearvars; close all;

% Input Parameters
BarNum =  5;
OTfile1 = '20';
OTfile2 = '21';
Direct = 1;         % 1 for buckling back, -1 for buckling forward
MTSforce = 3;       % column which has MTS force data
MTSdisp = 2;        % column which has MTS displacement data
n = 4;              % Order of polynomial to fit
dbl = 0.6708;        % Diameter of rebar, in
BarDia = 25.4*dbl;  % Diameter of rebar, mm
Ab = (pi/4)*dbl^2;  % area of rebars, in2

PrintLocation = 'C:\ConditionDependentPBEE\ExperimentalProgram\BBT Tests\Processed Data\CL20\bar';
addpath('C:\ConditionDependentPBEE\ExperimentalProgram\BBT Tests\Raw Data\CL20\MTS')
addpath('C:\ConditionDependentPBEE\ExperimentalProgram\BBT Tests\Raw Data\CL20\Optotrack\CDPBEE_corrosion_2021_12_07_094712');

filename1 = ['CDPBEE_corrosion_2021_12_07_094712_0',(OTfile1),'_3d.xls'];     % name of Optotrak data file - push
filename2 = ['CDPBEE_corrosion_2021_12_07_094712_0',(OTfile2),'_3d.xls'];     % name of Optotrak data file - pull
filename3 = ['bbt_20_',num2str(BarNum),'_comp.txt'];                              % name of MTS data file - push
filename4 = ['bbt_20_',num2str(BarNum),'_tension.txt'];                              % name of MTS data file - pulls                              % name of MTS data file - pulls 
header1 = 5;                            % number of header lines to skip in Optotrak
header2 = 8;                            % number of header lines to skip in MTS file
np = 7;                                 % number of Optotrak sensors

%% Import experimental data
data1 = dlmread(filename1,'',header1,1);            % imports Optotrak push data to matrix 'data1'
data2 = dlmread(filename2,'',header1,1);            % imports Optotrak pull data to matrix 'data2'
data3 = dlmread(filename3,'',header2,0);            % imports MTS push data to matrix 'data3'
data4 = dlmread(filename4,'',header2,0);            % imports MTS pull data to matrix 'data4'

% Match length of push files 
if length(data1)>length(data3)
    data1(length(data3)+1:length(data1),:) = [];
else 
    data3(length(data1)+1:length(data3),:) = [];
end

% Match length of pull files 
if length(data2)>length(data4)
    data2(length(data4)+1:length(data2),:) = [];
else
    data4(length(data2)+1:length(data4),:) = [];
end

% Concatenate separate data files
otdata = [data1;data2];
mtsdata = [data3;data4];

% Take out bad data
    for i = 1:length(otdata)-1
        for j = 1:length(otdata(1,:))
            if abs(otdata(i,j)-otdata(i+1,j)) > 1
                otdata(i+1,j) = NaN;
            end
        end
    end
    i = 1;
    while i < length(otdata)
        if sum(isnan(otdata(i,1)))
            otdata(i,:) = [];
            mtsdata(i,:) = [];
            otdata(i+1,:) = [];
            mtsdata(i+1,:) = [];
        end
        i = i+1;
    end

%% Organize LED Data
% Matrices with relative LED data marker position data
Xlocs = zeros(length(otdata),9);
Ylocs = zeros(length(otdata),9);
Zlocs = zeros(length(otdata),9);
Zplocs = zeros(length(otdata),9);

for i = 1:length(otdata)
    Xlocs(i,:) = otdata(i,1:3:27) - otdata(1,1:3:27);
    if otdata(1,2)<otdata(1,26)
        Ylocs(i,:) = otdata(i,2:3:27) - otdata(1,2);
    else
        Ylocs(i,:) = otdata(i,2:3:27) - otdata(1,26);
    end
    Zlocs(i,:) = otdata(i,3:3:27) - otdata(1,3:3:27);
    Zplocs(i,:) = sqrt(Xlocs(i,:).^2 + Zlocs(i,:).^2);
end

% Find point of maximum deflection, at last point of compression
maxc = length(data1);

% Coordinates to fit bar
Y2Fit = Ylocs(maxc,:)*0.0393701;
Z2Fit = Zlocs(maxc,:)*0.0393701;
X2Fit = Xlocs(maxc,:)*0.0393701;
ZP2Fit = Zplocs(maxc,:)*0.0393701;

% Fit of Z prime data
Fitzp = polyfit(Y2Fit,ZP2Fit,n);
y3 = min(Y2Fit)-0.5:0.01:max(Y2Fit)+0.5;
zp = polyval(Fitzp,y3);
[maxzp,I] = max(zp);
maxy3 = y3(I);
% Second Derivative of Z'-data
d2zp = diff(diff(zp));
dy2 = diff(y3).*diff(y3);
d2zpdy2 = d2zp./dy2(1:length(d2zp));
% Find strains from curvature
curv = min(d2zpdy2);
strain = curv*((BarDia/25.4)/2);

%% Move LED locations to neutral axis of bar
% First Derivative of Z prime data 
dy = diff(zp);
dx = diff(y3);
dydx = dy./dx;
% Find line tangent to Z' fitted line and line perpendicular to tangent
m = interp1(y3(1:length(dydx)),dydx,Y2Fit);     % slope of fit to Z' at LED locations
perp = -1./m;               % slope of line perpendicular to tangent
b = ZP2Fit-(perp.*Y2Fit);   % intercept of perpendicular line
bp = ZP2Fit-(m.*Y2Fit);     % intercept of tangent line
% Move in or out to location of neutral axis depth (1/2 bar dia. + 0.1" for LED)
dNA = (BarDia/50.8+0.1);
nax = Y2Fit+sign(perp).*Direct.*(dNA./sqrt(1+perp.^2));
nay = perp.*nax+b;

%% Fit line to LED locations at neutral axis of bar
FitNA = polyfit(nax,nay,n);
yNA = min(nax):0.1:max(nax);
xNA = polyval(FitNA,yNA);

% Second Derivative of Z'-data at neutral axis
d2zNA = diff(diff(xNA));
dyNA2 = diff(yNA).*diff(yNA);
d2ydx2 = d2zNA./dyNA2(1:length(d2zNA));

% Find strains from curvature
curvNA = min(d2ydx2);
strainNA = curvNA*((BarDia/25.4)/2);

%% Plot NA bar locations and fit
h=figure('Units','Inches','Position', [4,1,3,5]);hold all;grid on;box on
whitebg('w');
xlim([-0.5 2.5]); ylim([-1 9]);
plot(zp,y3,'r','LineWidth',1)
plot(xNA,yNA,'g','LineWidth',1)
plot(ZP2Fit,Y2Fit,'ro','LineWidth',1,'MarkerFaceColor','r','MarkerSize',3)
plot(nay,nax,'go','LineWidth',1,'MarkerFaceColor','g','MarkerSize',3)
plot([0 0],[-5 50],'k--','LineWidth',1.5);
plot([-5 5],[0 0],'k--','LineWidth',1.5);
legend('LED Deflection','N/A Deflection','Location','Best')
set(gca,'FontSize',12,'FontName','Times New Roman')
xlabel('Deformation [in]','FontSize',16);
ylabel('Height [in]','FontSize',16);
set(gca,'Color','w');
set(gcf,'Color','w','InvertHardCopy','off');
print(h,'-dpng','-r250',[PrintLocation,num2str(BarNum),'\Position.png'])

%% Plot NA curvature
h=figure('Units','Inches','Position', [7,1,3,5]);hold all;grid on;box on
whitebg('w');
xlim([-1.7 1.7]); ylim([-1 9]);
plot(d2zpdy2,y3(1:length(d2zpdy2)),'r','LineWidth',1)
plot(d2ydx2,yNA(1:length(d2ydx2)),'g','LineWidth',1)
plot([0 0],[-5 50],'k--','LineWidth',1.5);
plot([-5 5],[0 0],'k--','LineWidth',1.5);
legend('LED Curvature','N/A Curvature','Location','Best')
text(0.8,median(y3)+0.8,['\phi_{LED} = ',num2str(round(abs(curv),3))...
    ,char(10),'\epsilon_{LED} = ',num2str(round(abs(strain),3))],...
    'BackgroundColor','w','HorizontalAlignment','center',...
    'EdgeColor','k','FontSize',10);
text(0.8,median(y3)-0.8,['\phi_{N/A} = ',num2str(round(abs(curvNA),3))...
    ,char(10),'\epsilon_{N/A} = ',num2str(round(abs(strainNA),3))],...
    'BackgroundColor','w','HorizontalAlignment','center',...
    'EdgeColor','k','FontSize',10);
set(gca,'FontSize',12,'FontName','Times New Roman')
xlabel('Curvature  [1/in]','FontSize',16);
ylabel('Height [in]','FontSize',16);
set(gca,'Color','w');
set(gcf,'Color','w','InvertHardCopy','off');
print(h,'-dpng','-r250',[PrintLocation,num2str(BarNum),'\Curvature.png'])

%% Find bar stresses and point of fracture

stresses = zeros(length(otdata),1);
% Stresses in bar
for i = 1:length(mtsdata)
    stresses(i) = mtsdata(i,MTSforce)/Ab;
end
[maxstress,maxstressloc] = max(abs(stresses));
[maxpstress,maxpstressloc] = max(stresses);

% Find time step of fracture
for i=length(stresses):-1:1
    if stresses(i)<-1 || stresses(i)>1
        fracture = i-1;
        stresses(fracture+1:length(stresses)) = [];
        break
    end
end
fracture = fracture-8;

if maxpstressloc > fracture
    maxpstressloc = fracture;
end

% Find time of zero stress for initialize gage lengths
for i=1:100
    if stresses(i)>0 && stresses(i+1)<0
        zerostress = i;
        break
    end
end
%zerostress = 1;
%% Calculate strains

% Initialize matrices for speed
lengths = zeros(fracture,np-1);
strains = zeros(fracture,np-1);

% Length of each gage length at each time step
for i = 1:length(lengths)
    for j = 4:3:(np-1)*3+1          
        lengths(i,ceil(j/3)-1) = sqrt((otdata(i,j+3)-otdata(i,j))^2 + ...            
            (otdata(i,j+4)-otdata(i,j+1))^2 + (otdata(i,j+5) ...
            -otdata(i,j+2))^2 );     
    end
end

% Calculate strains
for i = 1:length(lengths) 
    for j = 1:np-1
        strains(i,j) = (lengths(i,j) - lengths(zerostress,j))/lengths(zerostress,j);      
        if strains(i,j)>0.5 || strains(i,j)<-0.5
            strains(i,j) = NaN;
        end
    end
end

% Average strain 
avgstr = zeros(length(lengths),1);
strainsum = 0;
for i = 1:length(lengths)
    for j = 1:np-1
        strainsum = strainsum + strains(i,j);
    end
    avgstr(i) = strainsum/(np-1);       
    strainsum = 0;
end

% Max strain 
maxstr = zeros(length(lengths),1);
strainsum = 0;
for i = 1:length(lengths)
    maxstr(i) = max(strains(i,:));
end

% Plot strains at each gage length
maxfracture = 0;
for i = 1:6
    if strains(fracture,i)>maxfracture
        maxfracture = strains(fracture,i);
    end
end

% Calculate axial strain
straina = (mtsdata(maxc,MTSforce)/(29000*Ab))+strainNA;

%% Calculate elongations and plot stress vs. strain
unielong = strains(maxpstressloc,:);

checkneg = unielong(unielong<0);        % calculate avg of uniform elongation values
if isempty(checkneg) == 1               % if any values are negative, assume avg = 0
    avg_ue = mean(unielong);            
else
    avg_ue = 0;
end

li = (otdata(zerostress,5)-otdata(zerostress,23));         % original length from LED's on bar
lig = abs(otdata(zerostress,26)-otdata(zerostress,2));     % original length from LED's on grips
lax = lig-abs((otdata(maxc,26)-otdata(maxc,2)));           % axial deformation
elong = ((otdata(:,5)-otdata(:,23))-li)./li;               % elongation based on LED's on bar
elong1 = (abs((otdata(:,26)-otdata(:,2)))-lig)./lig;              % elongation based on LED's on grips
elongMTS = (mtsdata(:,MTSdisp)-mtsdata(1,MTSdisp))./(mtsdata(:,MTSdisp)+lig/25.4);  % elongation based on MTS data
LD = (lig-13)/BarDia;       

h = figure('Units','Inches','Position', [1,1,6,4]);hold all;grid on;box on
whitebg('w');
set(gca,'FontSize',14,'FontName','Times New Roman');hold all
plot(elongMTS(1:fracture),stresses(1:fracture),'c','LineWidth',1.5);
plot(elong1(1:fracture),stresses(1:fracture),'r','LineWidth',1.5);
plot(elongMTS(fracture),stresses(fracture),'cx','LineWidth',2,'MarkerFaceColor','r','MarkerSize',10);
plot([0 0],[-200 200],'k:','LineWidth',1.5);
plot([-20 20],[0 0],'k:','LineWidth',1.5);
axis([-0.3,0.2,-130,180])
legend('MTS elongation','Optotrak elongation','Location','Best');
title(['CMC #5 - V3, Specimen #',num2str(BarNum)],'FontSize',18)
xlabel('Axial Strain','FontSize',16); 
ylabel('Stress [ksi]','FontSize',16);
set(gca,'Color','w');
set(gcf,'Color','w','InvertHardCopy','off');
print(h,'-dpng','-r250',[PrintLocation,num2str(BarNum),'\StressStrain.png'])

h = figure('Units','Inches','Position', [1,1,8,6]);hold all;grid on;box on
whitebg('w');
set(gca,'FontSize',14,'FontName','Times New Roman');hold all
plot(elongMTS(1:fracture),stresses(1:fracture),'k','LineWidth',2.5);
plot(strains(1:fracture,1),stresses(1:fracture),'LineWidth',1.5);
plot(strains(1:fracture,2),stresses(1:fracture),'LineWidth',1.5);
plot(strains(1:fracture,3),stresses(1:fracture),'LineWidth',1.5);
plot(strains(1:fracture,4),stresses(1:fracture),'LineWidth',1.5);
plot(strains(1:fracture,5),stresses(1:fracture),'LineWidth',1.5);
plot(strains(1:fracture,6),stresses(1:fracture),'LineWidth',1.5);
plot(elong(1:fracture),stresses(1:fracture),'r','LineWidth',1.5);
plot(elong1(1:fracture),stresses(1:fracture),'c','LineWidth',1.5);
plot(elongMTS(fracture),stresses(fracture),'x','LineWidth',1.5,'MarkerSize',8);
plot(strains(fracture,1),stresses(fracture),'x','LineWidth',1.5,'MarkerSize',8);
plot(strains(fracture,2),stresses(fracture),'x','LineWidth',1.5,'MarkerSize',8);
plot(strains(fracture,3),stresses(fracture),'x','LineWidth',1.5,'MarkerSize',8);
plot(strains(fracture,4),stresses(fracture),'x','LineWidth',1.5,'MarkerSize',8);
plot(strains(fracture,5),stresses(fracture),'x','LineWidth',1.5,'MarkerSize',8);
plot(strains(fracture,6),stresses(fracture),'x','LineWidth',1.5,'MarkerSize',8);
plot(elong(fracture),stresses(fracture),'rx','LineWidth',1.5,'MarkerSize',8);
plot(elong1(fracture),stresses(fracture),'cx','LineWidth',1.5,'MarkerSize',8);
plot(elongMTS(fracture),stresses(fracture),'kx','LineWidth',2.5,'MarkerSize',12);
plot(elongMTS(maxpstressloc,1),stresses(maxpstressloc),'o','LineWidth',1.5,'MarkerSize',8);
plot(strains(maxpstressloc,1),stresses(maxpstressloc),'o','LineWidth',1.5,'MarkerSize',8);
plot(strains(maxpstressloc,2),stresses(maxpstressloc),'o','LineWidth',1.5,'MarkerSize',8);
plot(strains(maxpstressloc,3),stresses(maxpstressloc),'o','LineWidth',1.5,'MarkerSize',8);
plot(strains(maxpstressloc,4),stresses(maxpstressloc),'o','LineWidth',1.5,'MarkerSize',8);
plot(strains(maxpstressloc,5),stresses(maxpstressloc),'o','LineWidth',1.5,'MarkerSize',8);
plot(strains(maxpstressloc,6),stresses(maxpstressloc),'o','LineWidth',1.5,'MarkerSize',8);
plot(elongMTS(maxpstressloc,1),stresses(maxpstressloc),'ko','LineWidth',2.5,'MarkerSize',8)
plot([0 0],[-200 200],'k:','LineWidth',1.5);
plot([-20 20],[0 0],'k:','LineWidth',1.5);
axis([-0.3,0.3,-120,160])
legend('MTS elongation','OT g1','OT g2','OT g3', 'OT g4', 'OT g5', 'OT g6','OT all gages','OT on MTS','Location','Best');
title(['CMC #5 - V3, Specimen #',num2str(BarNum)],'FontSize',18)
text(0.28,-100,['Average Uniform Elongation = ',num2str(round(abs(avg_ue),3))],...
    'BackgroundColor','w','HorizontalAlignment','right',...
    'EdgeColor','k','FontSize',10);
xlabel('Axial Strain','FontSize',16); 
ylabel('Stress [ksi]','FontSize',16);
set(gca,'Color','w');
set(gcf,'Color','w','InvertHardCopy','off');
print(h,'-dpng','-r250',[PrintLocation,num2str(BarNum),'\StressStrain_OT.png'])

%% Concatenate allresults
results = {LD,lax/25.4,maxzp,maxstress,curvNA,strainNA,straina,elongMTS(fracture),avg_ue};
xlswrite([PrintLocation,num2str(BarNum),'\Results.xls'],results)