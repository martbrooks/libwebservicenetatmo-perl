A Perl interface to the Netatmo API
===================================

This is a Perl library to talk to Netatmo's API and retrieve your device data.
Copy 'example_settings.yaml' to 'settings.yaml', edit appropriately, and you should
then be able to run example.pl:

martin@prole ~/netatmo $ ./example.pl 
Hitchin Close
- Bella's Bedroom: 19.7
- Martin's Office: 21.9
- Garden: -1.2

Currently there's only a module for the weather modules as those are all I have.
It should be fairly easy to extend for the other devices.
