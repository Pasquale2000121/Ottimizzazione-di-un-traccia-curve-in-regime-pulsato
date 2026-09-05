function TDS544A_YSingolaConnessione(osc, source_ch, yscale, ypos)
  try
    if ypos > 3.8 ypos=3.8; 
    elseif ypos < -3.8 ypos=-3.8; end
    %% Y axis Setting
    text_cmd = strcat(source_ch,':SCALe');
    fprintf (osc, [text_cmd,' ', num2str(yscale)]);
    text_cmd = strcat(source_ch,':POSition ');
    fprintf (osc, [text_cmd, ' ', num2str(ypos)]);
    text_cmd = strcat(source_ch,':OFFSet ');
    fprintf (osc, [text_cmd, ' ', num2str(0)]);
  catch ME
    error('ERRORE impostazione Asse Y (%s): %s', sourche_ch, ME.message);
  end
end
