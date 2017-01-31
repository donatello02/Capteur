
#ifndef RADIO_SENSE_TO_LEDS_H
#define RADIO_SENSE_TO_LEDS_H
#include "stdio.h"
#include "string.h"
 
typedef nx_struct radio_sense_msg {
  nx_uint16_t error;
  nx_uint16_t mon_id;
  nx_uint16_t dest_id;
  nx_uint16_t data;
  nx_uint16_t v[5];
  nx_uint16_t nbv;
  nx_uint16_t type;
} radio_sense_msg_t;

enum {
  AM_RADIO_SENSE_MSG = 7,
};

#endif
