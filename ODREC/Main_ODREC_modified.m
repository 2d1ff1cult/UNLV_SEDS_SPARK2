%% Inputs
% An example main code to use ODREC (One Dimensional REgenerative Cooling
% analysis)
% Yiğithan Mehmet Köse
% September 2023

clc
clear
close all

% Load properties data
% load('Methane.mat')
% l_prop = CH4_liquid;
% s_prop = CH4_saturated;
% v_prop = CH4_vapor;

%load('Propane.mat')
%l_prop = C3H8_liquid;
%s_prop = C3H8_saturated;
%v_prop = C3H8_vapor;

load('Kerosene_liquid.mat')
load('Kerosene_saturated.mat')
load('Kerosene_vapor.mat')
l_prop = Kerosene_liquid;
s_prop = Kerosene_saturated;
v_prop = Kerosene_vapor;

% load('Oxygen.mat')
%l_prop = O2_liquid;
%s_prop = O2_saturated;
%v_prop = O2_vapor;

% General Engine Properties
Fuel = 'Jet-A(L)';          % fuel name Kerosene
Oxidizer = 'O2';            % oxidizer name Kerosene
OF = 1.7;                   % oxidizer/fuel mixture ratio
Pc = 35e5;                  % combustion chamber pressure, Pa
Ft = 45e2;                  % thrust, N
P_ambient = 89e3;            % ambient pressure, Pa
T_f_c = 298;            % fuel temperature entering combustion chamber, K
T_o_c = 298;             % oxidizer temperature entering combustion chamber, K

% Engine Wall Material
K_wall = 365;               % engine wall thermal conductivity, W/mK
eps = 6.3e-6;               % cooling channel roughness, m

% Coolant General Properties
i_c = 1;                    % coolant index, 1:fuel, 2:oxidizer
T_c_i = 298;                % coolant inlet temperature, K
P_c_i = 38e5;               % coolant inlet pressure, Pa

% Cooling Channel Properties
N = 60;                     % number of cooling channels
w = 0.001;                  % cooling channel base width, m
h = 0.005;                  % cooling channel height, m
y = 0.005;                  % thickness at channel base, m

% Coolant Vapor Table Specifications
P_1 = 10e5;                 % pressure in first table of vapor properties, Kerosene, Pa
P_l = 60e5;                 % pressure in last table of vapor properties, Kerosene, Pa
N_p = 6;                    % number of tables of vapor properties

% Thrust Chamber Profile
load('geom.mat')            % chamber geometry matrix
L_star = 0.98;              % characteristic length, m
theta_n = 20;               % bell nozzle entry angle, deg
theta_e = 8;                % bell nozzle exit angle, deg
N1 = 30;                    % thrust chamber cylindrical part number of divisions
N2 = 16;                    % thrust chamber round conical section number of divisions
N3 = 16;                    % thrust chamber throat entrance number of divisions
N4 = 16;                    % thrust chamber throat exit number of divisions
N5 = 30;                    % thrust chamber bell curve nozzle number of divisions

%% Initialize the analysis

inputs.fuel = Fuel;
inputs.oxidizer = Oxidizer;
inputs.T_o_c = T_o_c;
inputs.T_f_c = T_f_c;
inputs.discretization = [N1 N2 N3 N4 N5];
inputs.eps = eps;
inputs.i_c = i_c;
inputs.y = y;
inputs.L_star = L_star;
inputs.theta_n = theta_n;
inputs.theta_e = theta_e;
inputs.P_c_i = P_c_i;
inputs.T_c_i = T_c_i;
inputs.k_wall = K_wall;
inputs.P_1 = P_1;
inputs.P_l = P_l;
inputs.N_p = N_p;

inputs.Pc = Pc;
inputs.F = Ft;
inputs.OF = OF;
inputs.Pe = P_ambient;
inputs.N = N;
inputs.w = w;
inputs.h = h;

%% Analysis

Results = ODREC(inputs,l_prop,s_prop,v_prop,geom);
Results = Results.Thermal_Analysis(inputs);
Tw = Results.T_w;

%% Plots

% Figure 1: Wall Temperature, Engine Contour, and Wall Heat Flux
figure(1)
var = myaxisc(1, 3);
p(1) = plot(var.p{1},100*Results.X,Results.T_w,'Color',[0,0,1]);
p(2) = plot(var.p{2},100*Results.X,100*Results.Z,'Color',[.7 .7 .7],'LineWidth',3);
p(3) = plot(var.p{3},100*Results.X,Results.q/1e6,'Color','r');
var.xlim([-17,4]);
var.ylabel(1,'Wall Temperature (K)');
var.ylabel(2,'Radius (cm)');
var.ylabel(3,'Wall Heat Flux (MW/m^2)');
var.xlabel('x (cm)');
var.ylim(1,[400,1000]);
var.ylim(2,[0,20]); % Ensure engine contour is visible
var.ylim(3,[0,45]);
var.ycolor(1,[0,0,1]);
var.ycolor(2,[.5 .5 .5]);
var.ycolor(3,'r');
leg = legend(var.legendtarget,p,...
    'Wall Temperature','Engine Contour','Wall Heat Flux');
set(leg,'Color','W')
set(gcf,'color','W')
set(gca,'fontname','times')
var.fontsize(9)

% Figure 2: Coolant state in channels and Saturation line
figure(2)
plot(Results.Tem_c,Results.p_c/1e5,'>','MarkerSize',5,...
    'MarkerEdgeColor','blue',...
    'MarkerFaceColor',[1 .6 .6])
hold on
plot(s_prop(:,1),s_prop(:,2)/1e5,'k')
xlabel('Temperature (K)')
ylabel('Pressure (bar)')
set(gcf,'color','W')
set(gca,'fontname','times')
legend('Coolant state in channels','Saturation line')

% Figure 3: Coolant Temperature, Engine Contour, Vapor Fraction, and Coolant Pressure
figure(3)
var = myaxisc(3, 4);
p(1) = plot(var.p{1},100*Results.X,Results.Tem_c,'v-','Color',[0.4660 0.6740 0.1880],'MarkerSize',5,'MarkerEdgeColor','[0.4660 0.6740 0.1880]','MarkerFaceColor','green');
p(2) = plot(var.p{2},100*Results.X,100*Results.Z,'Color',[.7 .7 .7],'LineWidth',3);
p(3) = plot(var.p{3},100*Results.X,Results.X_g,'s-','Color','r','MarkerSize',5,'MarkerEdgeColor','red','MarkerFaceColor',[1 .6 .6]);
p(4) = plot(var.p{4},100*Results.X,Results.p_c/1e5,'^-','Color','blue','MarkerSize',5,'MarkerEdgeColor','blue','MarkerFaceColor',[0.3010 0.7450 0.9330]);

var.xlim([-17,4]);
var.ylabel(1,'Coolant Temperature (K)');
var.ylabel(2,'Radius (cm)');
var.ylabel(3,'Vapor Fraction');
var.ylabel(4,'Coolant Pressure (bar)');
var.xlabel('x (cm)');
var.ylim(1,[100,270]);
var.ylim(2,[0,20]);
var.ylim(3,[-0.05,1.05]);
var.ylim(4,[29,42]);

var.ycolor(1,[0.4660 0.6740 0.1880]);
var.ycolor(2,[.4 .4 .4]);
var.ycolor(3,'r');
var.ycolor(4,'b');

leg = legend(var.legendtarget,p,...
    'Temperature','Engine Contour','Vapor Fraction','Pressure');
set(leg,'Color','W')
set(gcf,'color','W')
set(gca,'fontname','times')
var.fontsize(9)

% Define a function to create custom axes
function var = myaxisc(figNum, numSubplots)
    figure(figNum);
    var.p = arrayfun(@(x) subplot(numSubplots,1,x), 1:numSubplots, 'UniformOutput', false);
    var.legendtarget = var.p{1}; % Choose where the legend should be placed
    var.xlim = @(lims) cellfun(@(ax) xlim(ax, lims), var.p, 'UniformOutput', false);
    var.ylim = @(i, lims) ylim(var.p{i}, lims);
    var.ylabel = @(i, label) ylabel(var.p{i}, label);
    var.xlabel = @(label) xlabel(var.p{end}, label);
    var.ycolor = @(i, color) set(var.p{i}, 'YColor', color);
    var.fontsize = @(size) set(findall(gcf, '-property', 'FontSize'), 'FontSize', size);
end
