# Jukebox front-end in React

[![Codeship Status for kyan/jukebox-react](https://codeship.com/projects/48b19f90-0ae9-0134-60dd-223fae911045/status?branch=master)](https://codeship.com/projects/155708)

## Get started using Docker

If you have Docker installed, this is the fastest and prefered way to develop
on the project. To get going you can just run (from the project root):

    $ docker-compose build
    $ docker-compose run --rm service rake db:migrate
    $ docker-compose run --rm service rake db:seed
    $ docker-compose up

This will:

* Build an Image for the UI and run it. It also runs the linter.
* Run the rails app

Visit `http://localhost:8080` to view the app.

Note Docker for mac does not yet support sound and you can't play anything :(

If you are running this in the Kyan office you can switch `websocketServerURI`
to point to `jukebox.local:8081` to use the live jukebox.

### Running the test suite

In another tab you can run the test suite.

`$ docker-compose run web gulp`

### Mopidy

You will want to add your Spotify credentials to `mopidy.conf` – do not commit
these into the repo.

### Code coverage

Note that __100% coverage__ is required to get a passing build which will be run automatically by [Codeship](https://codeship.com).

The coverage will be output in the terminal. You can view more detail (such as the exact code not covered) by opening `index.html` inside the `coverage` directory.

### Istanbul

[https://github.com/gotwarlost/istanbul](https://github.com/gotwarlost/istanbul)

Code coverage is checked via Istanbul.

The `Babel` package `babel-plugin-__coverage__` prevents code we have not written from showing up in the Istanbul coverage report.

### Browserify

[http://browserify.org](http://browserify.org)

Browserify allows us to break out code up into modules and have them all bundled together to work in the browser.

### Babelify

[https://github.com/babel/babelify](https://github.com/babel/babelify)

[Babel](https://github.com/babel/babel) Allows new ES6 syntax to be used.

Combines the [Babel](https://github.com/babel/babel) js compiler to work with `Browserify`

### Watchify

[https://github.com/substack/watchify](https://github.com/substack/watchify)

Auto re-compiles any changes you make to the js files automatically for you.

### Flux

[https://facebook.github.io/flux/](https://facebook.github.io/flux/)

"An application architecture for React utilizing a unidirectional data flow."

Essentially it allows us to easily share state between isolated components.

### Karma

[https://karma-runner.github.io](https://karma-runner.github.io)

Karma is a test runner we use for running the specs.

It is configured to run the specs in a headless [PhantomJS](http://phantomjs.org/) browser.

It also handles Browserify, Babelify and auto-reloading the specs.

### Jasmine

[http://jasmine.github.io/](http://jasmine.github.io/)

Jasmine is the testing framework we use for writing the specs.

### Immutable

[https://facebook.github.io/immutable-js/](https://facebook.github.io/immutable-js/)

Immutable js allows the data in the store to be immutable.

This provides an optimisation for React, as it can detect exactly the data that
has changed and thus only re-renders the components effected.
