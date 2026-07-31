---
layout: post
title: "Teaching RSpec How to Speak"
date: 2017-11-01 01:16:53 +0100
tags: [ruby, rspec, testing]
description: "Using a text-to-speech gem to have RSpec announce your test results out loud so long test runs never get forgotten."
---

As a Ruby on Rails developer, I write a lot of RSpec tests, and for big applications, it takes a lot of time to run them all.

For my current project tests, it takes close to half an hour to run, so I’m often getting distracted by other tasks, funny Facebook memes, or interesting YouTube videos. As a result, my running tests are being forgotten. I’ve spent some time to try to find a good solution to remind me about these running tests, and I’ve found it.

## TTS - Text to Speech. (Time to Speak :P )

I was wondering if I can use the Google Translate voice to tell me when my tests were done, and I found a way to do it. We just need a [tts](https://github.com/c2h2/tts) gem and a bit of magic.

First, install the tts gem by adding it to the `Gemfile`

```ruby
gem 'tts'
```

or just by running `gem install tts`.

Then we need to modify our `spec/spec_helper.rb` and add a few lines:

```ruby
require 'tts'
config.after(:suite) do
  "Rspec completed testing the application.".play
end
```

So, after a whole bunch of tests (`config.after(:suite)`) the code will run tts method `play`, that will tell us that tests were completed.

But what if I want to hear more detailed results? We can get current results from RSpec’s reporter variable and count the number of successful results.

```ruby
reporter = RSpec.world.reporter
examples_count = reporter.examples.count
failed_examples_count = reporter.failed_examples.count
successful_examples_count = examples_count - failed_examples_count
```

Now we can combine everything and listen to how RSpec tells us the statistics after each run

```ruby
config.after(:suite) do
  reporter = RSpec.world.reporter
  examples_count = reporter.examples.count
  failed_examples_count = reporter.failed_examples.count
  successful_examples_count = examples_count - failed_examples_count
  "Rspec completed testing the application. Total count is #{examples_count}. Successful - #{successful_examples_count}. Failed - #{failed_examples_count}".play
end
```

What if we don’t want to hear this annoying text all the time, like when you are just running single tests, or sitting in the silent office and don’t want to bother others with an announcement of the results of your tests or if you don’t want to scare your roommates?

I found that we can’t easily pass the options to the `rspec` command, BUT we can use environment variables to set some parameters.

Let’s agree that we will use `RSPEC_TTS_ENABLED` environment variable defining if we want to hear our command or not. Then we can enable the tts only if it will receive the variable.

```ruby
if ENV['RSPEC_TTS_ENABLED']
  config.after(:suite) do
    reporter = RSpec.world.reporter
    examples_count = reporter.examples.count
    failed_examples_count = reporter.failed_examples.count
    successful_examples_count = examples_count - failed_examples_count
    "Rspec completed testing the application. Total count is #{examples_count}. Successful - #{successful_examples_count}. Failed - #{failed_examples_count}".play
  end
end
```

That’s it! A bit of code and we now have a helpful reminder for completed tests :)
