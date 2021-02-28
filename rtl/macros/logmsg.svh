`ifndef LOGMSG_SVH_INCLUDED
`define LOGMSG_SVH_INCLUDED

`ifdef MSG_LEVEL
    `define MSG(level, msg_str) \
        do begin \
            if (level < `MSG_LEVEL && level < cfg::logmsg_level) begin \
                $write("%0t %s\n", $time, $sformatf msg_str); \
            end \
        end while(0)
`else
    `define MSG(level, msg_str) do begin end while(0)
`endif

`endif