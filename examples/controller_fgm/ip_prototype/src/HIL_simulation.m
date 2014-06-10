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
set(handles.states, 'XLim', [0,3000], 'YLim', [-10,10]); 

axes(handles.inputs);
xlabel('steps [k]', 'FontSize', 10);
ylabel('u', 'FontSize', 10);
title('Inputs', 'FontSize', 10);
set(handles.inputs, 'XLim', [0,3000], 'YLim', [-2,2]); 


        


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
   
% Set the number of simulations to run
num_simulation=3000;


load FGM_example.mat
nx=size(A_d,1);
nu=size(B_d,2);

num_iter_in=ones(1,40)*num_iter;


fpga_x_log_plot=[];
fpga_u_log_plot=[];


for i=1:num_simulation
    
    
%     [num_simulation-i]

	%% preprocess
	%(algotihm's steps that will be implemented on the CPU)
	Fxr=[Fx,Fr];                            % This can be precomputed
	invH0 = inv(H);                         % This can be precomputed
	dualH0 = Aineq*invH0*Aineq';            % This can be precomputed
	sh = diag(1./sqrt(sum(abs(dualH0),2))); % This can be precomputed
	dualH = sh*dualH0*sh;                   % This can be precomputed
	premat_xout = -invH0*Aineq'*sh;         % This can be precomputed
	premat_xr = -invH0*Fxr;                 % This can be precomputed

    
   
    

	if (i>1)

		 if (matlabFPGA==2) %matlab
             x_out=matlab_x_out;
         elseif (matlabFPGA==1) %fpga
            x_out=fpga_x_out;
         end
		
		%% postprocess
		%(algotihm's instruction that will be implemented on the CPU)
		theta = premat_xout*x_out + premat_xr*[x0;xref];
	   
		%% Apply plant model
		u_out = theta(1:nu);
     
		x0 = A_d*x0 + B_d*u_out;
        
        pause(0.01)
        
         fpga_x_log_plot=[fpga_x_log_plot, x0];
    
        plot(handles.states,fpga_x_log_plot');
        axes(handles.states);
        xlabel('steps [k]', 'FontSize', 10);
        ylabel('x', 'FontSize', 10);
        title('States', 'FontSize', 10);
        set(handles.states, 'XLim', [0,3000], 'YLim', [-10,10]); 
         pause(0.01)
        
         fpga_u_log_plot=[fpga_u_log_plot, u_out(1:nu)];
         plot(handles.inputs,fpga_u_log_plot');
         axes(handles.inputs);
        xlabel('steps [k]', 'FontSize', 10);
        ylabel('u', 'FontSize', 10);
        title('Inputs', 'FontSize', 10);
        set(handles.inputs, 'XLim', [0,3000], 'YLim', [-2,2]);

		

	end
	
	xrlvec=[x0;xref;1];
	xr=[x0;xref];
	b=Bineq0 + Bineq*x0;
	FTxrl_int=[Aineq*invH0*Fxr, b];
	FTxrl = (sh*FTxrl_int)';
	x_in = FTxrl'*xrlvec; %this will be passed to the FPGA

	
    
    matlabFPGA=get(handles.matlabfpga,'Value');

    if (matlabFPGA==2) %matlab

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% compute with Matlab and save in a file simulation results

        % Simulation results x_out
        %initialization
        x = zeros(size(dualH,1),1);
        y = x;


        %% process
        %(algotihm's steps that will be implemented on the FPGA)
        for k2=1:num_iter_in(1)

            % Cache previous value of x
            xprev = x;

            % Calculate gradient
            gradJ = dualH*y+x_in;

            % Update x (from preconditioning, the value "L" is zero)
            xtilde = y - gradJ;

            % Project onto feasible region
            for k3 = 1:size(x,1)
                x(k3) = xtilde(k3);
                if xtilde(k3) > bmax(k3)
                    x(k3) = bmax(k3); 
                end
                if xtilde(k3) < bmin(k3)
                    x(k3) = bmin(k3);
                end
            end


            % Calculate difference between x and xprev
            xdiff = x-xprev;


            % Update y
            y = x+beta_iter(k2)*xdiff;


        end

        matlab_x_out = x; %this will be read from the FPGA
        
        log_enable=get(handles.log,'Value');
        
        if (log_enable==1)
        
            %save x_out_log
            filename = strcat('../test_hil/results/matlab_x_out_log.dat');
            fid = fopen(filename, 'a+');

            for j=1:length(matlab_x_out)
                fprintf(fid, '%2.18f,',matlab_x_out(j));
            end
            fprintf(fid, '\n');

            fclose(fid);
        end

    elseif (matlabFPGA==1) %fpga
 
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %save x0_log
%         filename = strcat('../test_hil/results/x0_log.dat');
%         fid = fopen(filename, 'a+');
% 
%         for j=1:length(x0)
%             fprintf(fid, '%2.18f,',x0(j));
%         end
%             fprintf(fid, '\n');
% 
%         fclose(fid);
% 
% 
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %save x_in_log
%         filename = strcat('../test_hil/results/x_in_log.dat');
%         fid = fopen(filename, 'a+');
% 
%         for j=1:length(x_in)
%             fprintf(fid, '%2.18f,',x_in(j));
%         end
%         fprintf(fid, '\n');
% 
%         fclose(fid);
% 
% 
% 
% 
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %save num_iter_in_log
%         filename = strcat('../test_hil/results/num_iter_in_log.dat');
%         fid = fopen(filename, 'a+');
% 
%         for j=1:length(num_iter_in)
%             fprintf(fid, '%2.18f,',num_iter_in(j));
%         end
%         fprintf(fid, '\n');
% 
%         fclose(fid);


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
        data_to_send=x_in;
        FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);

        % send num_iter_in
        Packet_type=3; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
        packet_internal_ID=1;
        packet_output_size=1;
        data_to_send=num_iter_in;
        FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);


        % start FPGA
        Packet_type=2; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
        packet_internal_ID=0;
        packet_output_size=1;
        data_to_send=0;
        FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);


        % read data from FPGA
        % read x_out
        Packet_type=4; % 1 for reset, 2 for start, 3 for write to IP vector packet_internal_ID, 4 for read from IP vector packet_internal_ID of size packet_output_size
        packet_internal_ID=0;
        packet_output_size=40;
        data_to_send=0;
        [output_FPGA, ~, ~] = FPGAclientMATLAB(data_to_send,Packet_type,packet_internal_ID,packet_output_size);
        fpga_x_out=output_FPGA;

        log_enable=get(handles.log,'Value');

        if (log_enable==1)

            %save x_out_log
            filename = strcat('../test_hil/results/fpga_x_out_log.dat');
            fid = fopen(filename, 'a+');

            for j=1:length(fpga_x_out)
                fprintf(fid, '%2.18f,',fpga_x_out(j));
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
