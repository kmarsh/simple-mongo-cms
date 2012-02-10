## Simple Mongo CMS

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