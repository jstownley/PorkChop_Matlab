% ------------------------------------------------------------------------------
% Function     : PorkChop
%
% Purpose      : Creates and maintains the GUI for the Pork Chop Plots
%                tool.
%
% Input        : None
%
% Output       : None
%
% Assumptions  : None
%
% Dependencies : ReportEvent
%
% Example Use  : PorkChop();
% ------------------------------------------------------------------------------
function PorkChop()

  % Create GUI figure
  width = 1200;
  height = 1000;
  h = figure('position',[0 0 width height]);
  movegui(h,'center');
  
  % Define data model
  bodyStruct = struct('name','','file','','r',[],'v',[],'jDate',[],...
                      'calDate',[],'start',[],'stop',[]);
  gui.vars.orig = bodyStruct;
  gui.vars.dest = bodyStruct;
  gui.vars.soln = struct('v1',[],'normBodyV1',[],'C31',[],...
                         'v2',[],'normBodyV2',[],'C32',[],...
                         'r1',[],'r2',[],'deltaT',[],...
                         'oDates',[],'dDates',[]);
  gui.vars.contourChoices = {'Launch Velocity', 'normBodyV1'; ...
                             'Launch C3', 'C31'; ...
                             'Arrival Velocity', 'normBodyV2'; ...
                             'Arrival C3', 'C32'};
  gui.vars.contourLevels = (0:5);
  gui.vars.contourType   = gui.vars.contourChoices{1,2};
  gui.vars.singleLaunch  = [];
  gui.vars.singleArrive  = [];
  
  % Define dimension/position variables
  hPad = .01;
  wPad = height/width * hPad;
  hMargin = 3*hPad;
  wMargin = 3*wPad;
  
  labelWidth = .15;
  labelHeight = .02;
  optHeight = .03;
  shortEditWidth = .1;
  longEditWidth = .2;
  selectWidth = .12;
  
  cols = 2;
  col1X = wMargin;
  col2X = 1/cols + wMargin/2;
  
  panWidth = 1 - 10*wMargin;
  panHeight = .15;
  plotHeight = 1 - 2*panHeight - 4*hMargin;
  plotWidth = plotHeight * height/width;
  btnWidth = .07;
  btnHeight = .04;
  runBtnHeight = .06;
  
  
  % Add GUI features
  
  topLine = 1 - hMargin;
  
  % Data source panel
  deltaY = panHeight;
  deltaX = panWidth;
  ptX = (1 - panWidth)/2;
  ptY = topLine - deltaY;
  gui.parts.srcPanel = uipanel('units','normalized',...
                               'Position',[ptX ptY deltaX deltaY],...
                               'parent',h);
                             
  % Reset the figure background color to match the uipanel
  set(h,'color',get(gui.parts.srcPanel,'backgroundcolor'));
  
  % Determine some in-panel dimensions
  blockWidth = (longEditWidth + btnWidth) / panWidth;
  blockHeight = (2*labelHeight + 2*optHeight + hPad) / panHeight;
  blockOffX = (.5 - blockWidth)/2;
  topLinePanel = blockHeight + (1 - blockHeight)/2;
  
  % Origin source file
  deltaX = labelWidth / panWidth;
  deltaY = labelHeight / panHeight;
  ptX = blockOffX;
  ptY = topLinePanel - deltaY;
  gui.parts.origSrcFileText = uicontrol('Style','text',...
                                        'String','Origin body source file:', ...
                                        'fontsize',12,...
                                        'units','normalized',...
                                        'Position',[ptX ptY deltaX deltaY],...
                                        'parent',gui.parts.srcPanel,...
                                        'horizontalalignment','left');
  deltaX = longEditWidth / panWidth;
  deltaY = optHeight / panHeight;
  ptY = ptY - deltaY;
  gui.parts.origSrcFileEdit = uicontrol('style','edit',...
                                        'string','',...
                                        'fontsize',12,...
                                        'parent',gui.parts.srcPanel,...
                                        'units','normalized',...
                                        'position',[ptX ptY deltaX deltaY],...
                                        'backgroundcolor','white',...
                                        'callback',{@SetStringFieldValue,'originFile'});
  ptX = ptX + deltaX;
  deltaX = btnWidth / panWidth;
  gui.parts.origSrcBrowseButton = uicontrol('style','pushbutton',...
                                            'string','Browse...',...
                                            'fontsize',12,...
                                            'parent',gui.parts.srcPanel,...
                                            'units','normalized',...
                                            'position',[ptX ptY deltaX deltaY],...
                                            'callback',{@BrowseForFile,'origin'});
  
  % Origin source start time
  deltaX = labelWidth / panWidth;
  ptX = blockOffX;
  deltaY = labelHeight / panHeight;
  ptY = ptY - hPad/panHeight - deltaY;
  gui.parts.origStartText = uicontrol('Style','text',...
                                      'String','Start Date (DD-MMM-YYYY):', ...
                                      'fontsize',12,...
                                      'units','normalized',...
                                      'Position',[ptX ptY deltaX deltaY],...
                                      'parent',gui.parts.srcPanel,...
                                      'horizontalalignment','left');
  deltaX = shortEditWidth / panWidth;
  deltaY = optHeight / panHeight;
  ptY = ptY - deltaY;
  gui.parts.origStartEdit = uicontrol('style','edit',...
                                      'string','',...
                                      'fontsize',12,...
                                      'parent',gui.parts.srcPanel,...
                                      'units','normalized',...
                                      'position',[ptX ptY deltaX deltaY],...
                                      'backgroundcolor','white',...
                                      'callback',{@SetStringFieldValue,'originStart'});
  
  % Origin source stop time
  ptX = ptX + deltaX + 2*wMargin;
  ptY = ptY + deltaY;
  deltaY = labelHeight / panHeight;
  deltaX = labelWidth / panWidth;
  gui.parts.origStopText = uicontrol('Style','text',...
                                     'String','Stop Date (DD-MMM-YYYY):', ...
                                     'fontsize',12,...
                                     'units','normalized',...
                                     'Position',[ptX ptY deltaX deltaY],...
                                     'parent',gui.parts.srcPanel,...
                                     'horizontalalignment','left');
  deltaX = shortEditWidth / panWidth;
  deltaY = optHeight / panHeight;
  ptY = ptY - deltaY;
  gui.parts.origStopEdit = uicontrol('style','edit',...
                                     'string','',...
                                     'fontsize',12,...
                                     'parent',gui.parts.srcPanel,...
                                     'units','normalized',...
                                     'position',[ptX ptY deltaX deltaY],...
                                     'backgroundcolor','white',...
                                     'callback',{@SetStringFieldValue,'originStop'});
  
  % Destination source file
  deltaX = labelWidth / panWidth;
  deltaY = labelHeight / panHeight;
  ptX = .5 + blockOffX;
  ptY = topLinePanel - deltaY;
  gui.parts.destSrcFileText = uicontrol('Style','text',...
                                        'String','Destination body source file:', ...
                                        'fontsize',12,...
                                        'units','normalized',...
                                        'Position',[ptX ptY deltaX deltaY],...
                                        'parent',gui.parts.srcPanel,...
                                        'horizontalalignment','left');
  deltaX = longEditWidth / panWidth;
  deltaY = optHeight / panHeight;
  ptY = ptY - deltaY;
  gui.parts.destSrcFileEdit = uicontrol('style','edit',...
                                        'string','',...
                                        'fontsize',12,...
                                        'parent',gui.parts.srcPanel,...
                                        'units','normalized',...
                                        'position',[ptX ptY deltaX deltaY],...
                                        'backgroundcolor','white',...
                                        'callback',{@SetStringFieldValue,'destinationFile'});
  ptX = ptX + deltaX;
  deltaX = btnWidth / panWidth;
  gui.parts.destSrcBrowseButton = uicontrol('style','pushbutton',...
                                            'string','Browse...',...
                                            'fontsize',12,...
                                            'parent',gui.parts.srcPanel,...
                                            'units','normalized',...
                                            'position',[ptX ptY deltaX deltaY],...
                                            'callback',{@BrowseForFile,'destination'});
  
  % Destination source start time
  deltaX = labelWidth / panWidth;
  deltaY = labelHeight / panHeight;
  ptX = .5 + blockOffX;
  ptY = ptY - hPad/panHeight - deltaY;
  gui.parts.destStartText = uicontrol('Style','text',...
                                      'String','Start Date (DD-MMM-YYYY):', ...
                                      'fontsize',12,...
                                      'units','normalized',...
                                      'Position',[ptX ptY deltaX deltaY],...
                                      'parent',gui.parts.srcPanel,...
                                      'horizontalalignment','left');
  deltaX = shortEditWidth / panWidth;
  deltaY = optHeight / panHeight;
  ptY = ptY - deltaY;
  gui.parts.destStartEdit = uicontrol('style','edit',...
                                      'string','',...
                                      'fontsize',12,...
                                      'parent',gui.parts.srcPanel,...
                                      'units','normalized',...
                                      'position',[ptX ptY deltaX deltaY],...
                                      'backgroundcolor','white',...
                                      'callback',{@SetStringFieldValue,'destinationStart'});
  
  % Destination source stop time
  ptX = ptX + deltaX + 2*wMargin;
  ptY = ptY + deltaY;
  deltaX = labelWidth / panWidth;
  deltaY = labelHeight / panHeight;
  gui.parts.destStopText = uicontrol('Style','text',...
                                     'String','Stop Date (DD-MMM-YYYY):', ...
                                     'fontsize',12,...
                                     'units','normalized',...
                                     'Position',[ptX ptY deltaX deltaY],...
                                     'parent',gui.parts.srcPanel,...
                                     'horizontalalignment','left');
  deltaX = shortEditWidth / panWidth;
  deltaY = optHeight / panHeight;
  ptY = ptY - deltaY;
  gui.parts.destStopEdit = uicontrol('style','edit',...
                                     'string','',...
                                     'fontsize',12,...
                                     'parent',gui.parts.srcPanel,...
                                     'units','normalized',...
                                     'position',[ptX ptY deltaX deltaY],...
                                     'backgroundcolor','white',...
                                     'callback',{@SetStringFieldValue,'destinationStop'});
                                      
  % Add countour plot panel
  deltaY = plotHeight;
  deltaX = plotWidth;
  ptX = col1X + (.5 - wMargin/2 - col1X - deltaX)/2;
  ptY = topLine - panHeight - hMargin - deltaY;
  gui.parts.contourPanel = uipanel('units','normalized',...
                                   'Position',[ptX ptY deltaX deltaY],...
                                   'parent',h);
  gui.parts.contourAx = axes('parent',gui.parts.contourPanel);
                                 
  % Define some bottom-row dimensions
  blockWidth = selectWidth + longEditWidth + btnWidth + 2*wMargin;
  blockOffX = (.5 - blockWidth)/2;
  bottomRowTop = ptY - hMargin;
                                      
  % Add contour type dropdown box
  deltaX = labelWidth;
  deltaY = labelHeight;
  ptX = blockOffX;
  ptY = bottomRowTop - deltaY;
  gui.parts.contourTypeText = uicontrol('Style','text',...
                                     'String','Plot Type:', ...
                                     'fontsize',12,...
                                     'units','normalized',...
                                     'Position',[ptX ptY deltaX deltaY],...
                                     'parent',h,...
                                     'horizontalalignment','left');
  deltaY = optHeight;
  ptY = ptY - deltaY;
  deltaX = selectWidth;
  gui.parts.contourList = uicontrol('Style','popupmenu',...
                                    'String',gui.vars.contourChoices(:,1), ...
                                    'fontsize',12,...
                                    'Value',1, ...
                                    'units','normalized',...
                                    'Position',[ptX ptY deltaX deltaY],...
                                    'parent',h,...
                                    'horizontalalignment','left',...
                                    'callback',{@SetContourType});
                                      
  % Add contour levels text box
  ptX = ptX + deltaX + wMargin;
  deltaX = labelWidth;
  deltaY = labelHeight;
  ptY = bottomRowTop - deltaY;
  gui.parts.contourLevelsText = uicontrol('Style','text',...
                                     'String','Contours (Matlab syntax vector):', ...
                                     'fontsize',12,...
                                     'units','normalized',...
                                     'Position',[ptX ptY deltaX deltaY],...
                                     'parent',h,...
                                     'horizontalalignment','left');
  deltaX = longEditWidth;
  deltaY = optHeight;
  ptY = ptY - deltaY;
  gui.parts.contourLevelsEdit = uicontrol('style','edit',...
                                          'string','',...
                                          'fontsize',12,...
                                          'parent',h,...
                                          'units','normalized',...
                                          'position',[ptX ptY deltaX deltaY],...
                                          'backgroundcolor','white',...
                                          'callback',{@SetStringFieldValue,'contourLevels'});
                                           
  % save button
  ptX = ptX + deltaX + wMargin;
  deltaX = btnWidth;
  deltaY = btnHeight;
  ptY = bottomRowTop - deltaY;
  gui.parts.saveContourButton = uicontrol('style','pushbutton',...
                                          'string','Save',...
                                          'fontsize',12,...
                                          'parent',h,...
                                          'units','normalized',...
                                          'position',[ptX ptY deltaX deltaY],...
                                          'callback',{@SavePlot,'contour'});
                                      
  % Add single-trajectory plot panel
  deltaY = plotHeight;
  deltaX = plotWidth;
  ptX = col2X + (1 - wMargin - col2X - deltaX)/2;
  ptY = topLine - panHeight - hMargin - deltaY;
  gui.parts.singlePanel = uipanel('units','normalized',...
                                   'Position',[ptX ptY deltaX deltaY],...
                                   'parent',h);
  gui.parts.singleAx = axes('parent',gui.parts.singlePanel);
                                 
  % Define some bottom-row dimensions
  blockWidth = 2*labelWidth + btnWidth + 2*wMargin;
  blockOffX = (.5 - blockWidth)/2 + .5;
                                      
  % Add single-trajectory launch date
  deltaY = labelHeight;
  deltaX = labelWidth;
  ptX = blockOffX;
  ptY = bottomRowTop - deltaY;
  gui.parts.launchText = uicontrol('Style','text',...
                                    'String','Launch Date (DD-MMM-YYYY):', ...
                                    'fontsize',12,...
                                    'units','normalized',...
                                    'Position',[ptX ptY deltaX deltaY],...
                                    'parent',h,...
                                    'horizontalalignment','left');
  deltaY = optHeight;
  ptY = ptY - deltaY;
  deltaX = shortEditWidth;
  gui.parts.launchEdit = uicontrol('style','edit',...
                                   'string','',...
                                   'fontsize',12,...
                                   'parent',h,...
                                   'units','normalized',...
                                   'position',[ptX ptY deltaX deltaY],...
                                   'backgroundcolor','white',...
                                   'callback',{@SetStringFieldValue,'singleLaunch'});
                                      
  % Add single-trajectory arrival date
  ptX = ptX + labelWidth + wMargin;
  deltaX = labelWidth;
  deltaY = labelHeight;
  ptY = bottomRowTop - deltaY;
  gui.parts.arrivalText = uicontrol('Style','text',...
                                    'String','Arrival Date (DD-MMM-YYYY):', ...
                                    'fontsize',12,...
                                    'units','normalized',...
                                    'Position',[ptX ptY deltaX deltaY],...
                                    'parent',h,...
                                    'horizontalalignment','left');
  deltaY = optHeight;
  ptY = ptY - deltaY;
  deltaX = shortEditWidth;
  gui.parts.arrivalEdit = uicontrol('style','edit',...
                                    'string','',...
                                    'fontsize',12,...
                                    'parent',h,...
                                    'units','normalized',...
                                    'position',[ptX ptY deltaX deltaY],...
                                    'backgroundcolor','white',...
                                    'callback',{@SetStringFieldValue,'singleArrival'});
                                           
  % save button
  ptX = ptX + labelWidth + wMargin;
  deltaX = btnWidth;
  deltaY = btnHeight;
  ptY = bottomRowTop - deltaY;
  gui.parts.saveSingleButton = uicontrol('style','pushbutton',...
                                         'string','Save',...
                                         'fontsize',12,...
                                         'parent',h,...
                                         'units','normalized',...
                                         'position',[ptX ptY deltaX deltaY],...
                                         'callback',{@SavePlot,'single'});
                                                                    
  % RUN button
  deltaX = btnWidth;
  deltaY = runBtnHeight;
  ptX = .5 - deltaX/2;
  ptY = hMargin;
  gui.parts.runButton = uicontrol('style','pushbutton',...
                                          'string','RUN',...
                                          'fontsize',12,...
                                          'fontweight','bold',...
                                          'parent',h,...
                                          'units','normalized',...
                                          'position',[ptX ptY deltaX deltaY],...
                                          'callback',{@RunPorkChop});
   
                                    
  % Since the inline functions are terminated with 'end' instead of
  % 'return', variables declared above will be universal in scope (within
  % this main function). This comes in handy when manipulating the 'gui'
  % variable structure, but we don't want to inadvertently mess with or use
  % any of the other variables in the inline functions. So clear those out.
  clearvars -except gui;
  
  % update options structure
  UpdateGUI;
  
  
  
  %% BrowseForFile
  function BrowseForFile(hObject,eventData,bodyFlag)
    
    % Get the file for the data
    [fileName,pathName] = uigetfile('*.txt');
    if (false == ischar(fileName))
      return;
    end
    
    % Load the data file
    [err,body] = LoadData(fullfile(pathName,fileName));
    if (true == err)
      ReportEvent(1,sprintf('Unable to load %s body data file',body))
      return;
    end
    
    % Set the data and dates to the correct structure
    if (true == strcmpi(bodyFlag,'origin'))
      gui.vars.orig.file    = fullfile(pathName,fileName);
      gui.vars.orig.name    = body.name;
      gui.vars.orig.r       = body.r;
      gui.vars.orig.v       = body.v;
      gui.vars.orig.jDate   = body.jDate;
      gui.vars.orig.calDate = body.calDate;
      gui.vars.orig.start   = body.calDate(1);
      gui.vars.orig.stop    = body.calDate(end);
    elseif (true == strcmpi(bodyFlag,'destination'))
      gui.vars.dest.file    = fullfile(pathName,fileName);
      gui.vars.dest.name    = body.name;
      gui.vars.dest.r       = body.r;
      gui.vars.dest.v       = body.v;
      gui.vars.dest.jDate   = body.jDate;
      gui.vars.dest.calDate = body.calDate;
      gui.vars.dest.start   = body.calDate(1);
      gui.vars.dest.stop    = body.calDate(end);
    else
      ReportEvent(1,sprintf('Improper body flag: %s',bodyFlag));
    end
    
    % Update the GUI
    UpdateGUI;
    
  end


                                      
  %% SetStringFieldValue
  function SetStringFieldValue(hObject,eventData,flag)
    
    % Set the proper variable based on the flag string
    if (true == strcmpi(flag,'originStart'))
      gui.vars.orig.start = datenum(get(gui.parts.origStartEdit,'string'));
    elseif (true == strcmpi(flag,'originStop'))
      gui.vars.orig.stop = datenum(get(gui.parts.origStopEdit,'string'));
    elseif (true == strcmpi(flag,'destinationStart'))
      gui.vars.dest.start = datenum(get(gui.parts.destStartEdit,'string'));
    elseif (true == strcmpi(flag,'destinationStop'))
      gui.vars.dest.stop = datenum(get(gui.parts.destStopEdit,'string'));
    elseif (true == strcmpi(flag,'contourLevels'))
      gui.vars.contourLevels = str2num(get(gui.parts.contourLevelsEdit,'string'));
    elseif (true == strcmpi(flag,'singleLaunch'))
      gui.vars.singleLaunch = datenum(get(gui.parts.launchEdit,'string'));
    elseif (true == strcmpi(flag,'singleArrival'))
      gui.vars.singleArrive = datenum(get(gui.parts.arrivalEdit,'string'));
    else
      ReportEvent(1,'Improper string field flag');
    end
    
    % update GUI
    UpdateGUI;

  end



  %% SetContourType
  function SetContourType(hObject,eventData)
    
    gui.vars.contourType = gui.vars.contourChoices{get(gui.parts.contourList,'value'),2};
    
    UpdateGUI;
    
  end



  %% SavePlot
  function SavePlot(hObject,eventData,type)
    
    % Define file name
    if (true == strcmpi(type,'contour'))
      drawLegend = false;
      ax = gui.parts.contourAx;
      fileName = sprintf('%s %s_%s_%s %s_%s_%s',...
                            gui.vars.contourChoices{get(gui.parts.contourList,'value'),1},...
                            gui.vars.orig.name,...
                            datestr(gui.vars.orig.start),...
                            datestr(gui.vars.orig.stop),...
                            gui.vars.dest.name,...
                            datestr(gui.vars.dest.start),...
                            datestr(gui.vars.dest.stop));
    elseif (true == strcmpi(type,'single'))
      drawLegend = true;
      ax = gui.parts.singleAx;
      fileName = sprintf('transferTrajectory %s-%s %s_%s',...
                            gui.vars.orig.name,...
                            gui.vars.dest.name,...
                            datestr(gui.vars.singleLaunch),...
                            datestr(gui.vars.singleArrive));
    end
    
    % Copy axes to new figure
    h = figure;
    copyobj(ax,h);
    
    % For some reason, the legend isn't copied over for the
    % single-trajectory plot. So if that's the plot we're saving, redraw
    % the legend.
    if (true == drawLegend)
      legend(gui.vars.orig.name,gui.vars.dest.name,'Transfer')
    end
    
    
    % Save plots
    saveas(h,fileName,'png');
    saveas(h,fileName,'fig');
    
    % Close the figure window
    close(h);
    
  end



  %% UpdateGUI
  function UpdateGUI()
    
    % Start by making sure the input data panel is good to go
    set(gui.parts.origSrcFileEdit,'string',gui.vars.orig.file);
    if (false == isempty(gui.vars.orig.file))
      
      % Make sure the origin start and stop dates are within the data range
      if (false == IsInRange(gui.vars.orig.start,gui.vars.orig.calDate))
        ReportEvent(1,'Origin start date is outside data range');
        gui.vars.orig.start = [];
      end
      set(gui.parts.origStartEdit,'string',datestr(gui.vars.orig.start));

      if (false == IsInRange(gui.vars.orig.stop,gui.vars.orig.calDate))
        ReportEvent(1,'Origin end date is outside data range');
        gui.vars.orig.stop = [];
      end
      set(gui.parts.origStopEdit,'string',datestr(gui.vars.orig.stop));
      
    end
    
    % Set the destination source file
    set(gui.parts.destSrcFileEdit,'string',gui.vars.dest.file);
    if (false == isempty(gui.vars.dest.file))
    
      if (false == IsInRange(gui.vars.dest.start,gui.vars.dest.calDate))
        ReportEvent(1,'Destination start date is outside data range');
        gui.vars.dest.start = [];
      end
      set(gui.parts.destStartEdit,'string',datestr(gui.vars.dest.start));

      if (false == IsInRange(gui.vars.dest.stop,gui.vars.dest.calDate))
        ReportEvent(1,'Destination end date is outside data range');
        gui.vars.dest.stop = [];
      end
      set(gui.parts.destStopEdit,'string',datestr(gui.vars.dest.stop));
      
    end
    
    % Enable the run function
    if ( (true == isempty(gui.vars.orig.start)) || (true == isempty(gui.vars.orig.stop)) || ...
         (true == isempty(gui.vars.dest.start)) || (true == isempty(gui.vars.dest.stop)) )
      set(gui.parts.runButton,'enable','off');
    else
      set(gui.parts.runButton,'enable','on');
    end
    
    
    % Make sure that we have a contour type selected and contour layers
    % defined for when we attempt to make the plots
    set(gui.parts.contourList,'value',find(strcmp(gui.vars.contourChoices(:,2),gui.vars.contourType)));
    set(gui.parts.contourLevelsEdit,'string',num2str(gui.vars.contourLevels));
    
    % Now, if we've just run a solution, make the contour plot
    if ( (false == isempty(gui.vars.soln.normBodyV1)) && (false == isempty(gui.vars.contourLevels)) )
      % Reset axes in the contour plot panel
      cla(gui.parts.contourAx,'reset')
      
      % Create the contour plot
      contour(gui.parts.contourAx,...
              gui.vars.soln.oDates,gui.vars.soln.dDates,...
              gui.vars.soln.(gui.vars.contourType),...
              gui.vars.contourLevels,...
              'color','k','lineWidth',2,'showText','on');

      % Set the grid and labels
      set(gui.parts.contourAx,'XTickLabel',datestr(get(gui.parts.contourAx,'xtick')),...
                              'yticklabel',datestr(get(gui.parts.contourAx,'ytick')));
      grid(gui.parts.contourAx,'on')
      xlabel(gui.parts.contourAx,'Departure Date')
      ylabel(gui.parts.contourAx,'Arrival Date')
      title(gui.parts.contourAx,sprintf('%s for %s-%s Transfer',...
                            gui.vars.contourChoices{get(gui.parts.contourList,'value'),1},...
                            gui.vars.orig.name,...
                            gui.vars.dest.name))
  
      % Since we've generated and plotted a solution, enable the save
      % button and the single-trajectory date textboxes
      set(gui.parts.launchEdit,'enable','on');
      set(gui.parts.arrivalEdit,'enable','on');
      set(gui.parts.saveContourButton,'enable','on');
  
    else
      % In this case, we haven't generated any solution data, so make sure
      % the save button isn't enabled
      set(gui.parts.saveContourButton,'enable','off');
      set(gui.parts.launchEdit,'enable','off');
      set(gui.parts.arrivalEdit,'enable','off');
    end
    
    
    % Now, make sure the single-trajectory launch and arrival dates have
    % been defined for when we attempty to draw the trajectory plot
    if (false == isempty(gui.vars.singleLaunch))
      set(gui.parts.launchEdit,'string',datestr(gui.vars.singleLaunch));
    end
    if (false == isempty(gui.vars.singleArrive))
      set(gui.parts.arrivalEdit,'string',datestr(gui.vars.singleArrive));
    end
    
    % Now, if we've just run a solution, make the contour plot
    if ( (false == isempty(gui.vars.singleLaunch)) && (false == isempty(gui.vars.singleArrive)) )
      % Reset axes in the single-trajectory plot panel
      cla(gui.parts.singleAx,'reset')
      
      % Get the launch and arrival indices
      iLD = find(gui.vars.soln.oDates==gui.vars.singleLaunch);
      iO  = find(gui.vars.orig.calDate == gui.vars.singleLaunch);
      iAD = find(gui.vars.soln.dDates==gui.vars.singleArrive);
      iD  = find(gui.vars.dest.calDate == gui.vars.singleArrive);
      
      % Get the body trajectories
      origTraj = CalculateOrbitalTrajectory(gui.vars.orig.r(iO,:), ...
                                            gui.vars.orig.v(iO,:), -1);
      destTraj = CalculateOrbitalTrajectory(gui.vars.dest.r(iD,:), ...
                                            gui.vars.dest.v(iD,:), -1);
      transTraj = CalculateOrbitalTrajectory(gui.vars.soln.r1(iAD,iLD,:), ...
                                             gui.vars.soln.v1(iAD,iLD,:), ...
                                             gui.vars.soln.deltaT(iAD,iLD));
      
      % Plot the trajectories
      plot(gui.parts.singleAx,origTraj(:,1),origTraj(:,2),'b')
      hold(gui.parts.singleAx,'on')
      plot(gui.parts.singleAx,destTraj(:,1),destTraj(:,2),'r')
      plot(gui.parts.singleAx,transTraj(:,1),transTraj(:,2),'m')
      axis(gui.parts.singleAx,'equal')
      
      % Add stats
      textStr = {'  ';...
                 sprintf('   $$\\boldmath{Launch v_{\\infty}:  %0.2f km/s}$$',gui.vars.soln.normBodyV1(iAD,iLD));...
                 sprintf('   $$\\boldmath{Arrival v_{\\infty}: %0.2f km/s}$$',gui.vars.soln.normBodyV2(iAD,iLD))};
      xTxt = min(get(gui.parts.singleAx,'xlim'));
      yTxt = max(get(gui.parts.singleAx,'ylim'));
      text(xTxt,yTxt,textStr,'parent',gui.parts.singleAx,...
        'interpreter','latex','verticalAlignment','top');
      
      % Add labels
      xlabel(gui.parts.singleAx,'X (km)')
      ylabel(gui.parts.singleAx,'Y (km)')
      legend(gui.parts.singleAx,gui.vars.orig.name,gui.vars.dest.name,'Transfer')
      title(gui.parts.singleAx,sprintf('Single-trajectory Transfer Orbit, Launch: %s, Arrive: %s',...
                                       datestr(gui.vars.singleLaunch),datestr(gui.vars.singleArrive)))
      grid(gui.parts.singleAx,'on')
      
      % Add sun, origin on launch date, and destination on arrival date
      plot(gui.parts.singleAx,0,0,'yo','linewidth',8)
      plot(gui.parts.singleAx,origTraj(1,1),origTraj(1,2),'bo','linewidth',4)
      plot(gui.parts.singleAx,destTraj(1,1),destTraj(1,2),'ro','linewidth',4)
  
      % Since we've generated and plotted a solution, enable the save
      % button
      set(gui.parts.saveSingleButton,'enable','on');
  
    else
      % In this case, we haven't generated any solution data, so make sure
      % the save button isn't enabled
      set(gui.parts.saveSingleButton,'enable','off');
    end

  end


  %% RunPorkChop
  function RunPorkChop(hObject,eventData)
    
    % Solve Gauss' problem
    gui.vars.soln = SolveGaussProblem(gui.vars.orig, ...
                                     [gui.vars.orig.start, gui.vars.orig.stop], ...
                                      gui.vars.dest, ...
                                     [gui.vars.dest.start, gui.vars.dest.stop]);
                                   
    % Initialize the single-trajectory dates with the minimum launch deltaV
    [iD,iO] = find(gui.vars.soln.normBodyV1 == min(min(gui.vars.soln.normBodyV1)));
    gui.vars.singleLaunch = gui.vars.soln.oDates(iO);
    gui.vars.singleArrive = gui.vars.soln.dDates(iD);
    
    % Update the GUI
    UpdateGUI;
    
  end


  %% IsInRange
  function flag = IsInRange(dateNum,dateVec)
    
    flag = dateNum >= dateVec(1) && dateNum <= dateVec(end);
    
  end

end