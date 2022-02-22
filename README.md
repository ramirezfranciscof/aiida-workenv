# aiida-workenv

Easy to download work environment template for AiiDA.
Originally based on the [`aiida-prerequisites'](https://github.com/aiidateam/aiida-prerequisites) image builder.

This docker file will run the containers to generate an AiiDA work env.

Relevant commands:

```
$ docker-compose up -d
$ docker exec -it aiida /bin/bash
$ docker-compose down -v

$ docker-compose -p "stack_name" up -d
$ docker-compose -p "stack_name" down -v
```

