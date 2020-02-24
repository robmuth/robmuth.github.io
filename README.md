# Welcome
Welcome to my personal blog. Please have a look at my recent posts:

<ul>		
   {% for post in site.posts limit:25 %}		
     <li>		
       {{ post.date | date_to_string: "ordinal", "DE" }}: <a href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a>		
     </li>		
   {% endfor %}		
</ul>

## Contact
You can find me on [Keybase.io](https://keybase.io/rmuth)
