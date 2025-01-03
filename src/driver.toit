// MIT License
// Copyright (c) 2024 TrioSystem
// Use of this source code is governed by an MIT-style license that can be
// found in the package's LICENSE file.

import i2c
import gpio
import io


I2C_ADDRESS ::=  0x15

/*
Gesture ID
  NONE = 0x00,
  SWIPE_UP = 0x01,
  SWIPE_DOWN = 0x02,
  SWIPE_LEFT = 0x03,
  SWIPE_RIGHT = 0x04,
  SINGLE_CLICK = 0x05,
  DOUBLE_CLICK = 0x0B,
  LONG_PRESS = 0x0C
 */   

class Coordinate:
  gestureID/int? := null  // Gesture ID
  points/int? := null     // Number of touch points
  event/int? := null      // Event (0 = Down, 1 = Up, 2 = Contact)
  x /int := 0             // X axis coordinate.
  y /int := 0             // Y axis coordinate.
  

  constructor .x .y :

/**
Capacitive touch screen CST816S series driver.
*/
class Driver:
  // Registers.
  static MotionMask   ::= 0xEC 
  static IrqCtl    ::= 0xFA
  static DisAutoSleep  ::= 0xFE
  static AutoSleeptime   ::= 0xF9
  static LongPressTime ::= 0xFC

  dev_/i2c.Device ::= ?
  rst-pin_/gpio.Pin ::= ?
  irq-pin_/gpio.Pin ::= ?
  coord_/Coordinate ::= ?
  actions_/Map := { : }


  constructor  
      .dev_
      rst-pin/int
      irq-pin/int
      :

    rst-pin_ = gpio.Pin.out rst-pin 
    irq-pin_ = gpio.Pin.in irq-pin 

    coord_ = Coordinate 0 0 

    reset_

    //versionInfo := dev_.read-reg 0xA7 3
    //print "Version Info $versionInfo"

    task:: irq-task

    
  /**
  Assigns actions to interrupt events. Optionally all previously registered action are cleared.
  */
  assign-action 
      --clear-all /bool = false
      --irq /Lambda? = null
      --single-click /Lambda? = null
      --double-click /Lambda? = null
      --long-press /Lambda? = null
      --swipe-up /Lambda? = null
      --swipe-down /Lambda? = null
      --swipe-right /Lambda? = null
      --swipe-left /Lambda? = null
    :
    if clear-all: 
      a/Map := { : }
      actions_ = a
    action/Map := {
      0 :  irq,
      1 :  swipe-up,  
      2 :  swipe-down,  
      3 :  swipe-right,  
      4 :  swipe-left,
      5 :  single-click, 
      11 :  double-click, 
      12 :  long-press,       
      } 
         

    action.do: | key value |

      if value:
        actions_.update key 
          --if-absent=: value
          : value

      

  /**
  resets the chip.
  */
  reset_:
    rst-pin_.set 1
    sleep --ms=50
    rst-pin_.set 0
    sleep --ms=5
    rst-pin_.set 1
    sleep --ms=50


  /**
  Read the Coordinate.
  
  get_coords -> List:
    x/List := [coord_.x, coord_.y]
    return x
*/
  get_coords -> Coordinate:
    return coord_


  /*!
    @brief  put the touch screen in standby mode
  
  enable_sleep -> none:
    rst-pin_.set 0
    sleep --ms=5
    rst-pin_.set 1
    sleep --ms=50

    dev_.write-reg 0xA5 #[0x03] 
*/


    /*!
    @brief  enable double click regider 0xEC 

    [bit 2] EnConLR Enable Continuous Left-Right (LR) Scrolling Action
    [bit 1] EnConUD Enable Continuous Up-Down (UD) Scrolling Action
    [bit 0] EnDClick Enable Double Click Action
    */
  enable_double_click on/bool=true -> none:
    if on :
      dev_.write-reg MotionMask #[0x01] 
    else :
      dev_.write-reg MotionMask #[0x00] 

    //motionmask := dev_.read-reg MotionMask 1
    //print " MotionMask is set to $motionmask"
   

    /*!
    @brief  interrupt contol register 0xFA
    
    [bit 7] EnTest Interrupt pin test, automatically generates low pulses
    periodically after being enabled.  128decimal
    [bit 6] EnTouch Generates low pulses when the touch is detected.   64decimal
    [bit 5] EnChange Generates low pulses when touch is changed.       32decimal
    [bit 4] EnMotion Generates low pulses when gesture is detected.    16decimal
    [bit 0] OnceWLP Only generates one low pulse when log press gesture. 1decimal
    Defoult 0x60 = 96decimal = 01100000
    */
  interrupt_control 
      --test/bool=false  
      --touch/bool=false 
      --change/bool=false 
      --motion/bool=false
      --longpress/bool=false
      -> none:
    param := 0
    if test :
      param  += 128
    if touch :
      param  += 64
    if change :
      param += 32
    if motion :
      param += 16
    if longpress :
      param += 1


    dev_.registers.write-u8 IrqCtl param
   

    //interrupt := dev_.read-reg IrqCtl 1
    //print "InterruptMask is set to $interrupt"
  

/*!
    @brief  Set the auto sleep time register 0xF9
    @param  seconds Time in seconds (1-255) before entering standby mode after inactivity
    [bit 7:0] AutoSleepTime Automatically enter low-power mode if there
    is no touch in x seconds. Unit: 1s, Default: 2s.
*/
  set_auto_sleep_time seconds/int -> none:

    if seconds < 1:
      seconds = 1 // Enforce minimum value of 1 second
  
    else if seconds > 255:
      seconds = 255 // Enforce maximum value of 255 seconds  

    dev_.registers.write-u8 0xF9 seconds

    //data := dev_.read-reg 0xF9 1
    //print " Auto Sleep Time is set to $data seconds"
    
  


  irq-task:
    
    while true:
      irq-pin_.wait-for 0

      data_raw/ByteArray := dev_.read-reg 0x01 6
      coord_.gestureID = data-raw.byte-at 0     
      coord_.points = data-raw.byte-at 1        
      coord_.event = (data-raw.byte-at 2) >> 6                //data_raw[2] >> 6
      coord_.x = (io.BIG-ENDIAN.uint16 data-raw 2) & 0x0FFF   //((data_raw[2] & 0xF) << 8) + data_raw[3]
      coord_.y = (io.BIG-ENDIAN.uint16 data-raw 4) & 0x0FFF   //((data_raw[4] & 0xF) << 8) + data_raw[5]

      actions_.get coord_.gestureID
        --if-present=: if actions_[coord_.gestureID] : actions_[coord_.gestureID].call
      
