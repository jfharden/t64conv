# T64conv

This gem provides a cli wrapper around c1541 provided with the vice emulator.

Execution will look recursively inside the current directory for T64 files to convert to D64 files.

It will look for T64 files as plain files and also look inside any zip files to see if they contain a T64, a D64, 
or another zip file (if they do it will be unzipped into a temporary directory to operate on.)

A new directory (specified by --outdir/-o, by default ./C64DISKS will be created, or reused if it already exists.

Every T64 file found will have a new directory made which has the same name as the T64 file (if it is SHOWDOWN.T64 a
directory SHOWDOWN created), placed into a subdirectory which is the same of the first letter (uppercased) of the T64
filename (so as to alphabetise them) and have any .nfo file found in the same location as the T64 placed into the same
directory.

All of the files in the output directory will be created with uppercase names.

If you provide the --include-tape/-t option it will also copy the T64 file into the destination directory.

So in the following structure:

```bash
.
└── tape_images
    └── showdown
        ├── SHOWDOWN.T64
        └── VERSION.nfo
```

Would produce
```
.
├── C64DISKS
│   └── S
│       └── SHOWDOWN
│           ├── SHOWDOWN.D64
│           ├── SHOWDOWN.T64
│           └── VERSION.nfo
└── tape_images
    └── showdown
        ├── SHOWDOWN.T64
        └── VERSION.nfo
```

Note in the above example the showdown directory could be a zip file named showdown.zip instead of a directory and the
same result would be produced (utilising a temporary directory to perform the extraction).


## Installation

Install this gem so it provides the executable to your system

```bash
gem install t64conv
```

## Usage

You must have the c1541 utility installed to use this gem.

```bash
t64conv --include-tape
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jfharden/t64conv. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/jfharden/t64conv/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the T64conv project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jfharden/t64conv/blob/master/CODE_OF_CONDUCT.md).
