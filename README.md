TODO:
- Add ability for rails to read env file
- Make stripe id in config/secrets.yml reference and env variable
- Write model method to query the data field to determine if I need to
call the API or not
- Return array of events from the find_all_* method
- Add unit tests
- Add functional tests
- Event.where("(data ->> 'created')::int > ?", 1452464455).count


QUESTIONS:
- Will response time out before API responds with all of the data?

UNIQUE FEATURES:
- Set stripe_id via an environment variable. Because we're working with
one customer at a time and in a support scenario, this variable can be
manually set for each request thus limiting account details to the
interwebs.

