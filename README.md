A Perl interface to the Netatmo API
===================================

This is a Perl library to talk to Netatmo's API and retrieve your device data.
Copy 'example_settings.yaml' to 'settings.yaml', edit appropriately, and you
should then be able to run example.pl:

```
martin@prole ~/netatmo $ ./example.pl 
- Office in Paris
-- Netatmo HQ: 7.6℃, 59%.
-- Coffee Machine: 23.1℃, 24%, 395ppm.
-- Meeting Room: 24.4℃, 22%, 484ppm.
-- Reception: 22.8℃, 21%, 388ppm.
-- Rain Gauge: 0mm (0mm today).
-- Wind Gauge: 1.2mph @ 90°.
-- Boss's Office: 23.5℃, 1009.9mbar, 20%, 34dB, 395ppm.

- Hitchin Close
-- Garden: 52%.
-- Bella's Bedroom: 46%, 848ppm.
-- Martin's Office: 1021.9mbar, 38%, 41dB, 709ppm.
```
