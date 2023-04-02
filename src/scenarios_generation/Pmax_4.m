
function [] =Pmax_4() % Calculate the maximum power generated by one PV module
q = 1.60218E-19;  %Elementary charge (1.60218E-19 coulombs)
k = 1.38066E-23;  %Boltzmann's constant (1.38066E-23 J/K)
T0 = 25;%Reference temperature (25 deg C)


%% Parameters
% Parameters are different from module to another
% Current module: Canadian Solar CS5P-220M, see Row 124 in the excel sheet of Sandia lab (located in this folder) : SandiaModuleDatabase_20120925
% Or go to  "https://pvpmc.sandia.gov/PVLIB_Matlab_Help/" then go to "pvl_sapmmoduledb"
% or install the PVLIB toolbox at "https://pvpmc.sandia.gov/applications/pv_lib-toolbox/" and see the "Documentation for PV_LIB Toolbox for Matlab"
n=1.4032;
Ns=96;
Imp0=4.5463;
Vmp0=48.3156;
c(1)=1.0128; % C0
c(2)=-0.0128; % C1
c(3)=0.2793; % C2
c(4)=-7.2446; % C3
AlphaImp=1.8100e-04; %almp
BetaVmp_=-0.2355; %BVmpo
mBetaVmp=0; %mBVmp

%% Reading
Ee=csvread('Ee.csv'); % Ee is the Effective irradiance, see POA_2(x) function 
celltemp=csvread('Tcell.csv'); % See Tc_3() function

%% Initialize
Imp=0.*Ee; % Current at the maximum power point 
Vmp=0.*Ee; % Voltage at the maximum power point 
Pmp = 0*Ee; % Power at the maximum power point 
BetaVmp = 0*Ee;
delta = 0*Ee;

%% Calculations
% Install PV_LIB Toolbox at "https://pvpmc.sandia.gov/applications/" then go to "pvl_sapm" function

Ee(Ee<0) = 0;
filter = (Ee >= 1E-3);% Don't perform SAPM on Ee values < 1E-3
Imp(filter) = Imp0.*(c(1).* Ee(filter) + c(2)*(Ee(filter).^2)).*(1 + AlphaImp .* (celltemp(filter) - T0));
delta(filter) = n .* k .* (celltemp(filter) + 273.15) ./ q;
BetaVmp(filter) = BetaVmp_ + mBetaVmp .* (1-Ee(filter));
Vmp(filter) = (Vmp0 +c(3) .* Ns .* delta(filter) .* log(Ee(filter))+ c(4) .*Ns .* (delta(filter) .* log(Ee(filter))).^2 + BetaVmp(filter) .* (celltemp(filter) - T0));
Pmp(filter)=Imp(filter).*Vmp(filter);

csvwrite("Pmax.csv",Pmp);
end
% Pmp(isnan(Pmp))=0;