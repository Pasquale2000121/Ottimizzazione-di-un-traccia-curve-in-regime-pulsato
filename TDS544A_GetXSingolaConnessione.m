function t =  TDS544A_GetXSingolaConnessione(osc)
  try
    close all;
    % Reset Status
    fprintf(osc, '*CLS'); 
    fprintf(osc, ':HEADer OFF');
    while osc.BytesAvailable > 0
        fscanf(osc);  % or use fgetl(supply)
    end
    
    %% X axis Setting
    timeScale = str2double(query(osc, 'HORizontal:MAIn:SCAle?'));
    
    %% creazione asse x
    t_total = timeScale*10 ;
    t = linspace(0, t_total, 500); % Vettore tempo
  catch ME
    error('ERRORE nel GET X: %s', ME.message);
  end
end
