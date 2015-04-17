lagasafn-tools: Convert archives of Icelandic law into a git repository
=======================================================================

lagasafn-tools downloads zip archives of Icelandic law from althingi.is and converts to a git repository. [See this respository as an example output](https://github.com/nifgraup/lagasafn).

Usage
-----

    sudo apt-get install git tidy pandoc parallel
    git clone https://github.com/nifgraup/lagasafn-tools.git
    cd lagasafn-tools
    make prepare
    make
    make push
