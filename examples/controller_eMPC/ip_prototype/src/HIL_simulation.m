function varargout = HIL_simulation(varargin)
% HIL_SIMULATION MATLAB code for HIL_simulation.fig
%      HIL_SIMULATION, by itself, creates a new HIL_SIMULATION or raises the existing
%      singleton*.
%
%      H = HIL_SIMULATION returns the handle to a new HIL_SIMULATION or the handle to
%      the existing singleton*.
%
%      HIL_SIMULATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HIL_SIMULATION.M with the given input arguments.
%
%      HIL_SIMULATION('Property','Value',...) creates a new HIL_SIMULATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HIL_simulation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HIL_simulation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HIL_simulation

% Last Modified by GUIDE v2.5 10-Jun-2014 15:55:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HIL_simulation_OpeningFcn, ...
                   'gui_OutputFcn',  @HIL_simulation_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before HIL_simulation is made visible.
function HIL_simulation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HIL_simulation (see VARARGIN)

% Choose default command line output for HIL_simulation
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HIL_simulation wait for user response (see UIRESUME)
% uiwait(handles.figure1);


info = imfinfo('logo.jpg') % Determine the size of the image file
axes(handles.logo);
imshow('logo.jpg');
set(handles.logo, 'Units', 'Normalized', 'Position', [0.05, 0.85, 0.3, 0.152]);


info = imfinfo('HIL.jpg'); % Determine the size of the image file
axes(handles.HIL);
imshow('HIL.jpg');
set(handles.HIL, 'Units', 'Normalized', 'Position', [0, 0.15, 0.39, 0.325]);

axes(handles.states);
xlabel('steps [k]', 'FontSize', 10);
ylabel('x', 'FontSize', 10);
title('States', 'FontSize', 10);
set(handles.states, 'XLim', [0,100], 'YLim', [-3,3]); 

axes(handles.inputs);
xlabel('steps [k]', 'FontSize', 10);
ylabel('u', 'FontSize', 10);
title('Inputs', 'FontSize', 10);
set(handles.inputs, 'XLim', [0,100], 'YLim', [-20,20]); 


        


% --- Outputs from this function are returned to the command line.
function varargout = HIL_simulation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Exit_button.
function Exit_button_Callback(hObject, eventdata, handles)
% hObject    handle to Exit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close


% --- Executes on button press in Start_button.
function Start_button_Callback(hObject, eventdata, handles)
% hObject    handle to Start_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


Run_HIL(hObject, eventdata, handles);




function Run_HIL(hObject, eventdata, handles)

addpath('functions');
   
% Set the number of simulations to run
num_simulation=100;


filename=strcat('eMPC_inverted_pendulum.mat');
load(filename);

nx=size(ctrl.sysStruct.B,1);
nu=size(ctrl.sysStruct.B,2);
G=ctrl.Gi;
F=ctrl.Fi;

A=(ctrl.sysStruct.A);
B=(ctrl.sysStruct.B);
C=(ctrl.sysStruct.C);
D=(ctrl.sysStruct.D);

x0=[-pi*2/3;  0];

fpga_x_log_plot=[];
fpga_u_log_plot=[];


for i=1:num_simulation

    

	if (i>1)

		 matlabFPGA=get(handles.matlabfpga,'Value');
	
		 if (matlabFPGA==2) %matlab
             u_out=matlab_u_out;
         elseif (matlabFPGA==1) %fpga
            u_out=fpga_u_out;
         end
		
     
		x0 = A*x0 + B*u_out;
		
		log_enable=get(handles.log,'Value');
		
		if (log_enable==1)
        
            %save x0_log
            filename = strcat('../test_hil/results/x0_log.dat');
            fid = fopen(filename, 'a+');

            for j=1:length(x0)
                fprintf(fid, '%2.18f,',x0(j));
            end
            fprintf(fid, '\n');

            fclose(fid);
        end
        
        
		
        
        pause(0.01)
        
         fpga_x_log_plot=[fpga_x_log_plot, x0];
    
        plot(handles.states,fpga_x_log_plot');
        axes(handles.states);
        xlabel('steps [k]', 'FontSize', 10);
        ylabel('x', 'FontSize', 10);
        title('States', 'FontSize', 10);
        set(handles.states, 'XLim', [0,100], 'YLim', [-3,3]); 
         pause(0.01)
        
         fpga_u_log_plot=[fpga_u_log_plot, u_out(1:nu)];
         plot(handles.inputs,fpga_u_log_plot');
         axes(handles.inputs);
        xlabel('steps [k]', 'FontSize', 10);
        ylabel('u', 'FontSize', 10);
        title('Inputs', 'FontSize', 10);
        set(handles.inputs, 'XLim', [0,100], 'YLim', [-20,20]);
		

		

	end
	
	
	
    
    matlabFPGA=get(handles.matlabfpga,'Value');

    if (matlabFPGA==2) %matlab

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% compute with Matlab and save in a file simulation results

        % Simulation results u_out
		[region, ~] = double_searchTree_point_location(ctrl,x0);
		tmp = double_control_law(F,G, x0, region);
		matlab_u_out=tmp(1:nu);

        
        log_enable=get(handles.log,'Value');
        
        if (log_enable==1)
        
            %save u_out_log
            filename = strcat('../test_hil/results/matlab_u_out_log.dat');
            fid = fopen(filename, 'a+');

            for j=1:length(matlab_u_out)
                fprintf(fid, '%2.18f,',matlab_u_out(j));
            end
            fprintf(fid, '\n');

            fclose(fid);
        end

    elseif (matlabFPGA==1) %fpga
 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% send the stimulus to the FPGA, execute the algorithm and read back the results
        % reset IP
        Packet_type=1; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
        packet_internal_ID=0;
        packet_output_size=1;
        data_to_send=1;
        FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);


        % send data to FPGA
        % send x_in
        Packet_type=3; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
        packet_internal_ID=0;
        packet_output_size=1;
        data_to_send=x0;
        FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);


        % start FPGA
        Packet_type=2; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
        packet_internal_ID=0;
        packet_output_size=1;
        data_to_send=0;
        FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);


        % read data from FPGA
        % read u_out
        Packet_type=4; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
        packet_internal_ID=0;
        packet_output_size=2;
        data_to_send=0;
        [output_FPGA, ~, ~] = FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);
        fpga_u_out=output_FPGA(1:nu);

        log_enable=get(handles.log,'Value');

        if (log_enable==1)

            %save fpga_u_out_log
            filename = strcat('../test_hil/results/fpga_u_out_log.dat');
            fid = fopen(filename, 'a+');

            for j=1:length(fpga_u_out)
                fprintf(fid, '%2.18f,',fpga_u_out(j));
            end
            fprintf(fid, '\n');

            fclose(fid);

        end
        
    end

	

end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in log.
function log_Callback(hObject, eventdata, handles)
% hObject    handle to log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of log





% --- Executes on selection change in matlabfpga.
function matlabfpga_Callback(hObject, eventdata, handles)
% hObject    handle to matlabfpga (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns matlabfpga contents as cell array
%        contents{get(hObject,'Value')} returns selected item from matlabfpga
if (get(handles.matlabfpga,'Value')==1) 

    info = imfinfo('HIL.jpg'); % Determine the size of the image file
    axes(handles.HIL);
    imshow('HIL.jpg');
    set(handles.HIL, 'Units', 'Normalized', 'Position', [0, 0.15, 0.39, 0.325]);
    
else
    
     info = imfinfo('HIL1.jpg'); % Determine the size of the image file
    axes(handles.HIL);
    imshow('HIL1.jpg');
    set(handles.HIL, 'Units', 'Normalized', 'Position', [0, 0.15, 0.39, 0.325]);
    
end


% --- Executes during object creation, after setting all properties.
function matlabfpga_CreateFcn(hObject, eventdata, handles)
% hObject    handle to matlabfpga (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
