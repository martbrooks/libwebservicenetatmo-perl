A Perl interface to the Netatmo API
===================================

This is a Perl library to talk to Netatmo's API and retrieve your device data.
Copy 'example_settings.yaml' to 'settings.yaml', edit appropriately, and you
should then be able to run example.pl:

```
martin@prole ~/netatmo $ ./example.pl 
- Office in Paris
-- Netatmo HQ: 59%.
-- Coffee Machine: 24%, 395ppm.
-- Meeting Room: 22%, 484ppm.
-- Reception: 21%, 388ppm.
-- Rain Gauge: 0mm (0mm today).
-- Wind Gauge: 1.2mph @ 90°.
-- Boss's Office: 1009.9mbar, 20%, 34dB, 395ppm.

- Hitchin Close
-- Garden: 7.5℃, 52%.
-- Bella's Bedroom: 18.3℃, 46%, 848ppm.
-- Martin's Office: 21.8℃, 1021.9mbar, 38%, 41dB, 709ppm.
```
