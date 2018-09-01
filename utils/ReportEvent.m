% ------------------------------------------------------------------------------
% Function     : ReportEvent
%
% Purpose      : Provide common way to get messages to user.
%                  Note: Event Message Format
%                         '<Event Type>:<Function Name>[<line#] <Message>
%                  Note: Event Types
%                          1 - Error event
%                          2 - Warning event
%                          3 - Info event
%           
% Input        : eventType - Type of event to process
%                msgDisp   - Message string to display (Command Window)
%
% Output       : none
%
% Assumptions  : none
%
% Dependencies : none
%
% Example Use  : ReportEvent(2,'Danger Will Robinson!');
% ------------------------------------------------------------------------------
function ReportEvent(eventType, msgDisp)
 
  %% Init Variables
  eventStr = ['ERROR : '; ...
              'WARN  : '; ...
              'INFO  : '; ...
              'CRASH : '];
 
   
 
  %% Get Calling Stack Info
  st = dbstack('-completenames');
 
 
 
  %% Verify Function Usage
  if (2 ~= nargin)
    str = [eventStr(1) st(2).name ' Invalid Function Usage'];
    disp(str);
    return;
  end
 
  %% Output the event message
  %    - Form the message string
  %      For 'Info' messagesdo not add the file and line number message source
  %    - Send to appropriate output
  %-----------------------------------------------------------------------------
   
  % form the time stamp
  dStr = sprintf('%04d-%02d-%02d %02.0f:%02.0f:%02.0f : ', clock());
   
  % form the msg string
  strDisp = [dStr eventStr(eventType,:) msgDisp ' [' st(2).name ' - ' num2str(st(2).line) ']'];

  % if the stack shows a file exists for the calling function then create
  % the URL string for dispaly
  if (exist(st(2).file,'file')==2)
    urlStr = sprintf('<a href="matlab:opentoline(''%s'',%d)">%s</a>', ...
                     st(2).file, ...
                     st(2).line, ...
                     st(2).name);

    strDisp = [dStr eventStr(eventType,:) msgDisp '[' urlStr ' - Line ' num2str(st(2).line) ']']; %#ok<AGROW>
  end
 
   
  % Display to Command Line
  disp(strDisp);
 
  return;