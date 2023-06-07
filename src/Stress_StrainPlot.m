%% Stress-strain plot with embellishments
% Afnan Mostafa
% 06/07/2023

%% Happy Summer 2023!!

%% clearing space
clear
clc
close all

%% read file(s)
files = ("stress_profile_30140.txt");

%% shear or uniaxial tension/compression (use only 1)
isShear = 1;
isTensile = 0;
isCompressive = 0;

%% edge case 1
if sum([isShear, isTensile, isCompressive]) > 1
    error('use only 1 test case')
end

%% sanity check
if isShear == 1
    test = "Shear Profile";
elseif isTensile == 1
    test = "Tensile Profile";
elseif isCompressive == 1
    test = "Compressive Profile";
end

%% columns in your stress-strain data file (i.e. id type x y z sigX sigY sigXY)
columns = 7;
skipROW = 1; % headerline in your data file

%% column values for plotting stress-strain plots
strainCol = 1;
stressXYCol = 4;

%% call function to plot embellished stress-strain plots
for ii=1:length(files)
    hold on
    [x,y,p1,p2,v] = shearPlot(files(ii),columns,skipROW,strainCol,stressXYCol,test);
end

%% Maximum strength and strain at that strength
MAXY = max(y);
failStrn = x(y == MAXY);
failStrnPercentage = failStrn*100;

%% switches for embellishments
isEmbellished = 01;
isMultiSlopes = 01;
strStart = 0.1; %% in percentage
strEnd = 1.0;    %% in percentage

if isEmbellished == true
    if isMultiSlopes == 1
        noSlopes = 4;
        strRange = (strStart:(strEnd-strStart)/noSlopes:strEnd);
        strRange = (strRange)./100;
        
        for g=1:length(strRange)-1
            
            %% select range for slope drawing
            startX = strRange(g);
            endX = strRange(g+1);
            hold on
            
            %% toughness (need to change for ductile materials)
            areaPoints = find(y==MAXY);
            hold on
            areaValue = trapz(x(1:areaPoints),v(1:areaPoints));
            areaSS = area(x(1:areaPoints),v(1:areaPoints),'LineStyle','none','FaceColor',[0.7 0.7 0.7],'FaceAlpha',0.20);
            
            %% modulus (change x1, x2)
            x1 = (find(x>(startX*0.95) & x<(startX*1.005)));
            x2 = (find(x>(endX*0.95) & x<(endX*1.005)));
            subX = x(x1:x2);
            subY = v(x1:x2);
            
            %% modulus slope(s)
            app=polyfit(subX,subY,1);
            slopes(g,1) = app(1);
            
            %% draw lines
            subX = linspace(startX,endX);
            plot(subX, app(1).*subX + app(2),'-','LineWidth',3);
 
            %% annotation
            annotation(gcf,'textbox',...
                [0.565555555555555 0.475783974929138 0.303333324514054 0.105691054106866],...
                'String',sprintf('Toughness, U_T: %.2f GPa\n Shear Modulus, G: %0.2f GPa',areaValue,app(1)),...
                'LineWidth',2,...
                'FontWeight','bold',...
                'FontSize',22,...
                'FontName','Garamond',...
                'BackgroundColor',[0.901960784313726 0.901960784313726 0.901960784313726]);
                        
        end
        meanSlope = mean(slopes);
    elseif isMultiSlopes == 0
        
        %% convert from percentage to decimal
        strStart = strStart/100; %% in decimal
        strEnd = strEnd/100;    %% in decimal
        hold on
        
        %% toughness (need to change for ductile materials)
        areaPoints = find(y==MAXY);
        areaValue = trapz(x(1:areaPoints),v(1:areaPoints));
        areaSS = area(x(1:areaPoints),v(1:areaPoints),'LineStyle','none','FaceColor',[0.7 0.7 0.7],'FaceAlpha',0.20);
        
        %% modulus (change x1, x2)
        x1 = (find(x>(strStart*0.95) & x<(strStart*1.005)));
        x2 = (find(x>(strEnd*0.95) & x<(strEnd*1.005)));
        subX = x(x1:x2);
        subY = v(x1:x2);
        
        %% modulus slope
        app = polyfit(subX,subY,1);
        
        %% draw lines
        subX = linspace(strStart,strEnd);
        plot(subX, app(1).*subX + app(2),'r-','LineWidth',2);
        
        %% annotation box
        annotation(gcf,'textbox',...
            [0.565555555555555 0.475783974929138 0.303333324514054 0.105691054106866],...
            'String',sprintf('Toughness, U_T: %.2f GPa\n Shear Modulus, G: %0.2f GPa',areaValue,app(1)),...
            'LineWidth',2,...
            'FontWeight','bold',...
            'FontSize',22,...
            'FontName','Garamond',...
            'BackgroundColor',[0.901960784313726 0.901960784313726 0.901960784313726]);
                
    end
end

legend([p1],'AB-stacked RD-IBG, f_{sp^{3}} = 15.00%','Location','southeast',...
    'Position',[0.143950626246722 0.845141308555943 0.338518509555746 0.0499419266407775],...
    'Color',[0.941176470588235 0.941176470588235 0.941176470588235]);

set(gcf,'units','points','position',[100,100,1024,700])

%% additional features for rearranging plots
% ch = get(gca,'Children');
% set(gca,'Children',[ ch(1) ch(3) ch(5) ch(6) ch(7) ch(10) ch(11) ch(8) ch(2) ch(4) ch(9)])

function [x,y,p1,p2,v] = shearPlot(file,columns,skipROW,strainCol,stressXYCol,test)

s = readtextfile(file,columns,skipROW,' ','#');

%% strain = 1st column and XY_stress = 4th column
x = s{1,strainCol};
y = s{1,stressXYCol};

%% %% show strain as percentage or fraction (uncomment if you need)
% % if showPercentage == 1
% %     x=x.*100;
% % end

if strcmpi(test,"Shear Profile")
    p1 = plot(x,y,'--b','DisplayName','Shear Profile','LineWidth',2,...
        'MarkerSize',6,...
        'MarkerEdgeColor','b',...
        'MarkerFaceColor', 'b' );
    
elseif strcmpi(test,"Tensile Profile")
    p1 = plot(x,y,'--b','DisplayName','Tensile Profile','LineWidth',2,...
        'MarkerSize',6,...
        'MarkerEdgeColor','b',...
        'MarkerFaceColor', 'b' );
    
elseif strcmpi(test,"Compressive Profile")
    p1 = plot(x,y,'--b','DisplayName','Compressive Profile','LineWidth',2,...
        'MarkerSize',6,...
        'MarkerEdgeColor','b',...
        'MarkerFaceColor', 'b' );
end

%% %% uncomment to see intermediate markers over the whole trend
% % p2=plot(x(1:25:end)*100,y(1:25:end),'o','DisplayName','[]','LineWidth',1.0,...
% %     'MarkerSize',2,...
% %     'MarkerEdgeColor','b',...
% %     'MarkerFaceColor', 'none' );

%% moving average
v = movmean(y,100);
p2 = plot(x,v,'r','DisplayName','Moving Average Profile','LineWidth',2,...
    'MarkerSize',6,...
    'MarkerEdgeColor','r',...
    'MarkerFaceColor', 'none' );

%% plotting features
box on
grid on;
set(gca,'FontName','Garamond','FontSize',24,'FontWeight','bold',...
    'LineWidth',2,'XMinorTick','off',...
    'YMinorTick','off','GridAlpha',0.07,...
    'GridLineStyle','--','LineWidth',2);

%% labels (change xy, x, y as you need)
if strcmpi(test,"Shear Profile")
    ylabel('Shear Stress, \tau_{xy} (GPa)',...
        'FontName','Garamond','FontSize',24)
    xlabel('Shear Strain, \epsilon_{xy}',...
        'FontName','Garamond','FontSize',24);
    
    yline(max(y),'Parent',gca,'Color',[0.64,0.08,0.18],'FontWeight','bold','LineStyle',...
        '--',...
        'LineWidth',1.5,...
        'FontName','Garamond',...
        'FontSize',18,...
        'Label',{sprintf('Max \\tau_{xy} = %.2f GPa\n Max \\epsilon_{xy} = %.2f%%',max(y),x(y==max(y))*100)});
    
elseif strcmpi(test,"Tensile Profile")
    ylabel('Tensile Stress, \sigma_{x} (GPa)',...
        'FontName','Garamond','FontSize',24)
    xlabel('Tensile Strain, \epsilon_{x}',...
        'FontName','Garamond','FontSize',24);
    
    yline(max(y),'Parent',gca,'Color',[0.64,0.08,0.18],'FontWeight','bold','LineStyle',...
        '--',...
        'LineWidth',1.5,...
        'FontName','Garamond',...
        'FontSize',18,...
        'Label',{sprintf('Max \\sigma_{x} = %.2f GPa\n Max \\epsilon_{x} = %.2f%%',max(y),x(y==max(y))*100)});
    
elseif strcmpi(test,"Compressive Profile")
    ylabel('Compressive Stress, \sigma_{y} (GPa)',...
        'FontName','Garamond','FontSize',24)
    xlabel('Compressive Strain, \epsilon_{y}',...
        'FontName','Garamond','FontSize',24);
    
    yline(max(y),'Parent',gca,'Color',[0.64,0.08,0.18],'FontWeight','bold','LineStyle',...
        '--',...
        'LineWidth',1.5,...
        'FontName','Garamond',...
        'FontSize',18,...
        'Label',{sprintf('Max \\sigma_{y} = %.2f GPa\n Max \\epsilon_{y} = %.2f%%',max(y),x(y==max(y))*100)});
end

ylim([0, max(y)+4])

end