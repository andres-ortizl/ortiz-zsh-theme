Smiley

A fork of the [eriner](https://github.com/zimfw/eriner) theme.

I just wanted to make the theme more simpler and also add the feature for measuring the elapsed time between commands
and the k8s context in case I've my `KUBECONFIG` var set.

### home

![home](./img/default.png)

### basic git

![basic](./img/git.png)

### error

![error](./img/err.png)

### virtualenv

![venv](./img/venv.png)

### k8s context-namespace

![k8s](./img/kubernetes.png)

### virtualenv + k8s

![venv](./img/venv.png)

## Configuration

| Variable                  | Description                                                                                           | Default value |
|---------------------------|-------------------------------------------------------------------------------------------------------|---------------|
| `STATUS_COLOR`            | Status segment color                                                                                  | 140           |
| `PWD_COLOR`               | Working directory segment color                                                                       | 140           |
| `CLEAN_COLOR`             | Clean `git` working tree segment color                                                                | 191           |
| `DIRTY_COLOR`             | Dirty `git` working tree segment color                                                                | 220           |
| `SEP`                     | Separator for the status segments                                                                     | ▲             |
| `FULL_PATH_VIRTUAL_ENV`   | I usually don't care about the full path or name of the virtualenv, if you want the name put a 1 here | 0             |
| `KUBERNETES_COLOR_PROMPT` | Kubernetes context-namespace color. I'm using `kubens` & `kubectx`                                    | 033           |
| `SHOW_ARCH`               | Show the architecture of the machine                                                                  | 0             |  

There's a function called `print_available_colors` if you want to check the available colors

## Installation with zim

Add this line in your `~/.zimrc` file:

```zsh
zmodule https://github.com/andres-ortizl/ortiz-zsh-theme.git --name ortiz
```

