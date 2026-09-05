function y = TDS544A_GetDataSingolaConnessione(osc, record_length, ch_num_s, xoff, attenuazione, autozero) 
  try
    % Flushing Buffer
    fprintf(osc, '*CLS');
    fprintf(osc, 'HEADer OFF');
    while osc.BytesAvailable > 0
        fscanf(osc);  % or use fgetl(supply)
    end

    
    %% Configurazione canale
    fprintf(osc, ['DATa:SOUrce CH', ch_num_s]);

    fprintf(osc, 'HEADer ON');
    fprintf(osc, 'HEADer OFF');
    %%Pulire
    RL = double(record_length);
    X_Off = double(xoff);
    centro_finestra = round(RL * (X_Off/100));
    
    data_start = centro_finestra - 250;
    data_stop = centro_finestra + 249;
    
    if data_start < 1
        data_start = 1;
        data_stop = 500;
    end
    if data_stop > record_length
        data_stop = record_length;
        data_start = record_length - 499;
    end


    %% Configurazione del formato dati
    fprintf(osc, 'DATA:ENCdg RIBinary'); % Dati in formato binario
    fprintf(osc, 'WFMPRE:BYT_Nr 1'); % 8-bit per campione
    fprintf(osc, ['DATa:STARt ', num2str(data_start)]);
    fprintf(osc, ['DATa:STOP ', num2str(data_stop)]);
    fprintf(osc, 'HEADer OFF');
    
    risposta1     = query(osc, ['WFMPRE:CH', ch_num_s, ':YMULT?']);
    verticalScale = str2double(risposta1);
    risposta2     = query(osc, ['WFMPRE:CH', ch_num_s, ':YOFF?']);
    YOFF          = str2double(risposta2);
    risposta3     = query(osc, ['WFMPRE:CH', ch_num_s, ':YZERO?']);
    YZERO         = str2double(risposta3);

    clrdevice(osc);
    pause(0.02);
    %% Lettura dati
    fprintf(osc, 'CURVe?'); % Richiede i dati d'onda
    raw_data = binblockread(osc, 'int8')'; % Legge dati binari
    fscanf(osc);

    % Conversione in valori reali (volt)
    y = (str2double(attenuazione)*((double(raw_data) - YOFF) * verticalScale + YZERO ) + autozero);
    pause(0.02);
    clrdevice(osc);
  catch ME
    error('ERRORE in GetData (canale %s): %s', ch_num_s, ME.message);
  end
end
    