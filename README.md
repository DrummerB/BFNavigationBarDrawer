# BFNavigationBarDrawer


| *With* automatic scroll view adjustment | *Without* scroll view adjustment |
| ------------- | -----|
| ![Imgur](http://i.imgur.com/0Jpwbr9.gif) | ![Imgur](http://i.imgur.com/JmXZEAi.gif) |


Summary
-------

BFNavigationBarDrawer is a UIToolbar subclass that can easily be displayed below a UINavigationBar, similarly to the playlist view in the Music app. You can also assign a scroll view (or table view) to the drawer. The drawer will take care of moving the scroll view's content down and updating its contentInset property, when the drawer is displayed.

Instructions
------------

Create a Podfile, if you don't have one already. Add the following line.

    pod 'BFNavigationBarDrawer'
    
Run the following command.

    pod install
    
Alternatively, you can just drop the `BFNavigationBarDrawer.{h,m}` files into your project.

Create a drawer instance and assign a scroll view that should be scrolled by the drawer:

    drawer = [[BFNavigationBarDrawer alloc] init];
    drawer.scrollView = self.tableView;
    
Add some UIBarButtonItems to it and when you want to display it, call:

    [drawer showFromNavigationBar:self.navigationController.navigationBar animated:YES];
    
To hide it:

    [drawer hideAnimated:YES];
    
       
Notes
------------

I only tested with iOS 7. It doesn't make a lot of sense to use it with earlier iOS versions, as navigation bars used to be opaque and you could simply resize the scroll view to make room for an additional header bar.

License
-------

[New BSD License](http://en.wikipedia.org/wiki/BSD_licenses). For the full license text, see [here](https://raw.github.com/DrummerB/BFNavigationBarDrawer/master/LICENSE).
