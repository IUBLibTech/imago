# cbrc-sufia7
Imago application.

This code represents a project to put data from the Center for Biological Research Collections (CBRC) at Indiana University into a digital repository. See http://www.iu.edu/~cbrc/ for more details about the collections themselves.

In its current form, this code works by first installing an out-of-the-box Sufia installation and overwriting the code from this repository. This can be done by following the instructions for installaing Sufia 7.0 here: https://github.com/projecthydra/sufia/tree/v7.0.0. Then, before starting the application, overwrite the contents of this project directly over the application, overwriting the existing files.

Note that this project disabled creating new users from within the interface. To create a user, run the following in the rails console:

```
u = User.create!({:email => "example@example.com", :password => "11111111", :password_confirmation => "11111111" })
```
To run the image ingest rake task:

```
rake cbrc:import:import_herbs[import_data/20151013_upload.csv,example@example.com]
```

