# DocBook XSL Wrapper

_Initial 'gemification' of the DocBook XSL Ruby script. Please consider
this as an Alpha release._

The DocBook XSL stylesheets are very powerful and provide an easy way to output
your DocBook XML documents into a usable format such as EPUB and PDF. This GEM
hopes to make using these stylesheets even easier.

At present the wrapper will only convert DocBook to EPUB 2 and is
intended to be run from the command-line - future versions will have more
functionality (see Future Improvements).

The original Ruby script can be found at: http://docbook.sourceforge.net/release/xsl/1.78.0/epub/bin/


## Requirements

* DocBook
* DocBook XSL (~> v1.78.0)
* xsltproc

### NOTE

The Docbook XSL Wrapper uses xsltproc, which allows all stylesheets to be
pulled from the http://docbook.sourceforge.net... URI, but if you have the
stylesheets installed locally, xsltproc will rewrite the URI to use local files.

On my OSX Lion system, "docbook" was installed via Homebrew, but two issues
needed fixing before everything worked correctly.

The catalog file ($XML_CATALOG_FILES) needed updating;

1. Add an entry to your 1.78.0 path.
2. Remove older XSL entries (e.g. 1.76.0 & 1.77.0).

_Please make sure that xsltproc uses the *1.78.0* stylesheets as default_


## Installation

    $ gem install docbook_xsl_wrapper

## Usage

    $ docbook_xsl_wrapper [OPTIONS] [DocBook File]

## Future Improvements

  * Better design so it can be used from within other GEMs, as part of a larger tool-chain.
  * Test that the GEM also works on Linux.
  * EPUB3 output
  * Other output formats (e.g. PDF)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
