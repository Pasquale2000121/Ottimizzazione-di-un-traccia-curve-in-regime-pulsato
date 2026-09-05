%% Current Probe - TCP0150

function [Vapp,Imeas,Vmeas] = TDS544ACompVoltage_HP(supply, Vfix, Vdes, Vapp, vgs_min,vgs_max, vds_min,vds_max, Tolerance, Kp, Ki, osc,xosc, osc_Vdsch, osc_Idch, t1, t2,SerialPortParam, mode, Pulse_Width, xoff, Att1, Att2, Att3, Att4, AutoZeros)
    Vmeas = 0;
    error_V = Vdes - Vmeas;
    it_count = 0;
    it_limit_min = 2; % Current Resolution
    it_limit_max = 15;
    Imeas = 5;
    state_integral = 0;
    Tolerance = Tolerance*0.8;
    last_iter = 0;

    while((abs(error_V) > Tolerance && it_count < it_limit_max) || it_count < it_limit_min || last_iter < 2)
        
        drawnow; % Aggiorna la coda eventi di MATLAB
        f_stop = findobj('Type', 'Figure', 'Number', 1); % Cerca la figure(1)
        if ~isempty(f_stop)
            userData = get(f_stop, 'UserData');
            if isfield(userData, 'stopFlag') && userData.stopFlag
                % Se è stato premuto STOP, esci brutalmente dalla compensazione
                return; 
            end
        end
        
        SupplySetting_HP(supply, Vfix, Vapp, osc, vgs_min,vgs_max, vds_min,vds_max, 1);                                    
        pause(0.2)
        sendDataSTM32(SerialPortParam, mode, 10, Pulse_Width, 100, 120, Vdes);     
        %SupplySetting_HP(Vfix, Vapp, osc, vgs_min,vgs_max, vds_min,vds_max, 0);

        %% Drain Voltage
        current_sel = extractAfter(osc_Vdsch, 'CH');
        % canale = str2double(current_sel);
        switch str2double(current_sel)
            case 1
                y = TDS544A_GetDataSingolaConnessione(osc, length(xosc), current_sel, xoff, Att1, AutoZeros(1));
                Att = Att1;
            case 2
                y = TDS544A_GetDataSingolaConnessione(osc, length(xosc), current_sel, xoff, Att2, AutoZeros(2));
                Att = Att2;
            case 3
                y = TDS544A_GetDataSingolaConnessione(osc, length(xosc), current_sel, xoff, Att3, AutoZeros(3));
                Att = Att3;
            case 4
                y = TDS544A_GetDataSingolaConnessione(osc, length(xosc), current_sel, xoff, Att4, AutoZeros(4));
                Att = Att4;
        end
        Vmeas=mean(y((t1<xosc)&(xosc<t2)));
        % Zoom(Vmeas, osc, osc_Vdsch, -1);
        error_V = Vdes - abs(Vmeas);
        %% Enable for MOSFET
        if  error_V < 0.100
            scale = 0.2;
        elseif error_V >= 0.100 && error_V < 1
            scale = 0.5;
        else
            scale = 1;
        end

        TDS544A_Y_OffsetSingolaConnessione(osc, osc_Vdsch, scale, 1.5, Vdes, Att, 0);
        %% Enable for Diode
        %TDS544A_Y_OffsetSingolaConnessione(osc, osc_Vdsch, scale, 1.5, Vmeas, 0);
		%% Drain Current
        current_sel = extractAfter(osc_Idch, 'CH');
        switch str2double(current_sel)
            case 1
                y = TDS544A_GetDataSingolaConnessione(osc, length(xosc), current_sel, xoff, Att1, AutoZeros(1));
                Att = Att1;
            case 2
                y = TDS544A_GetDataSingolaConnessione(osc, length(xosc), current_sel, xoff, Att2, AutoZeros(2));
                Att = Att2;
            case 3
                y = TDS544A_GetDataSingolaConnessione(osc, length(xosc), current_sel, xoff, Att3, AutoZeros(3));
                Att = Att3;
            case 4
                y = TDS544A_GetDataSingolaConnessione(osc, length(xosc), current_sel, xoff, Att4, AutoZeros(4));
                Att = Att4;
        end

        Imeas = mean(y((t1<xosc)&(xosc<t2)));
        if abs(error_V) > Tolerance
            TDS544A_Y_OffsetSingolaConnessione(osc, osc_Idch, 5, 0, Imeas, Att, 0);
            Vapp = Vapp + Kp * error_V + Ki * state_integral; %y[n]=y[n-1]+kp*x[n]+ki*x[n-1]
            state_integral = error_V; % Integration
            last_iter = 0;
        else 
            % TDS544A_Y_OffsetSingolaConnessione(osc, osc_Idch, 0.5, 0, Imeas, Att, 0);
            TDS544A_Y_OffsetSingolaConnessione(osc, osc_Idch,  abs(Imeas/(str2double(Att)))/4, 0, Imeas, Att, 0);
            Zoom(Vdes, osc, osc_Vdsch, 0);
            last_iter = last_iter + 1;
        %ZOOM
        end

        it_count = it_count + 1;
        %% Cases to avoid compensation
        if Vapp > vds_max
            disp('WARNING: Supply Vds limit');
            break;
        end
        if Vapp < vds_min && Vmeas < 0
            disp('WARNING: Supply Vds limit');
            break;
        end
        if it_count > it_limit_max
            disp('WARNING: Vds not Compensated');
        end

    end
end
