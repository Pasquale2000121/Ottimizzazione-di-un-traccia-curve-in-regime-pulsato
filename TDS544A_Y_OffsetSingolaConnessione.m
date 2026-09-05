function TDS544A_Y_OffsetSingolaConnessione(osc, source_ch, yscale, ypos, yoff, att, diff_probe)
  try
    att = str2double(att);
    yoff = yoff/att;
    % diff_probe - Single-end probe offset is limited to 10V;
    if diff_probe == 0
        if abs(yoff) > 1 && abs(yoff) <= 10
            if yscale < 0.101
                yscale = 0.101;
            elseif yscale > 1.0
                yscale = 1.0;
            end
        elseif abs(yoff) > 10
            if yscale < 1.01
                yscale = 1.01;
            elseif yscale > 10
                yscale = 10;
            end
        elseif abs(yoff) <= 1
            if yscale < 0.020
                yscale = 0.020;
            elseif yscale > 0.100
                yscale = 0.100;
            end
        end            
    else
%diff_probe = 1 non ancora ideato per il TDS544A
        if yoff > 49.5
            yscale = 5;
        end
    end
    %ypos = ypos/yscale; % normalized than the y division
    if yscale > 50
        yscale = 50;
    elseif yscale < 0.1
        yscale = 0.1;
    end

    %% Y axis Setting
    text_cmd = strcat(source_ch,':SCALe');
    fprintf (osc, [text_cmd,' ', num2str(yscale)]);
    text_cmd = strcat(source_ch,':POSition ');
    fprintf (osc, [text_cmd, ' ', num2str(ypos)]);
    text_cmd = strcat(source_ch,':OFFSet ');
    fprintf (osc, [text_cmd, ' ', num2str(yoff)]);
    %recordLength = str2double(query(osc, 'HORizontal:RECOrdlength?'));
    %pause (0.1);
  catch ME
    error('ERRORE impostazione Y Offset (%s): %s', source_ch, ME.message);
  end
    
  
end
