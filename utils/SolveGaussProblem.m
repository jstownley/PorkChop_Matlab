% ------------------------------------------------------------------------------
% Function     : SolveGaussProblem
%
% Purpose      : Solve Gauss' problem via the Universal Variables method
%
% Input        : origin - Structure containing state vectors for the origin
%                         body. Struct has the fields:
%                           .name    - Name of the body
%                           .jDate   - Nx1 vector of J2000 Julian dates
%                           .calDate - Nx1 vector of numeric calendar dates
%                                       (default Matlab datenum scheme)
%                           .r       - Nx3 matrix of radius vector ordinates
%                           .v       - Nx3 matrix of velocity vector 
%                                       ordinates
%                originDateRange - 2-element numeric vector of start and
%                                  stop dates over which to solve Gauss'
%                                  problem
%                destination     - Structure containing state vectors for 
%                                  the destination body. Struct contains 
%                                  same fields as those for 'origin' body
%                destinationDateRange - 2-element numeric vector of start
%                                       and stop dates over which to solve
%                                       Gauss' problem
%
% Output       : solution - Structure containing solution data for Gauss'
%                           problem. Struct contains the fields:
%                             .oDates     - Vector of origin body calendar 
%                                           dates contained in the solution
%                             .dDates     - Vector of destination body
%                                           calendar dates contained in the
%                                           solution 
%                             .v1         - DxOx3 matrix of initial
%                                           velocities of transfer orbit,
%                                           where D is the number of
%                                           destination dates and O is the
%                                           number of origin dates in the
%                                           solution
%                             .normBodyV1 - DxO matrix of norms of the
%                                           body-centric initial velocities
%                             .C31        - DxO matrix of launch C3
%                             .v2         - DxOx3 matrix of final
%                                           velocities of transfer orbit
%                             .normBodyV2 - DxO matrix of norms of the
%                                           body-centric final velocities
%                             .C32        - DxO matrix of arrival C3
%                             .r1         - DxOx3 matrix of initial radius
%                                           vector ordinates
%                             .r2         - DxOx3 matrix of final radius
%                                           vector ordinates
%                             .deltaT     - DxO matrix of flight times
%
% Assumptions  : 1. Units are in km, km/s
%                2. Origin and destination body data is described in the
%                   helio-centric (Sun center) J2000 reference frame
%
% Dependencies : ReportEvent, GetMuSun
%
% Example Use  : soln = SolveGaussProblem(earth,launchDates,mars,arrivalDates);
% ------------------------------------------------------------------------------
function solution = SolveGaussProblem(origin,originDateRange,destination,destinationDateRange)
  
  % Define some needed data
  muSun = GetMuSun();
  
  rO = origin.r;
  vO = origin.v;
  jDateO = origin.jDate;
  calDateO = origin.calDate;
  normRO = sqrt(sum(rO.^2,2));
  clear origin
  
  rD = destination.r;
  vD = destination.v;
  jDateD = destination.jDate;
  calDateD = destination.calDate;
  normRD = sqrt(sum(rD.^2,2));
  clear destination
  
  % Limit the data by the input date ranges
  oStart = originDateRange(1);
  oStop  = originDateRange(2);
  
  rO = rO(calDateO >= oStart & calDateO <= oStop,:);
  vO = vO(calDateO >= oStart & calDateO <= oStop,:);
  jDateO = jDateO(calDateO >= oStart & calDateO <= oStop);
  normRO = normRO(calDateO >= oStart & calDateO <= oStop);
  calDateO = calDateO(calDateO >= oStart & calDateO <= oStop);
  
  dStart = destinationDateRange(1);
  dStop  = destinationDateRange(2);
  
  rD = rD(calDateD >= dStart & calDateD <= dStop,:);
  vD = vD(calDateD >= dStart & calDateD <= dStop,:);
  jDateD = jDateD(calDateD >= dStart & calDateD <= dStop);
  normRD = normRD(calDateD >= dStart & calDateD <= dStop);
  calDateD = calDateD(calDateD >= dStart & calDateD <= dStop);
  
  % Initialize output
  solution.v1 = NaN(length(jDateD),length(jDateO),3);
  solution.normBodyV1 = NaN(length(jDateD),length(jDateO));
  solution.C31 = NaN(length(jDateD),length(jDateO));
  solution.v2 = NaN(length(jDateD),length(jDateO),3);
  solution.normBodyV2 = NaN(length(jDateD),length(jDateO));
  solution.C32 = NaN(length(jDateD),length(jDateO));
  
  solution.r1 = NaN(length(jDateD),length(jDateO),3);
  solution.r2 = NaN(length(jDateD),length(jDateO),3);
  solution.deltaT = NaN(length(jDateD),length(jDateO));
  
  solution.oDates = calDateO;
  solution.dDates = calDateD;
  
  % Solve Gauss' problem for each potential transfer
  maxIterations = 5000;
  for iO = 1:length(jDateO)
    for iD = 1:length(jDateD)
      
      targetDeltaT = (jDateD(iD) - jDateO(iO)) * 3600*24;
      
      % Find the angle between the radii
      deltaNu = acos(dot(rO(iO,:),rD(iD,:),2)/normRO(iO)/normRD(iD));
      cp = cross(rO(iO,:),rD(iD,:),2);
      if (0 > cp(3))
        deltaNu = 2*pi - deltaNu;
      end
      DM = sign(pi - deltaNu);
      
      % Skip this flight if the flight time is zero or less
      if (0 >= targetDeltaT)
        continue;
      end
      
      % Skip this flight if the origin and the destination are colocated
      if (3 == sum(rD(iD,:) == rO(iO,:)))
        continue;
      end
      
      % Calculate Universal Variable (UV) constant A
      A = DM*sqrt(normRO(iO) * normRD(iD) * (1 + cos(deltaNu)));
      
      % Iterate UV z until flight times converge within tolerance
      tol = 1e-4;
      z = 0;
      deltaT = 2*targetDeltaT;
      cc = 0;
      while ( (abs(deltaT - targetDeltaT)/targetDeltaT > tol) && (maxIterations > cc) )
        
        % Calculate C, S, Cprime, and Sprime given z
        if (-.01 > z)
          C = (1 - cosh(sqrt(-z)))/z;
          S = (sinh(sqrt(-z)) - sqrt(-z))/sqrt((-z)^3);
        elseif (.01 < z)
          C = (1 - cos(sqrt(z)))/z;
          S = (sqrt(z) - sin(sqrt(z)))/sqrt(z^3);
        else
          C = 1/factorial(2) - z/factorial(4) + z^2/factorial(6) - z^3/factorial(8);
          S = 1/factorial(3) - z/factorial(5) + z^2/factorial(7) - z^3/factorial(9);
        end
        
        % Calculate y, x, and the next deltaT given z
        y = normRO(iO) + normRD(iD) - A * (1 - z*S) / sqrt(C);
        if (0 > y)
          z = z + 1;
          continue;
        end
        x = sqrt(y/C);
        deltaT = (x^3*S + A*sqrt(y))/sqrt(muSun);
        
        % Calculate next z and go again
        if (0 == cc)
          zLast = 0;
          z = 2*pi^2;
        else
          zLast = z;
          z = z + (deltaZ/(deltaT-deltaTLast))*(targetDeltaT - deltaT);
          % Manually enforce the single-orbit asymptote
          if (4*pi^2 < z)
            z = 4*pi^2 - .1;
            deltaT = targetDeltaT * 1e6;
          end
        end
        deltaZ = z - zLast;
        deltaTLast = deltaT;
        
        cc = cc + 1;
        
      end
      
      % Now, calculate f, g, and gDot, and the trajectory velocities
      if (maxIterations > cc)
        f = 1 - y/normRO(iO);
        g = A*sqrt(y/muSun);
        gDot = 1 - y/normRD(iD);
        v1 = (rD(iD,:) - f*rO(iO,:))/g;
        v2 = (gDot*rD(iD,:) - rO(iO))/g;

        solution.v1(iD,iO,1:3) = v1;
        solution.normBodyV1(iD,iO) = sqrt(sum((v1-vO(iO,:)).^2,2));
        solution.C31(iD,iO) = solution.normBodyV1(iD,iO)^2;
        solution.v2(iD,iO,1:3) = v2;
        solution.normBodyV2(iD,iO) = sqrt(sum((v2-vD(iD,:)).^2,2));
        solution.C32(iD,iO) = solution.normBodyV2(iD,iO)^2;
      end

      solution.r1(iD,iO,1:3) = rO(iO,:);
      solution.r2(iD,iO,1:3) = rD(iD,:);
      solution.deltaT(iD,iO) = deltaT;
      
    end
  end
  
  return;