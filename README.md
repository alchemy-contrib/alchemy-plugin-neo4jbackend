inter
===========

Minimal lib for DOM interaction

Implements common js functions without having to rely on a large library like jQuery or an even larger framework.
Designed so you can easily remove pieces that you do not use to further minimize lib size.

What does it do?
================
Allows simple:
* selection of a DOM element via css selector
* creation of a DOM element
* setting of attributes on a DOM element

Why doesn't it...
=================
Most sites only use a few functions, mainly to get and set DOM elements. Libs with unused functions slow things down for the user. We seem to forget that the user is the priority, and anything that slows the page without benifit is a cardinal sin. Many libs sprawl and try to cover all functionality just incase.  Inter just lets you get and set effectively and efficiently.

License
=======

Beerware.

If you use this library and happen to run into someone who has contributed to it, strongly consider buying them a beer/coffee/social beverage to say thank you.  Other than that, do what you will.
