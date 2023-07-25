import 'package:flutter_call_detector/flavor.dart';

Feature: Phone Call Detector Page
    
    # Scenario: There is no action performed
    #     Given the app is running
    #     Then i see {Dk Phone Call Detector} text

    # Scenario: On Entering message in TextField and pressing btn i see saved
    #     Given the app is running
    #     Then i see {"Text Message"} text
    #     Then i see {TextField} widget
    #     Then i see enabled elevated button
    #     When i enter {"message"} into {0} input field
    #     When i tap on enabled elevated button
    #     Then i see {"Saved"} text
    

    Background:
        Given the app is configured with {Flavor.mock} flavor

    After:
        Then unregister Singletons

    Scenario: There is a TextField for entering message with a Key
        Given the app is running
        Then i see {TextField} widget

    Scenario: There is a widget offstage when the message list is empty
        Given the app is running
        Then i wait
        Then i see widget with {ValueKey("list-offstage")} key

    Scenario: Adding new custom message and viewing list
        Given the app is running
        When i enter {"message"} into {0} input field
        When i tap {"Save"} text
        Then i wait
        Then i see {ListTile} widget
    
    Scenario: Adding two custom messages
        Given the app is running
        When i enter {"this is custom message"} into {0} input field
        When i tap {"Save"} text
        Then i wait
        When i enter {"another message"} into {0} input field
        When i tap {"Save"} text
        Then i wait
        Then i see {ListTile} widget {2} times

    Scenario: Adding two custom messages and selecting one
        Given the app is running
        When i enter {"hello"} into {0} input field
        When i tap {"Save"} text
        Then i wait
        When i enter {"bye"} into {0} input field
        When i tap {"Save"} text
        Then i wait
        Then i see {ListTile} widget {2} times
        When i tap ListTile with {ValueKey(1)} key
        Then i see ListTile widget is selected
        Then i see {"Text Message: bye"} text
        

    # Scenario: The message list is empty when there is no hive data
    #     Given the app is running with {mockHiveBox}
    #     When {mockHiveBox} box has data {[]}
    #     Then i see {"No Saved Messages Found"} text