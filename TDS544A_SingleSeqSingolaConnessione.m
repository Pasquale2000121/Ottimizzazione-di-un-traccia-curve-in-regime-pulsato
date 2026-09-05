function TDS544A_SingleSeqSingolaConnessione(osc)    
    try
        fprintf (osc, 'ACQuire:STOPAfter SEQuence');
        fprintf (osc, 'ACQuire:STATE 1');
    catch ME
        error('ERRORE in SingleSeq: %s', ME.message);
    end
end