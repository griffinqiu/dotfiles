thoughtbot dotfiles
===================

![prompt](http://images.thoughtbot.com/thoughtbot-dotfiles-prompt.png)

requirements
------------

set zsh as your login shell:

    chsh -s $(which zsh)

install
-------

clone onto your laptop:

    git clone git://github.com/thoughtbot/dotfiles.git ~/dotfiles

(or, [fork and keep your fork
updated](http://robots.thoughtbot.com/keeping-a-github-fork-updated)).

install [rcm](https://github.com/thoughtbot/rcm):

    brew tap thoughtbot/formulae
    brew install rcm

install the dotfiles:

    env rcrc=$home/dotfiles/rcrc rcup

after the initial installation, you can run `rcup` without the one-time variable
`rcrc` being set (`rcup` will symlink the repo's `rcrc` to `~/.rcrc` for future
runs of `rcup`). [see
example](https://github.com/thoughtbot/dotfiles/blob/master/rcrc).

this command will create symlinks for config files in your home directory.
setting the `rcrc` environment variable tells `rcup` to use standard
configuration options:

* exclude the `readme.md`, `readme-es.md` and `license` files, which are part of
  the `dotfiles` repository but do not need to be symlinked in.
* give precedence to personal overrides which by default are placed in
  `~/dotfiles-local`
* please configure the `rcrc` file if you'd like to make personal
  overrides in a different directory


update
------

from time to time you should pull down any updates to these dotfiles, and run

    rcup

to link any new files and install new vim plugins. **note** you _must_ run
`rcup` after pulling to ensure that all files in plugins are properly installed,
but you can safely run `rcup` multiple times so update early and update often!

make your own customizations
----------------------------

create a directory for your personal customizations:

    mkdir ~/dotfiles-local

put your customizations in `~/dotfiles-local` appended with `.local`:

* `~/dotfiles-local/aliases.local`
* `~/dotfiles-local/git_template.local/*`
* `~/dotfiles-local/gitconfig.local`
* `~/dotfiles-local/psqlrc.local` (we supply a blank `.psqlrc.local` to prevent `psql` from
  throwing an error, but you should overwrite the file with your own copy)
* `~/dotfiles-local/tmux.conf.local`
* `~/dotfiles-local/vimrc.local`
* `~/dotfiles-local/vimrc.bundles.local`
* `~/dotfiles-local/zshrc.local`
* `~/dotfiles-local/zsh/configs/*`

for example, your `~/dotfiles-local/aliases.local` might look like this:

    # productivity
    alias todo='$editor ~/.todo'

your `~/dotfiles-local/gitconfig.local` might look like this:

    [alias]
      l = log --pretty=colored
    [pretty]
      colored = format:%cred%h%creset %s %cgreen(%cr) %c(bold blue)%an%creset
    [user]
      name = dan croak
      email = dan@thoughtbot.com

your `~/dotfiles-local/vimrc.local` might look like this:

    " color scheme
    colorscheme github
    highlight nontext guibg=#060606
    highlight folded  guibg=#0a0a0a guifg=#9090d0

if you don't wish to install a vim plugin from the default set of vim plugins in
`.vimrc.bundles`, you can ignore the plugin by calling it out with `unplug` in
your `~/.vimrc.bundles.local`.

    " don't install vim-scripts/tcomment
    unplug 'tcomment'

`unplug` can be used to install your own fork of a plugin or to install a shared
plugin with different custom options.

    " only load vim-coffee-script if a coffeescript buffer is created
    unplug 'vim-coffee-script'
    plug 'kchmck/vim-coffee-script', { 'for': 'coffee' }

    " use a personal fork of vim-run-interactive
    unplug 'vim-run-interactive'
    plug '$home/plugins/vim-run-interactive'

to extend your `git` hooks, create executable scripts in
`~/dotfiles-local/git_template.local/hooks/*` files.

your `~/dotfiles-local/zshrc.local` might look like this:

    # load pyenv if available
    if which pyenv &>/dev/null ; then
      eval "$(pyenv init -)"
    fi

your `~/dotfiles-local/vimrc.bundles.local` might look like this:

    plug 'lokaltog/vim-powerline'
    plug 'stephenmckinney/vim-solarized-powerline'

zsh configurations
------------------

additional zsh configuration can go under the `~/dotfiles-local/zsh/configs` directory. this
has two special subdirectories: `pre` for files that must be loaded first, and
`post` for files that must be loaded last.

for example, `~/dotfiles-local/zsh/configs/pre/virtualenv` makes use of various shell
features which may be affected by your settings, so load it first:

    # load the virtualenv wrapper
    . /usr/local/bin/virtualenvwrapper.sh

setting a key binding can happen in `~/dotfiles-local/zsh/configs/keys`:

    # grep anywhere with ^g
    bindkey -s '^g' ' | grep '

some changes, like `chpwd`, must happen in `~/dotfiles-local/zsh/configs/post/chpwd`:

    # show the entries in a directory whenever you cd in
    function chpwd {
      ls
    }

this directory is handy for combining dotfiles from multiple teams; one team
can add the `virtualenv` file, another `keys`, and a third `chpwd`.

the `~/dotfiles-local/zshrc.local` is loaded after `~/dotfiles-local/zsh/configs`.

vim configurations
------------------

similarly to the zsh configuration directory as described above, vim
automatically loads all files in the `~/dotfiles-local/vim/plugin` directory. this does not
have the same `pre` or `post` subdirectory support that our `zshrc` has.

this is an example `~/dotfiles-local/vim/plugin/c.vim`. it is loaded every time vim starts,
regardless of the file name:

    # indent c programs according to bsd style(9)
    set cinoptions=:0,t0,+4,(4
    autocmd bufnewfile,bufread *.[ch] setlocal sw=0 ts=8 noet

what's in it?
-------------

[vim](http://www.vim.org/) configuration:

* [ctrl-p](https://github.com/ctrlpvim/ctrlp.vim) for fuzzy file/buffer/tag finding.
* [rails.vim](https://github.com/tpope/vim-rails) for enhanced navigation of
  rails file structure via `gf` and `:a` (alternate), `:rextract` partials,
  `:rinvert` migrations, etc.
* run many kinds of tests [from vim]([https://github.com/janko-m/vim-test)
* set `<leader>` to a single space.
* switch between the last two files with space-space.
* syntax highlighting for markdown, html, javascript, ruby, go, elixir, more.
* use [ag](https://github.com/ggreer/the_silver_searcher) instead of grep when
  available.
* map `<leader>ct` to re-index ctags.
* use [vim-mkdir](https://github.com/pbrisbin/vim-mkdir) for automatically
  creating non-existing directories before writing the buffer.
* use [vim-plug](https://github.com/junegunn/vim-plug) to manage plugins.

[tmux](http://robots.thoughtbot.com/a-tmux-crash-course)
configuration:

* improve color resolution.
* remove administrative debris (session name, hostname, time) in status bar.
* set prefix to `ctrl+s`
* soften status bar color from harsh green to light gray.

[git](http://git-scm.com/) configuration:

* adds a `create-branch` alias to create feature branches.
* adds a `delete-branch` alias to delete feature branches.
* adds a `merge-branch` alias to merge feature branches into master.
* adds an `up` alias to fetch and rebase `origin/master` into the feature
  branch. use `git up -i` for interactive rebases.
* adds `post-{checkout,commit,merge}` hooks to re-index your ctags.
* adds `pre-commit` and `prepare-commit-msg` stubs that delegate to your local
  config.
* adds `trust-bin` alias to append a project's `bin/` directory to `$path`.

[ruby](https://www.ruby-lang.org/en/) configuration:

* add trusted binstubs to the `path`.
* load the asdf version manager.

shell aliases and scripts:

* `b` for `bundle`.
* `g` with no arguments is `git status` and with arguments acts like `git`.
* `migrate` for `rake db:migrate && rake db:rollback && rake db:migrate`.
* `mcd` to make a directory and change into it.
* `replace foo bar **/*.rb` to find and replace within a given list of files.
* `tat` to attach to tmux session named the same as the current directory.
* `v` for `$visual`.

thanks
------

thank you, [contributors](https://github.com/thoughtbot/dotfiles/contributors)!
also, thank you to corey haines, gary bernhardt, and others for sharing your
dotfiles and other shell scripts from which we derived inspiration for items
in this project.

license
-------

dotfiles is copyright © 2009-2018 thoughtbot. it is free software, and may be
redistributed under the terms specified in the [`license`] file.

[`license`]: /license

about thoughtbot
----------------

![thoughtbot](http://presskit.thoughtbot.com/images/thoughtbot-logo-for-readmes.svg)

dotfiles is maintained and funded by thoughtbot, inc.
the names and logos for thoughtbot are trademarks of thoughtbot, inc.

we love open source software!
see [our other projects][community].
we are [available for hire][hire].

[community]: https://thoughtbot.com/community?utm_source=github
[hire]: https://thoughtbot.com/hire-us?utm_source=github
