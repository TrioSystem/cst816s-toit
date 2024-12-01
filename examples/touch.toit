// Copyright (c) 2024 TrioSystems
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the examples/EXAMPLES_LICENSE file.

import gpio
import i2c
import cst816s as cst816s

//ESP32-2424S012 pin configuration
SDA_PIN ::= 4
SCL_PIN ::= 5
RST_PIN ::= 1
IRQ_PIN ::= 0


main:

  bus := i2c.Bus
            --sda=gpio.Pin SDA-PIN
            --scl=gpio.Pin SCL-PIN

  device := bus.device cst816s.I2C_ADDRESS

  touch := cst816s.Driver device RST_PIN IRQ_PIN

  touch.enable-double-click true
  touch.interrupt_control  --motion=true --longpress=true //--touch=true --change=true //--test=true 
  



  touch.assign-action --clear-all=true 
    --swipe-up= ::
      print "UP"

    --swipe-down= ::
      print "Down"

    --swipe-left= ::
      print "Left"

    --swipe-right= ::
      print "Right"

    --single-click= ::
      print "Click"
      print "x= $touch.coord_.x"
      print "y= $touch.coord_.y"
      print "finger= $touch.coord_.points"
      print "event= $touch.coord_.event"

    --double-click= ::
      print "Click-Click"

    --long-press= ::
      print "LongPress"
      print "finger= $touch.coord_.points"
      print "event= $touch.coord_.event"
  

  //while true:
    
    /*
    touch.get-coords
    touch.read-touch
    print touch.coord_.x
    print touch.coord_.y
    sleep --ms=100
    */
