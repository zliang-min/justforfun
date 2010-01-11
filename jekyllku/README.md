## Install
    gem install jekyllku

## Usage
Run `jekyllku [your_blog_name]`. Then a classic-jekyll-blog-like directory hi is created for you. Open the `config.ru` file with your favourite text-editor, and modify it until it satisfies you. Once you are done, upload your code to Heroku.

When your upload finished, run `heroku rake db:migrate` to generate the db schema. Then open your favourite browser, go to your app home on Heroku, and setup a web hook. And that's it!

Now, write your index page, maybe create some layouts, and compose some posts, then push them to Heroku, and your blog is automatically generated!
