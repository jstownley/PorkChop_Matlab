% ------------------------------------------------------------------------------
% Function     : CalculateOrbitalTrajectory
%
% Purpose      : Integrates the state vector of a body in the solar system
%                  for a given length of time
%
% Input        : rIn   - Initial radius vector (km)
%                vIn   - Initial velocity vector (km/s)
%                tSpan - Span of time over which to integrate. Can be
%                          either a number of seconds or '-1' for the case
%                          of integrating one complete orbit
%
% Output       : rOut - A Nx3 matrix of radius vector ordinates (km) of the
%                         orbital trajectory, where N is the number of
%                         hours of flight time
%
% Assumptions  : 1. Units are km, km/s
%                2. 2-body dynamics are sufficiently accurate
%
% Dependencies : ReportEvent, GetMuSun
%
% Example Use  : trajectory = CalculateOrbitalTrajectory(r0,v0,timeOfFlight);
%                earthOrbit = CalculateOrbitalTrajectory(rEarth,vEarth,-1);
% ------------------------------------------------------------------------------
function rOut = CalculateOrbitalTrajectory(rIn,vIn,tSpan)
      
  % Initialize output
  rOut = [];
  
  % Check inputs
  if (false == isnumeric(rIn))
    ReportEvent(1,'Input ''rIn'' must be a 3-element numeric vector')
    return;
  elseif (3 ~= numel(rIn))
    ReportEvent(1,'Input ''rIn'' must be a 3-element numeric vector')
    return;
  end
  
  if (false == isnumeric(vIn))
    ReportEvent(1,'Input ''vIn'' must be a 3-element numeric vector')
    return;
  elseif (3 ~= numel(vIn))
    ReportEvent(1,'Input ''vIn'' must be a 3-element numeric vector')
    return;
  end
  
  if (false == isnumeric(tSpan))
    ReportEvent(1,'Input ''tSpan'' must be a scalar number of seconds or ''-1''')
    return;
  elseif (1 ~= numel(tSpan))
    ReportEvent(1,'Input ''tSpan'' must be a scalar number of seconds or ''-1''')
    return;
  end
  
  % Get the orbital period (in seconds) if tSpan is -1
  if (-1 == tSpan)
    tSpan = GetPeriodFromState(rIn,vIn);
  end
  
  % Set/initialize integration variables
  dt = 3600;
  tSpan = ceil(tSpan/dt);
  rOut = NaN(tSpan + 1,3);
  rOut(1,:) = (rIn(:))';
  
  % Integrate 2-body trajectory
  muSun = GetMuSun();
  v = vIn(:);
  r = rIn(:);
  for dd = 2:tSpan+1
    r = r + v*dt;
    v = v - muSun/norm(r)^3.*r.*dt;
    rOut(dd,:) = r';
  end
      
  return
  
  
%% GetPeriodFromState
function t = GetPeriodFromState(r,v)
  
  muSun = GetMuSun;
  
  % Find enough orbital elements to get the semi-major axis
  h = cross(r,v);
  e = 1/muSun*((norm(v)^2 - muSun/norm(r))*r - dot(r,v)*v);
  p = norm(h)^2/muSun;
  a = p/(1-norm(e)^2);
  
  % Calculate the period
  t = 2*pi/sqrt(muSun) * a^1.5;
  
  return;