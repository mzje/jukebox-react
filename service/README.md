# Jukebox

[![Build Status](https://magnum.travis-ci.com/kyan/jukebox.svg?token=xhNqA5biipNRT3jusiMc&branch=master)](https://magnum.travis-ci.com/kyan/jukebox)

### Local Development

There is a homebrew formula for Mopidy.
Detailed instructions on how to install Mopidy on OS X on the [official Mopidy docs](http://docs.mopidy.com/).

### Tests

First thing you should do is run the tests! You can run the tests with:

    $ bin/rake db:test:prepare
    $ bin/rspec spec/

### Mopidy Config

    $ cat /etc/mopidy/mopidy.conf

Should look like this:

    [logging]
    config_file = /etc/mopidy/logging.conf
    debug_file = /var/log/mopidy/mopidy-debug.log

    [mpd]
    hostname = ::

    [spotify]
    username = kyanuser
    password = 5e5mBfQcMWAU

    [local]
    library = whoosh
    media_dir = /Music
    playlists_dir = /home/deploy/.config/mopidy/local/playlists

    [scrobbler]
    enabled = false

If you have a Spotify premium account then update the username and password.

Alternatively disable it as per the scrobbler.

Then run `mopidy local scan` to index your music.

### Start app

    $ bundle install
    $ bundle exec rake db:seed
    $ bundle exec foreman start

Inside `seeds/db.rb` you'll find credentials to login as Big Rainbow Head.

### Running locally

In `config/environments/development.rb` change `config.mpd_host` to 'localhost'

    $ mopidy
    $ bundle exec foreman start
    $ bundle exec thin start

### SSH keys

For security we do not use passwords, instead we use SSH keys.

Check which SSH keys you have enabled on your machine via:

    $ ssh-add -l

If the `kyan_deploy` key is missing you'll need to go get it. Ask someone.

Once you have it on your machine enable it via:

    $ ssh-add ~/.ssh/kyan_deploy

### starting Mopidy on the production box

As root:

    root@jukebox: service mopidy start
    root@jukebox: service mopidy status

### Restarting BRH

    root@jukebox: service jukebox-party_shuffle restart

### Foreman and Upstart on production

On the Server Upstart takes care of the Jukebox and all it's services via:

    root@jukebox: stop jukebox
    root@jukebox: start jukebox
    root@jukebox: restart jukebox

It simply exports the contents of the Foreman 'Procfile' on each deploy.

Note we do not keep Mopidy in the `Profile` as it clears out the playlist
each time it is restarted so we don't want to do that on deploy.

### Debugging on the server

Fire off any MPD commands you like, for example:

    $ telnet localhost 6600
    $ setvol 50
    $ status

### Deploy to the server

    $ bundle exec cap deploy:migrations

### If Jukebox is alive but returning no search results

Mopidy probably needs a reboot via:

    $ ssh deploy@jukebox.local
    $ sudo /etc/init.d/mopidy restart
