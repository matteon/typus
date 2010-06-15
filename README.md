# Typus: Admin interface for Rails applications

**Typus** is designed for a single activity:

    Trusted users editing structured content.

**Typus** doesn't try to be all the things to all the people but it's 
extensible enough to match lots of use cases.

## Key Features

- Access control by users and roles.
- CRUD and custom actions for your models on a clean interface.
- Internationalized interface.
- Extensible and overwritable templates.
- Low memory footprint.
- Show database tables.
- Easily update data.
- Create new data.
- Automatic form validation.
- Ruby 1.9 compatible.
- Sortable columns.
- Supports SQLite, MySQL, and PostgreSQL.
- Boolean filtering.
- Supports ActiveRecord.
- Search for records.
- Pagination.
- Supports Rails 2.3.
- MIT License, the same as Rails.

## Links

- [Project site and documentation](http://labs.intraducibles.com/projects/typus)
- [Plugin source](http://github.com/fesplugas/typus)
- [Mailing list](http://groups.google.com/group/typus)
- [Bug reports](http://github.com/fesplugas/typus/issues)
- [Gems](http://gemcutter.org/gems/typus)
- [Contributors](http://github.com/fesplugas/typus/contributors)

## Installing

Install from GitHub the latest version which is compatible with Rails 2.3.8.

    $ script/plugin install git://github.com/fesplugas/typus.git -r 2-3-stable

Once `typus` is installed, run the generator to create required files 
and migrate your database.

    $ script/generate typus
    $ rake db:migrate

Start the application server and go to <http://0.0.0.0:3000/admin>.

## License

Copyright &copy; 2007-2010 Francesc Esplugas Marti, released under the 
MIT license
