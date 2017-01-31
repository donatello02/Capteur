#include "Timer.h"
#include "RadioSenseToLeds.h"

module RadioSenseToLedsC @safe(){
  uses {
    interface Leds;
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli> as MilliTimer;
    interface Packet;
    interface Read<uint16_t>;
    interface SplitControl as RadioControl;
	
  }
}
implementation {

  message_t packet;
  bool locked = FALSE;
  
  event void Boot.booted() {
    call RadioControl.start();
    
        call Leds.led1On();
	
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call MilliTimer.startPeriodic(2000);
    }
  }
  event void RadioControl.stopDone(error_t err) {}
  
  event void MilliTimer.fired() {
    call Read.read();
  }

  event void Read.readDone(error_t result, uint16_t data) {
    if (locked) {
      return;
    }
    else {
      radio_sense_msg_t* rsm;

      rsm = (radio_sense_msg_t*)call Packet.getPayload(&packet, sizeof(radio_sense_msg_t));
      if (rsm == NULL) {
	return;
      }
      rsm->error = result;
      data = -39.6 +0.01 * data;
	rsm->data = data;
	rsm->dest_id = 0;
       rsm->mon_id = TOS_NODE_ID;
       if ( TOS_NODE_ID  != 0){
 call Leds.led2Toggle();
	
		printf("  + [%d]   Temperature envoye (%d) a [%d]\n",  rsm->mon_id  ,rsm->data,rsm->dest_id);
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_sense_msg_t)) == SUCCESS) {
	locked = TRUE;
      }
	}
	else{;
}
	
    }
  }

  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
    call Leds.led1Toggle();
    if (len != sizeof(radio_sense_msg_t)) {return bufPtr;}
    else {
	
      radio_sense_msg_t* rsm = (radio_sense_msg_t*)payload;
	uint16_t dest_id =rsm->dest_id;
	
	if (dest_id == TOS_NODE_ID){
     printf("  + [%d] Temperature recu (%d) de %d \n",rsm->dest_id , rsm->data, rsm->mon_id);//,rsm->mon_id);
	 call Leds.led0Toggle();
 	return bufPtr;
	}
	else{
		 call Leds.led1Toggle();
 	
		printf("  + [%d] Temperature broadcast pour [%d]\n",TOS_NODE_ID,  rsm->mon_id);
	
		     if (call AMSend.send(0, &packet, sizeof(radio_sense_msg_t)) == SUCCESS) 
			{
			locked = TRUE;
		      }
		
 		return bufPtr;
	
	}
    }
  }



  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

}
