require './app'

header = <<LIQUID
<h1>&lt;form&gt; &amp;&amp; f(x)</h1>
LIQUID

home = <<LIQUID
{% include 'header' %}
<ul>
  {% for page in db.pages %}
  <li><a href="{{ page.path }}">{{ page.title }}</a></li>
  {% endfor %}
</ul>

<p>Welcome! Blah blah</p>
LIQUID

team = <<LIQUID
{% include 'header' %}
<h2>Team</h2>
<ul>
{% for person in db.team %}
  <li>{{ person.name }}</li>
{% endfor %}
</ul>
LIQUID

recent_work = <<LIQUID
{% include 'header' %}
<h2>Recent Work</h2>
<ul>
{% for project in db.projects %}
  <li>{{ project.title }}</li>
{% endfor %}
</ul>
LIQUID

$mongo = Mongo::Connection.new
$db = $mongo['smcms']

$db['snippets'].remove
$db['snippets'].insert('name' => 'header', 'body' => header)

$db['pages'].remove
$db['pages'].insert('path' => '/', 'title' => 'Home', 'body' => home)
$db['pages'].insert('path' => '/team', 'title' => 'Team', 'body' => team)
$db['pages'].insert('path' => '/recent-work', 'title' => 'Recent Work', 'body' => recent_work)

$db['projects'].remove
%w[CT OC PhotoBoard].each do |project|
  $db['projects'].insert('title' => project)
end

$db['team'].remove
%w[Paul Kevin Scott].each do |person|
  $db['team'].insert('name' => person)
end