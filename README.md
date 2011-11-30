MultiRowCalloutAnnotationView - Exactly what it says, for MapKit / iOS 
=============
Created by Gregory S. Combs.  
Based on work at [GitHub](https://github.com/grgcombs/MultiRowCalloutAnnotationView).

Description
=============

- This is an annotation view that sports a callout bubble with multiple, independently selectable rows of data.  The objective is to allow each cell/row to utilize an accessory disclosure button, without resorting to a more involved UITableViewController scenario.

Implementation
=============

(See the demo for a functional representation of this project.)

- Presuming you've already set up your project to use the MapKit Framework, you first need to add the appropriate classes in the "MultiRowCalloutAnnotationView" directory.
- Next, ensure your annotation class (if you have a preexisting one) answers to the "title" selector, and that it also returns an array of MultiRowCalloutCells upon request.
- The callout cell class takes a title, subtitle, and an image.  You can also supply an NSDictionary for custom data that is passed along on accessory button touches.  
- The MultiRowCalloutAnnotationView gathers the necessary information and conveniently uses blocks to handle the button touch events.

Attributions and Thanks
=============

A portion of this class is based on James Rantanen's work at Asynchrony Solutions

- http://blog.asolutions.com/2010/09/building-custom-map-annotation-callouts-part-1/
- http://blog.asolutions.com/2010/09/building-custom-map-annotation-callouts-part-2/
 
License
=========================

[Under a Creative Commons Attribution 3.0 Unported License](http://creativecommons.org/licenses/by/3.0/)

![Creative Commons License Badge](http://i.creativecommons.org/l/by/3.0/88x31.png "Creative Commons Attribution")

Screenshots
=========================

![Screenshot](https://github.com/grgcombs/MultiRowCalloutAnnotationView/raw/master/screenshot.png "Screenshot")
