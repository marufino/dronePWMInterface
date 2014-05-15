import Adafruit_BBIO.PWM as PWM

#PWM.start(channel, duty, freq=2000, polarity=0)
PWM.start("P9_14", 70)
PWM.start("P9_16",20)
PWM.start("P8_13",10)
PWM.start("P8_19",15)

