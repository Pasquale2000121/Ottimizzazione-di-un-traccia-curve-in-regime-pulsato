function [Vapp, Vmeas] = TDS544ACompVoltage_HP_Gate(supply, Vapp, Vdes, Vfix, vgs_min,vgs_max, vds_min,vds_max, Tolerance, Kp, Ki, osc,xosc, osc_Vgsch, t1, t2,SerialPortParam, mode, Pulse_Width, xoff, Att1, Att2, Att3, Att4, AutoZeros)
  try
    Vdes = Vdes; 
    Vmeas = 0;
    error_V = Vdes - Vmeas;
    it_count = 0;
    it_limit_min = 1;
    it_limit_max = 10;
    Tolerance = Tolerance*0.6;
    state_integral = 0;
    last_iter = 0;

    while ((abs(error_V) > Tolerance && it_count < it_limit_max) || it_count < it_limit_min || last_iter < 2)
        drawnow; % Aggiorna la coda eventi di MATLAB
        f_stop = findobj('Type', 'Figure', 'Number', 1); % Cerca la figure(1)
        if ~isempty(f_stop)
            userData = get(f_stop, 'UserData');
            if isfield(userData, 'stopFlag') && userData.stopFlag
                % Se è stato premuto STOP, esci brutalmente dalla compensazione
                return; 
            end
        end
        SupplySetting_HP(supply, Vapp, Vfix, osc, vgs_min,vgs_max, vds_min,vds_max, 1);
        pause(0.1)
        sendDataSTM32(SerialPortParam, mode, 10, Pulse_Width, 100, 120, Vdes);      
        % SupplySetting_HP(Vapp, Vfix, osc, vgs_min,vgs_max, vds_min,vds_max, 0);

        %% Gate Voltage
        current_sel = extractAfter(osc_Vgsch, 'CH');
        % canale = str2double(current_sel);
        switch str2double(current_sel)
            case 1
                y = TDS544A_GetDataSingolaConnessione(osc, length(xosc), current_sel, xoff, Att1, AutoZeros(1));
            case 2
                y = TDS544A_GetDataSingolaConnessione(osc, length(xosc), current_sel, xoff, Att2, AutoZeros(2));
            case 3
                y = TDS544A_GetDataSingolaConnessione(osc, length(xosc), current_sel, xoff, Att3, AutoZeros(3));
            case 4
                y = TDS544A_GetDataSingolaConnessione(osc, length(xosc), current_sel, xoff, Att4, AutoZeros(4));
        end
        Vmeas=mean(y((t1<xosc)&(xosc<t2)));

        error_V = Vdes - abs(Vmeas);

        if abs(error_V) > Tolerance
            Vapp = Vapp + Kp * error_V + Ki * state_integral; %y[n]=y[n-1]+kp*x[n]+ki*x[n-1]
            state_integral = error_V; % Integration
            last_iter = 0;
        else
            Zoom(Vdes, osc, osc_Vgsch, 0);
            last_iter = last_iter + 1;
        end

        it_count = it_count + 1;
        if it_count > it_limit_max
            disp('WARNING: Vgs not Compensated');
        end

        %% Cases to avoid compensation
        if Vapp > vgs_max
            disp('WARNING: Supply Vgs limit');
            break;
        end
        if Vapp < vgs_min && Vmeas < 0
            disp('WARNING: Supply Vgs limit');
            break;
        end

    end
  catch ME
    error('ERRORE in CompVoltage_HP_Gate %s', ME.message);
  end
end
