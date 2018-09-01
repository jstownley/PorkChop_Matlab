% ------------------------------------------------------------------------------
% Function     : ParseHorizonsData
%
% Purpose      : Parses data from the JPL Horizons database into body name,
%                  Julian and (numeric) calendar dates, and radius and
%                  velocity vectors
%
% Input        : data - JPL Horizons database data
%
% Output       : err  - Error flag (0=no error, 1=error)
%                body - Structure containing the parsed Horizons data.
%                       Contains the fields:
%                         .name    - Name of the body
%                         .jDate   - Nx1 vector of J2000 Julian dates
%                         .calDate - Nx1 vector of numeric calendar dates
%                                     (default Matlab datenum scheme)
%                         .r       - Nx3 matrix of radius vector ordinates
%                         .v       - Nx3 matrix of velocity vector 
%                                     ordinates
%
% Assumptions  : 1. Input data is a vector of characters
%                2. Format of the input data is the unmodified "State 
%                   Vector" format retrieved via the Horizons web interface
%
% Dependencies : ReportEvent
%
% Example Use  : [err,earth] = ParseHorizonsData(earthDataStream);
% ------------------------------------------------------------------------------
function [err,body] = ParseHorizonsData(data)
  
  % Initialize the outputs
  err = 1;
  body.name    = '';
  body.jDate   = [];
  body.calDate = [];
  body.r       = [];
  body.v       = [];
  
  % Find the beginning of the ephemeris data, which will be preceded by the
  % string '$$SOE' and split the header from the data
  tagStart = strfind(data,'$$SOE');
  header = data(1:tagStart-1);
  data = data(tagStart+6:end);
  if (true == isempty(data))
    ReportEvent(1,'Unable to locate the start of the ephemeris data');
    return;
  end
  
  % First, search the header info for the name of the body
  expr = 'Revised: \w* \d*, \d*\s*(?<name>\w*)\s*';
  tokenNames = regexp(header,expr,'names');
  body.name = tokenNames.name;
  
  % Next, search the header info for the data column labels and ensure we
  % have the correct format
  expr = 'JDTDB,\s*Calendar Date \(TDB\),\s*X,\s*Y,\s*Z,\s*VX,\s*VY,\s*VZ,\s*LT,\s*RG,\s*RR';
  matches = regexp(header,expr,'match');
  if (true == isempty(matches))
    ReportEvent(1,'Unexpected data column format')
    return;
  end
  
  % Next, read in the data, which should have the column format as follows:
  %  1:  Julian date 
  %  2:  Calendar date
  %  3:  Heliocentric position X-ordinate (km)
  %  4:  Heliocentric position Y-ordinate (km)
  %  5:  Heliocentric position Z-ordinate (km)
  %  6:  Heliocentric velocity X-ordinate (km/s)
  %  7:  Heliocentric velocity Y-ordinate (km/s)
  %  8:  Heliocentric velocity Z-ordinate (km/s)
  %  9:  One-way light travel time (sec)
  %  10: Range (km)
  %  11: Range rate (km/s)
  colFormat = '%f %s %f %f %f %f %f %f %f %f %f';
  tempData = textscan(data,colFormat,'CollectOutput',true,'Delimiter',',');
  
  % Reassign the data to the output struct
  body.jDate = tempData{1};
  body.calDate = cellfun(@(x)datenum(x(6:end-5),'yyyy-mmm-dd HH:MM:SS'),tempData{2});
  body.r = tempData{3}(:,1:3);
  body.v = tempData{3}(:,4:6);
  
  % If we've made it this far, we're good to go
  err = 0;
  
  return;