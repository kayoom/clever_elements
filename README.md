clever\_elements
================

[![Build Status](https://secure.travis-ci.org/cice/clever_elements.png)](http://travis-ci.org/cice/clever_elements)


**Under Development, any help appreciated!**

**clever\_elements** is a RubyGem to use the **CleverElements SOAP Api** with Ruby / Rails.

Rails 3 Quickstart
------------------

The easiest way to use **clever\_elements** is with Rails 3. Just extend your Gemfile

    gem 'clever_elements', '~> 0.0.1'
    
put a `clever_elements.yml` file in your `#{Rails.root}/config`:

    user_id: <your user id>
    api_key: <your api key>
    mode: <test or live>
    
And use the `CleverElements::List` and `CleverElements::Subscriber` models, e.g.

    # Get the ids of all lists in your account:
    CleverElements::List.ids
    # => ['73302']
    
    # Get the list for a specific id:
    CleverElements::List.find '73302'
    # => <CleverElements::List:0x007fb78a8ab8f0 @id="73302", @name="ABC", @description="foobar", @subscriber="0", @unsubscriber="0">

    # Get all lists in your account:
    CleverElements::List.all
    # => [<CleverElements::List:0x007fb78a8ab8f0 @id="73302", @name="ABC", @description="foobar", @subscriber="0", @unsubscriber="0">]
    
    # Create a new list:
    list = CleverElements::List.new :name => 'baz'
    list.id
    # => nil
    list.create
    # => true
    list.id 
    # => 73303
    
    # Remove a list:
    list = CleverElements::List.find('73302')
    list.id
    # => 73302
    list.destroy
    # => true
    list.id
    # => nil
    
    # Get the subscribers in a list
    list = CleverElements::List.find('73302')
    list.subscriber
    # => [<CleverElements::Subscriber:0x007fb78a8ab8f0 @id='123123', @email='max@muster.de'>]
    
    # or
    CleverElements::Subscriber.all '73302'
    # => [<CleverElements::Subscriber:0x007fb78a8ab8f0 @id='123123', @email='max@muster.de'>]
    
    # Add a subscriber
    subscriber = list.create_subscriber :email => 'max@muster.de'
    # => <CleverElements::Subscriber:0x007fb78a8ab8f0 @id='123143', @email='max@muster.de'>
    
    # Unsubscribe
    subscriber.unsubscribe_from_all
    
### What doesn't work / hasn't been implemented yet?
* custom fields
* unsubscribe\_from\_list (implemented but API request doesn't work)

### What could be improved?
* extensions/wasabi\_parser.rb
* comprehensive exception handling
* environment dependent configuration (development, test, production)
* test / spec helpers