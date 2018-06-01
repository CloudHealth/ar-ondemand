# ar-ondemand

The `ar-ondemand` gem adds functionality to ActiveRecord to help deal with AR's bloat.

[![Gem Version](https://badge.fury.io/rb/ar-ondemand.svg)](http://badge.fury.io/rb/ar-ondemand)
[![Build Status](https://ci.solanolabs.com:443/cloudhealthtech/ar-ondemand/badges/branches/master?badge_token=bd73a19d5421a68f29e22ad15ad080cbabc56ba7)](https://ci.solanolabs.com:443/cloudhealthtech/ar-ondemand/suites/170027)

# Getting Started

```rb
require 'ar-ondemand'
```

Please note that this library has been written for our needs, and even though it has gotten significant usage in
production environments, it hasn't seen the myriad ways others use and abuse ActiveRecord, so please experiment
locally first.

It has been used with ActiveRecord 3.2, MRI 1.9.3, JRuby 1.7 and the MySQL adapter.

# Functionality

## on_demand

This was the original impetus for the gem. The issue was that we had to compare ~500k records between the source
dataset and our database, and we had no idea which records were new, changed or deleted. We'd preload everything from
the database, but due to ActiveRecord's massive bloat, we'd constantly run into OOM exceptions. To get around that,
the concept of a [lightweight ActiveRecord object](https://github.com/CloudHealth/ar-ondemand/blob/master/lib/ar-ondemand/record.rb)
was introduced that had the absolute bare minimum needed to handle comparing the source data with the database.

With this new type of object, we could easily interate over the 500k records extremely quickly and determine what has
changed. The on-demand aspect comes when `.save` is called. If changes were noticed, it
[secretly](https://github.com/CloudHealth/ar-ondemand/blob/master/lib/ar-ondemand/record.rb#L67) instantiates an actual
ActiveRecord model so that all the real functionality you'd expect, such as validation and callbacks, occurs.

### Usage

```rb
assets = Widget.on_demand :identifier, {customer_id: 1, account_id: 42}
source.each do |dso|
  w = assets[dso[:identifier]]
  w.name = dso[:name]
  w.foo = dso[:foo]
  w.bar = dso[:bar]
  ar_obj = w.save
  # If new or changed, ar_obj will be an ActiveRecord instance, and ar_obj.id will now be set
end
```

## for_reading

How often do you just need to load a bunch of objects and read some properties? Pretty often, right? Now, have you ever
looked at how much memory ActiveRecord itself is consuming, as well as how much extra time it takes to create all the
instances of the objects compared to how long it took to extract from the database? It's bonkers! The `for_reading`
method makes it easy to get access to ActiveRecord-like functionality at 100th the cost.

### Usage

Let's say you have some Widget's. Instead of:

```rb
Widget.where(customer_id: 1).each { |r| ... }
```

use `for_reading` and get a significant speed boost, and use far less memory:

```rb
Widget.where(customer_id: 1).for_reading.each { |r| ... }
```

The big limitation is that you can't use `.includes` so you have to be writing a query for just that class.

### Batch Results

```rb
Widget.where(customer_id: 1).for_reading(batch_size: 50000).each { |b| b.each { |r| } }
```

## for_enumeration_reading

This version of `for_reading` allows even faster access to the record when you just need to pull out some properties
while looping over the dataset. Access to the data is *only* available in the block passed to `for_enumeration_reading`.

```rb
res = Widget.where(customer_id: 1).for_enumeration_reading.inject([]) do |i, r|
    i << [r.id, r.name]
end
```

## for_streaming

Another use case was needing to iterate through 30,000,000 records. The code that needed this data was not setup to work
with batching, so the concept of streaming results was introduced. It simply uses an Enumerator to hide the fact that
batching is actually happening behind the scenes. The downside is that Enumerator made it ~10% slower. If speed matters,
change your code to use batching.

### Usage

```rb
def run
  get_objects.each do |r|
    do_something r
  end
end

def get_objects
  Widget.where(customer_id: 1).for_streaming
end
```

Additional usage:

```rb
Widget.where(customer_id: 1).for_streaming(batch_size: 100_000).each { |r| }
Widget.where(customer_id: 1).for_streaming(for_reading: true).each { |r| }
Widget.where(customer_id: 1).for_streaming(for_reading: true, batch_size: 1_000_000).each { |r| }
```

## for_enumeration_streaming

Just as `for_reading` has an enumeration version, `for_streaming` does as well. This helper function
is aimed at queries or millions of records that need to stream over the results, and only need to pull
out values witin the supplied block.

### Usage

```rb
res = []
Widget.where(customer_id: 1).for_enumeration_streaming(batch_size: 200_000).each do |r|
  res.add [r.id, r.name]
end
```

## raw_results

This is just a nice little helper to get the raw database results, which you'd get by calling `ActiveRecord::Base.connection.select_all`
but for some reason you can't call that on a model.

```rb
ActiveRecord::Base.connection.select_all "select * from widgets"
ActiveRecord::Base.connection.select_all "select * from widgets where customer_id = 1"
ActiveRecord::Base.connection.select_all "select * from widgets where customer_id = 1 limit 100000"
```

### Usage

```rb
Widget.raw_results
Widget.where(customer_id: 1).raw_results
Widget.where(customer_id: 1).limit(100_000).raw_results
```

## delete_all_by_pk

Deleting many records or even a few records in a massive table can be an expensive operation, and can even lock up
your table during the duration of the delete, as well as perform a complete table scan. A common pattern to deal with
this is querying the table first to find the primary keys that meet the criteria and then doing a delete specifying
the primary keys as the `where` condition. This function does that all for you.

### Usage

```rb
Widget.delete_all_by_pk
Widget.where(Widget[:customer_id].eq(1).and(Widget[:usage].gt(42))).delete_all_by_pk
```

If you know you could be deleting millions, then we recommend batching the deletes:

```rb
Widget.where(Widget[:customer_id].eq(1).and(Widget[:usage].gt(42))).delete_all_by_pk(batch_size: 250_000)
```
