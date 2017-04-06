# Dining
A project that demonstrates interactive animating view controllers to display a restaurant's reservation. It is purely a sample app so some of the views are just dummy views with nothing in them and it has some rough edges in the UI. It will display the view using view effects

In addition to demonstrating the animating view controller. It also has a TableViewAdapter pattern that avoids the massive view controller, and that TableViewAdaptor supports multiple cell types and only minor configuration when the view is loaded. The TableViewAdaptor is designed to be reused and is not just for this one instance. 

• Overall Approach keep the view controllers small, typically these become quite large with many responsibilities and become unmanagable. You can see this by adopting the Adaptor pattern for the tableView. The Adaptor for the table view is reusable for other table views and supports multiple cell types. 

• Adhere to the single responsibility principle. Where each object does one thing and one thing only as much as possible

• Pull to refresh works to bring up the next set of data.

• There is LRU cache which in UIImageView+Extension that demonstrates some multithreaded aware code.
