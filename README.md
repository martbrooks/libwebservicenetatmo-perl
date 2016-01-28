A Perl interface to the Netatmo API
===================================

This is a Perl library to talk to Netatmo's API and retrieve your device data.
Copy 'example_settings.yaml' to 'settings.yaml', edit appropriately, and you
should then be able to run example.pl:

```
martin@prole ~/netatmo $ ./example.pl 
Garden: 8.7℃, -, 64%, -, -
Bella's Bedroom: 19.4℃, -, 52%, -, 504ppm
Martin's Office: 22.6℃, 1024.7mbar, 44%, 50dB, 579ppm
```

Currently there's only a module for the weather modules as those are all I
have.  It should be fairly easy to extend for the other devices.
