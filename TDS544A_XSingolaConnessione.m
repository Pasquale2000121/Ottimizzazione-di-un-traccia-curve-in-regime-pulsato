function t =  TDS544A_XSingolaConnessione(osc, record_length, time_scale, trigger, xoff, xpos, trigger_ch, trigger_level, trigger_slope)
  try
    close all;
    %Approssimazione asse dei tempi per eccesso verso valori accettati dal
    %TDS544a
    esponente = floor(log10(time_scale));
    moltiplicatore = 10^esponente;
    base = time_scale / moltiplicatore;

    if base <= 1
        base = 1;
    elseif base <=2
        base = 2;
    elseif base <=5
        base = 5;
    else
        base = 10;
    end

    time_scale_arrotondato = base*moltiplicatore;
    
    % Reset Status
    fprintf(osc, '*CLS'); 
    fprintf(osc, ':HEADer OFF');
    while osc.BytesAvailable > 0
        fscanf(osc);  
    end
    fprintf(osc, 'ACQuire:STOPAfter RUNStop');
    fprintf(osc, 'ACQuire:STATE 1');
    fprintf(osc, 'HORizontal:DELay:MODe OFF');
    %% X axis Setting
    fprintf(osc, ['HORizontal:RECOrdlength ', num2str(record_length)]); 
    fprintf(osc, ['HORizontal:MAIn:SCAle ', num2str(time_scale_arrotondato)]); % sec/div
    fprintf(osc, ['HORizontal:POSition ', num2str(xoff)]);
    recordLength = 500;
    timeScale = str2double(query(osc, 'HORizontal:MAIn:SCAle?'));
    

    
    %% creazione asse x
    samplerate = recordLength / (timeScale * 10);
    t_sampling = 1 / samplerate;
    t = linspace(0, recordLength -1 , recordLength) * t_sampling;
    
    %% Trigger Setting
    fprintf(osc, ['TRIGger:MAIn:MODe ', trigger]);
    trigerpos = sprintf('HORizontal:TRIGger:POSition %d', xpos);
    fprintf(osc, trigerpos);
    fprintf(osc, ['TRIGger:MAIn:EDGE:SOUrce ', num2str(trigger_ch)]);
    fprintf(osc, ['TRIGger:MAIn:LEVel ', num2str(trigger_level)]);
    fprintf(osc, ['TRIGger:MAIn:EDGE:SLOpe ', trigger_slope]);
    %pause (0.2);
  catch ME
    error('ERRORE in impostazione Asse X e trigger: %s', ME.message);
  end

end
