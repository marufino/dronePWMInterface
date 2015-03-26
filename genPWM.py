import Adafruit_BBIO.PWM as PWM

#PWM.start(channel, duty, freq=2000, polarity=0)
PWM.start("P9_14", 45)
PWM.start("P9_16",25)
PWM.start("P8_13",55)
PWM.start("P8_19",35)

