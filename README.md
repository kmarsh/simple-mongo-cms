Simple Mongo CMS [![Build Status](https://secure.travis-ci.org/willcodeforfoo/simple-mongo-cms.png)](http://travis-ci.org/willcodeforfoo/simple-mongo-cms)
================

SMCMS aims to be a simple, MongoDB driven CMS. Really just enough to pull data
out of a MongoDB database with [Liquid] and [Markdown] templates.

### Example Template

    {% include 'header' %}
    <h2>Our Team</h2>
    <ul>
    {% for person in db.team %}
      <li>{{ person.name }}</li>
    {% endfor %}
    </ul>
    {% include 'footer' %}

### TODO

* Get specs running
* Figure out liquid performance issues
* Come up with a better name

[Liquid]: https://github.com/Shopify/liquid
[Markdown]: http://daringfireball.net/projects/markdown/

### Contributing

- Fork the project.
- Make your feature addition or bug fix.
- Add specs for it. This is important so I don't break it in a future version unintentionally.
- Commit, do not mess with Rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself in another branch so I can ignore when I pull)
- Send me a pull request. Bonus points for topic branches.

### Copyright

Copyright © 2012 Kevin Marsh. See [MIT-LICENSE](http://github.com/willcodeforfoo/simple-mongo-cms/blob/master/MIT-LICENSE) for details.