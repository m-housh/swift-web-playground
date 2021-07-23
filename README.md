[![CI](https://github.com/m-housh/swift-web-playground/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/m-housh/swift-web-playground/actions/workflows/ci.yml)

# swift-web-playground

Exploring the [pointfreeco/swift-web](https://github.com/pointfreeco/swift-web) framework.

## Overview

I started this project to help understand the `pointfreeco/swift-web` framework, by creating a
simple CRUD server.  The web framework uses some cryptic functional operators, so I wanted to
understand how they worked a little better and hopefully find some ways to add some synactic sugar
around them.

This project utilizes hyper-modularization and is implemented as a swift-package.

## Quickstart

To run this project locally, first clone the repository.

```
$ git clone https://github.com/m-housh/swift-web-playground.git
$ cd swift-web-playground
```

The easiest way is to run using docker compose.

```
$ make run-server-linux
```

When done or if you want to reset the data in the database containers, you can remove containers. Then run
the following command.
```
$ make clean-db-linux
```

### Alternative

If you don't have `PostgreSQL` installed then you can install via your favorite package manager.  Below is
how you can install using `homebrew`.

```
$ brew install postgresql
```

Start the postgres database.
```
$ brew services start postgresql
```

After the database has started run the following command to create the appropriate database users.
```
$ make db
```

Now you can start the server.
```
$ swift run server
```

