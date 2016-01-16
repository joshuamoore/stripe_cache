TODO:
- Write model method to query the data field to determine if I need to
call the API or not
- Return array of events from the find_all_* method

- Add unit tests
- Add functional tests

- Add support for responding to stripe's response codes
- Pass anything it can’t handle through to Stripe and merely
returning the results without caching


FUTURE WORK:
- be able to use Stripe webhooks to update data within the cache
- be able to tell us which access tokens it has data for and how much
    data it has
- be able to clear out data for a particular access token
- be able to cache data for as long as we’d like


QUESTIONS:
- Will response time out before API responds with all of the data?

UNIQUE FEATURES:
- Set stripe_id via an environment variable. Because we're working with
one customer at a time and in a support scenario, this variable can be
manually set for each request thus limiting account details to the
interwebs.
- Stripe response is stored as JSON and queried using Posgres' JSON
operators

