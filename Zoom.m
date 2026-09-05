function Zoom(Vmean, osc, source_ch, ypos)
    


   % dati_ordinati = sort(y_data, 'descend');
   % num_punti_cima = round(length(y_data) * 0.10);
   % V_tetto = mean(dati_ordinati(1:num_punti_cima));
    if Vmean <= 1.01
        NewScale = 0.020;
        % offset = Vmean;
    elseif Vmean > 1.01 && Vmean <= 10
        NewScale = 0.1;
        % offset = Vmean;
    else
        NewScale = 1.01;
    end
   text_cmd = strcat(source_ch,':OFFSet ');
   fprintf (osc, [text_cmd, ' ', num2str(Vmean)]);
   text_cmd = strcat(source_ch,':SCALe');
   fprintf (osc, [text_cmd,' ', num2str(NewScale)]);
   text_cmd = strcat(source_ch,':POSition ');
   fprintf (osc, [text_cmd, ' ', num2str(ypos)]);

   pause(0.5);
    % valori = []
    % for i = 1:20
    %     z.ch1 = TDS544A_GetDataSingolaConnessione(app.osc_obj, length(app.t), '1', app.XoffKnob.Value);
    %       pause(0.1);
    %     valori(end+1) = mean(z.ch1);
    % end
    