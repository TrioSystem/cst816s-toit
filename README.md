# cst816s

Library for the CST816S capacitive touch screen IC

## Auto Sleep Control

Auto Sleep is referred to as Standby Mode in the document. Disabling of auto sleep or auto standby will keep the touch display in Dynamic mode. This will improve responsiveness, at the cost of about ~1.6mA. /

By default, auto sleep is enabled with a timeout of 2 seconds. The following functions allow you to manage auto sleep behavior with "seconds" as Time in seconds (1-255):

``` toit
touch.set_auto_sleep_time seconds  
  ...
```

## User-Provided Interrupt

The CST816S library allows you to attach custom interrupt functions to handle touch events according to your application's needs. /
By providing a user-defined interrupt functions you can trigger specific actions upon gestures, such as 
swipe-up, swipe-down, swipe-left, swipe-right, single-click, double-click and long-press, or at any irq pulse without constantly polling the device. /
Optionally all previously registered actions are cleared with --clear-all=true 


``` toit
touch.assign-action --clear-all=true 
  --swipe-up= ::
      print "UP"

    --swipe-down= ::
    --swipe-left= ::
    --swipe-right= ::
    --single-click= ::
    --double-click= ::
    --long-press= ::
    --irq= ::

  ...
```

##  Interrupt Control
The following functions allow you to manage the irq behavior with : /
--motion = generates irq pulses when gesture is detected. /
--touch = generates irq pulses when touch is detected. /
--change = generates irq pulses when touch is changed. /
--longpress = only generates one irq pulse when log press gesture. /
--test = generates automatically periodic irq pulses for testing purpose. /
By default : touch and change is on:

``` toit
touch.interrupt_control  --motion=true --longpress=true //--touch=true --change=true //--test=true  
  ...
```
## Enable / Disable doubleclick
By default : double-click is disable:

``` toit
touch.enable-double-click true  // false
  ...
```


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
