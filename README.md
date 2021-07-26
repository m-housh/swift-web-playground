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

When done or if you want to reset the data in the database containers, the following command will remove 
the containers.
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

### Explore the api routes.

There is a paw file in the repository.  If you don't currently use paw, you can download a free trial at [paw.cloud](https://paw.cloud) to explore the api routes on the server.

There are basically 2 routes that the api currently handles which are `/api/users` and `/api/favorites`.
Where the users data structure consists of only a `name` and the favorites are a user relation that only
consists of a `description`.

Below are some examples of using [httpie](https://httpie.io) and interacting with the api on the default
port, however you could use `curl` or the existing `paw` file as well.

#### Create a new user
```
http :8080/api/users name="blob"
```

#### List all users.
```
http :8080/api/users
```

#### Update a user.
```
http :8080/api/users name="blob-sr"
```

#### Delete a user.
```
http DELETE :8080/api/users/78976CC6-EA94-11EB-AE9D-8FF1032E6348
```

#### Create a new user favorite
```
http :8080/api/favorites userId=78976CC6-EA94-11EB-AE9D-8FF1032E6348 description="Tacos"
```

#### Fetch all favorites
```
http :8080/api/favorites
```

#### Fetch all favorites for a user
```
http :8080/api/favorites userId==78976CC6-EA94-11EB-AE9D-8FF1032E6348
```

This is equivalent to the following query `/api/favorites?userId=78976CC6-EA94-11EB-AE9D-8FF1032E6348`

#### Update a favorite
```
http :8080/api/favorites/4A52CB80-EA94-11EB-AE9D-E30362C9E57B description="Pizza"
```

#### Delete a favorite
```
http DELETE :8080/api/favorites/4A52CB80-EA94-11EB-AE9D-E30362C9E57B
```

## The long story.
My normal profession is as a 3rd generation owner of a small HVAC company.  Since taking over the company
I have developed an interest in software development and have several internal services that I run / maintain.
Those services are getting older, are web-based, and written primarily in python.

Since our company runs entirely on apple devices, I have been interested in everything `swift` over the last
few years.  I have some backend services written in [vapor](https://github.com/vapor/vapor), but have recently
gained interest in the [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
for frontend work, and thought that I should explore their [swift-web](https://github.com/pointfreeco/swift-web)
framework, eventhough it is mentioned on the repo that it considered not stable.

The `swift-web` framework uses a bunch of, in my opinion cryptic operators (some of which I still have to just
copy and paste... i.e. `<¢>` 😂), and so I set out exploring their [isowords](https://github.com/pointfreeco/isowords) 
project, which is somewhat large and includes both frontend and backend code. So the purpose of this repo was 
to breakdown just what was needed to stand up a simple CRUD api and explore some ways to add some 
synactic sugar around it.

This allowed me to explore several of the [pointfreeco](https://github.com/pointfreeco) open source packages, as well
as interact with some [vapor](https://github.com/vapor/vapor) database packages at a lower level than I had previously.
And while this package still has a decent amount of libraries it exposes, most are just a few files and offers a good
separation of concerns, IMO.

It is my hope to write some articles around my experience for the last few days of learning this framework, but in
the meantime I will give a brief overview of the libraries defined in this package.  See the documentation strings
in the files themselves for more information (while I work on exploring hosting the DocC generated documentation).

### SharedModels

This defines the data types that are stored in the database and are shared amongst many of the libraries in the
package.  I kept them very simple for the sake of this project.

### DatabaseClient

This library exposes all the database operations that are used by the application.  It is just a value type
which is extended later on to have a `live` implementation for the actual business logic.

### DatabaseClientLive

This library exposes the `live` implementation of the [DatabaseClient](#DatabaseClient).  From the beginning of
creating the `live` implementation I wanted to use more of the `vapor` interface as opposed to a very `stringy`
based approach to database interactions used by `pointfreeco`, as you can see by my [initial commit](https://github.com/m-housh/swift-web-playground/blob/07985c55f6ee0cae9a80024fa06b92500cb78154/Sources/DatabaseClientLive/Live.swift)

### DatabaseCrudHelpers

This is just some synactic sugar that came out of wanting to use more of the `vapor` interface, and can be 
somewhat easily developed into it's own package or dropped into another project for easier creation of 
CRUD interactions with the database.

### RouterUtils

This is some synactic sugar around the pointfree `Router` type. This should also be easily dropped into a project
or moved to it's own package.  This library integrates the [pointfreeco/swift-case-paths](https://github.com/pointfreeco/swift-case-paths), to allow the router to be generic over
the `Route` type that it matches on. As well as the [pointfreeco/swift-nonempty](https://github.com/pointfreeco/swift-nonempty) to ensure that path components are specified
when creating routers.

### ServerRouter

This is repsponsible for creating the actual router used by the application, using the [CrudRouter](#CrudRouter) 
library.

### SiteMiddleware

This is what implements the business logic once an incoming route / request has been matched by the 
[ServerRouter](#ServerRouter).  It is responsible for interacting with the database and returning a response.

### ServerBootstrap

This is responsible for parsing, loading, and implementing default values for the server environment, that help
the server parse / match route requests and connect to the database.

### EnvVars

These represent the environment values that are used by the [ServerBootstrap](#ServerBootstrap) library to
create the server environment.  For this simple project and the fact that this project won't be used in a
production environment, this may not have been necessary, but was good to explore.

### server

This is the actual executable that glues everything together and runs the server.

## Feedback

Any feedback, issues, pull-requests are welcome.  Stay tuned as I hopefully get an opportunity to lay out more
of my thoughts on the [swift-web](https://github.com/pointfreeco/swift-web) framework journey.


## Associated gists.

[Getting codecov/codecov-action to work](https://gist.github.com/m-housh/a1699d32477aefab85d185f4b677ea2e)
