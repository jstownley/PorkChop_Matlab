% ------------------------------------------------------------------------------
% Function     : LoadData
%
% Purpose      : Load a data file of JPL Horizons data
%
% Input        : fileName - Absolute path to a data file
%
% Output       : err  - Error flag (0=no error, 1=error)
%                data - Data structure containing the fields:
%                         .name    - Name of the body
%                         .jDate   - Nx1 vector of J2000 Julian dates
%                         .calDate - Nx1 vector of numeric calendar dates
%                                     (default Matlab datenum scheme)
%                         .r       - Nx3 matrix of radius vector ordinates
%                         .v       - Nx3 matrix of velocity vector 
%                                     ordinates
%
% Assumptions  : None
%
% Dependencies : ReportEvent, ParseHorizonsData
%
% Example Use  : [err,earthData] = LoadData('C:\data\earth.txt');
% ------------------------------------------------------------------------------
function [err,data] = LoadData(fileName)

  % Initialize the output
  err  = 1;
  data = [];

  
  % Check input
  if (false == ischar(fileName))
    ReportEvent(1,'Input must be a string to an existing file')
    return;
  elseif (2 ~= exist(fileName,'file'))
    ReportEvent(1,'Input must be a string to an existing file')
    return;
  end
  
  
  % Open the text file
  fid = fopen(fileName,'r');
  if (-1 == fid)
    ReportEvent(1,sprintf('Unable to load file: %s',fileName));
    return;
  end
  
  % Read the data
  data = fread(fid,'*char')';
  fclose(fid);
  
  
  % Parse origin data
  [err,data] = ParseHorizonsData(data);
  if (true == err)
    ReportEvent(1,sprintf('Unable to parse JPL Horizons data from file: %s',fileName));
    return;
  end
  
  % If we've made it this far, there have been no errors
  err = 0;
  
  return;