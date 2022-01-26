// File: WaitNS.h
// Author: Urs Hofmann
// Mail: hofmannu@ethz.ch
// makes nanosecond delays happening through sleeping through clock cycles 

#ifndef WAITNS_H
#define WAITNS_H

// wait a few clock cycles
#define NOP __asm__ __volatile__ ("nop\n\t") // ~ 4 ns = one clock cycle

#define WAIT_12_NS NOP; NOP; NOP;
#define WAIT_24_NS WAIT_12_NS; WAIT_12_NS;
#define WAIT_48_NS WAIT_24_NS; WAIT_24_NS;
#define WAIT_96_NS WAIT_48_NS; WAIT_48_NS;
#define WAIT_192_NS WAIT_96_NS; WAIT_96_NS;

#endif