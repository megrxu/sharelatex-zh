FROM sharelatex/sharelatex:latest

# Set the timezone, some of the packages need timezone to setup
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install the common packages
# Uncomment to change the `sources.list`
# RUN sed -i 's/archive.ubuntu.com/mirrors.zju.edu.cn/g' /etc/apt/sources.list
RUN apt update
RUN apt install -y texlive-xetex texlive-latex-extra texlive-lang-chinese texlive-science texlive-latex-recommended texlive-fonts-recommended texlive-fonts-extra

# Some other Chinese fonts && rebuild the font cache
RUN mkdir -p ~/.local/share/fonts
RUN for i in simhei.ttf simkai.ttf simsun.ttc simsunb.ttf simfang.ttf; do wget -P ~/.local/share/fonts/ https://xugr.keybase.pub/static/fonts/$i; done
RUN fc-cache -rv