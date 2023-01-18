Run Publify
```bash
$ bundle install
$ rake db:setup
$ rake db:migrate
$ rake db:seed
$ rake assets:precompile
$ SCOUT_DEV_TRACE=true rails server (run server with devTrace) 
```

Toxiproxy Setup
```bash
$ brew tap shopify/shopify
$ brew install toxiproxy
$ brew services start toxiproxy
$ toxiproxy-cli create -l localhost:22220 -u localhost:5432 postgres_proxy
```