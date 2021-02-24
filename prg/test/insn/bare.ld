SECTIONS
{
 
PROVIDE (__executable_start = SEGMENT_START("text-segment", 0x10000));
. = SEGMENT_START("text-segment", 0x10000) + SIZEOF_HEADERS;
 
. = 0x11000;
 
.text : {*(.text)}
 
. = DATA_SEGMENT_ALIGN (0x10000, 0x10000);
.data : {*(.data)}
.bss : {*(.bss)}
. = DATA_SEGMENT_END (.);

.data : {
. = ALIGN(8);
. = . + 0x1000; /* 4kB of stack memory */
stack_top = .;
}

}
