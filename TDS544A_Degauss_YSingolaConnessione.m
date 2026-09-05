function TDS544A_Degauss_YSingolaConnessione(osc, source_ch)
  try
    %% Y axis Setting
    messaggio = sprintf('Premi il tasto DEGAUSS fisico per la sonda sul %s, poi premi OK.', source_ch);
    uiwait(msgbox(messaggio, 'Degauss Sonda Manuale', 'modal'));
    pause (6.5);
  catch ME
        error('ERRORE in Degauss (%s): %s', source_ch, ME.message);
  end
end
