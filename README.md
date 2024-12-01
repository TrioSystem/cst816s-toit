# cst816s

Library for the CST816S capacitive touch screen IC

## Auto Sleep Control

Auto Sleep is referred to as Standby Mode in the document. Disabling of auto sleep or auto standby will keep the touch display in Dynamic mode. This will improve responsiveness, at the cost of about ~1.6mA.

By default, auto sleep is enabled with a timeout of 2 seconds. The following functions allow you to manage auto sleep behavior:

## User-Provided Interrupt

The CST816S library allows you to attach a custom interrupt function to handle touch events according to your application's needs. By providing a user-defined interrupt, you can trigger specific actions upon touch events, such as waking the device from a low-power state, checking gestures, or executing custom logic without constantly polling the device.

## examples 

A simple usage example.
``` toit
import gpio
import i2c
import cst816s as cst816s

main:

  bus := i2c.Bus
            --sda=gpio.Pin 4
            --scl=gpio.Pin 5

  device := bus.device cst816s.I2C_ADDRESS

  touch := cst816s.Driver device 1 0

  touch.enable-double-click true
  touch.interrupt_control  --motion=true --longpress=true
  touch.assign-action --clear-all=true 
    --swipe-up= ::
      print "UP"
      
  ...
```
See the `examples` folder for more examples.


## Register Information

all registers are described in details in CST816S_register_declaration.pdf
