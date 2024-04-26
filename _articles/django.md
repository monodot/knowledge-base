---
layout: page
title: Django
---

## Third-party plugins

### Django-organizations

Define a link from your model to the `organizations.Organization` model:

```py
class Box(models.Model):
    org = models.ForeignKey(
        'organizations.Organization',
        on_delete=models.CASCADE,
        related_name='boxes',
    )
    # Then your model attributes go here...
```

Then ensuring your ListView only shows `Box` objects from an `org` that the user is part of:

```py
class BoxListView(ListView):
    model = Box

    def get_queryset(self):
        return Box.objects.filter(org__users=self.request.user)
```

Then you can render a list in `box_list.html`:

{% raw %}
```html
{% block content %}
  <h1>Box List</h1>
  {% if object_list %}
    <ul>
      {% for box in object_list %}
      <li>
        <a href="{% url 'box_detail' box.id %}">{{ box.title }} (Team: {{ box.org }})</a>
      </li>
      {% endfor %}
    </ul>
  {% else %}
    <p>Your team currently has no boxes. Would you like to create one?</p>
  {% endif %}
{% endblock %}
```
{% endraw %}
