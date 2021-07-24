[![CI](https://github.com/m-housh/swift-web-playground/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/m-housh/swift-web-playground/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/m-housh/swift-web-playground/branch/main/graph/badge.svg?token=GYr6z4hAce)](https://codecov.io/gh/m-housh/swift-web-playground)

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
git clone https://github.com/m-housh/swift-web-playground.git
```

Move into the project directory.
```
cd swift-web-playground
```

The easiest way is to run using docker compose, if it is installed on your system.  Which will start the
server and database running in docker containers.
```
make run-server-linux
```

When done or if you want to reset the data in the database containers, you can remove containers. Then run
the following command.
```
make clean-db-linux
```

### Alternative

If you don't have [PostgreSQL](https://www.postgresql.org) installed then you can install via your favorite 
package manager.  Below is how you can install using [homebrew](https://brew.sh).
```
brew install postgresql
```

Start the postgreSQL database.
```
brew services start postgresql
```

After the database has started run the following command to create the appropriate database users.
```
make db
```

Now you can start the server.
```
swift run server
```

To clean up the database and remove the created user when done, you can run the following command.
```
make clean-db
```

