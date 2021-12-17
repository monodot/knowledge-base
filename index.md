---
# You don't need to edit this file, it's empty on purpose.
# Edit theme's home layout instead if you wanna make some changes
# See: https://jekyllrb.com/docs/themes/#overriding-theme-defaults
layout: home
---

# Welcome

This site is a personal _wiki_ of knowledge that I've collected across lots of different tech topics, from programming to system administration. It's a collection of stuff I've learned, and want to share.

I try to keep it updated whenever I'm working on something new, **but** you might find that info on some topics is a little out-of-date, especially if I've not worked with that technology for a while.

For more info about this site, [check out the about page][about].

# A-Z of Articles

<ul>

    {% assign pages_list = site.articles | sort:"title" %}
    {% for page in pages_list %}
    {% unless page.url contains "private/" %}
      {% if page.title %}
        <li>
          <a href="{{ page.url | relative_url }}">{{ page.title | escape }}</a>
        </li>
      {% endif %}
    {% endunless %}
  {% endfor %}
</ul>


[about]: {{ site.baseurl }}{% link about.md %}
