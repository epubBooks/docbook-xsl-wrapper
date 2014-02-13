# DocBook XSL Wrapper

**IMPORTANT NOTICE - THIS GEM IS NO LONGER UNDER DEVELOPMENT**

_I've been struggling to re-work this GEM to be usable as a library, rather than just as a command-line tool. On top of that I think perhaps the GEM naming is not the best._

_For these reasons, I'm unlikely to develop this GEM any further. I may release an alternate _Docbook to EPUB_ libary at a later date, so keep an eye on my Github account for that._

====

_Please consider this as an Alpha release._

The DocBook XSL stylesheets are very powerful and provide an easy way to output
your DocBook XML documents into a usable format such as EPUB and PDF. This GEM
hopes to make using these stylesheets even easier.

At present the wrapper will only convert DocBook to EPUB2 and EPUB3 and is
intended to be run from the command-line - future versions will have more
functionality (see Future Improvements).

The original Ruby script can be found at: http://docbook.sourceforge.net/release/xsl/1.78.0/epub/bin/


## Requirements

* DocBook
* DocBook XSL (included in this repo)



## Installation

    $ gem install docbook_xsl_wrapper

## Usage

    $ docbook_xsl_wrapper [OPTIONS] [DocBook File]

## Future Improvements

  * Better design so it can be used from within other GEMs, as part of a larger tool-chain.
  * Test that the GEM also works on Linux.
  * Other output formats (e.g. PDF)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
