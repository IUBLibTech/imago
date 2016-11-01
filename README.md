# Imago
Imago is a instance of Sufia 7, customized to work with data from the Center for Biological Research Collections (CBRC) at Indiana University. See http://www.iu.edu/~cbrc/ for more details about the collections themselves.

This project is currently based on Sufia 7.0.

## Installation
* Check out this project
* In the config directory, change the names of the files that end with "-template" to remove the "-template" part, and fill in appropriate values
* Run 'bundle install' and 'rake db:migrate'
* Create users (see below).

Note that this project disabled creating new users from within the interface. To create a user, run the following in the rails console:

```
u = User.create!({:email => "example@example.com", :password => "11111111", :password_confirmation => "11111111" })
```
To run the batch image ingest rake task:

```
rake cbrc:import:import_herbs[samples/samplefiles.csv,example@example.com]
```

