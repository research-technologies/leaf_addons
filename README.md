


# LeafAddons

[![Build Status](https://travis-ci.org/research-technologies/leaf_addons.svg?branch=master)](https://travis-ci.org/research-technologies/leaf_addons)
[![Coverage Status](https://coveralls.io/repos/github/research-technologies/leaf_addons/badge.svg?branch=master)](https://coveralls.io/github/research-technologies/leaf_addons?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/59592cff3f45fdb42f72/maintainability)](https://codeclimate.com/github/research-technologies/leaf_addons/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/59592cff3f45fdb42f72/test_coverage)](https://codeclimate.com/github/research-technologies/leaf_addons/test_coverage)
[![Inline docs](http://inch-ci.org/github/research-technologies/leaf_addons.svg?branch=master)](http://inch-ci.org/github/research-technologies/leaf_addons)

LeafAddons provide additional functionality for Hyrax or Hyku repositories via a set of generators / plugins / tasks

## Importers

Importers for EPrints JSON, MARC, and directories of files.

Please see the wiki for further info:

* [Files_Directory_Importer](https://github.com/research-technologies/leaf_addons/wiki/Files_Directory_Importer)
* [EPrints_Json_Importer](https://github.com/research-technologies/leaf_addons/wiki/EPrints_Json_Importer)
* [MARC_Importer](https://github.com/research-technologies/leaf_addons/wiki/MARC_Importer)

Install with:

```
rails g leaf_addons:importers
```

## Devise Invitible

Adds and enables invitation only login with Devise invitible.

Install with:

```
rails g leaf_addons:invitible
```

## Coversheets

Adds and enables creation of coversheets on download for PDF and office document formats.

Install with:

```
rails g leaf_addons:coversheet
```

## OAI-PMH

Adds and enables an oai-pmh interface.

Install with:

```
rails g leaf_addons:oai_pmh
```

## Tasks

Delete unused access control policies:

```
rake leaf_addons:cleanup_accesscontrol
```

User accounts tasks:

List them with `rake -T leaf_addons`

Including:

```
rake leaf_addons:make_me_admin[email@address.com]
rake leaf_addons:invite_user[email@address.com] # if devise invitible is enabled
rake leaf_addons:invite_users['/tmp/my_file.csv'] # CSV file must contain a header row and three columns: email, display name, admin; admin column should contain the word true to indicate that the given user should be an admin

```
