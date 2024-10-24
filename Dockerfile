########################
FROM kalilinux/kali-rolling

# Add Kali repositories
RUN echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" > /etc/apt/sources.list

# Update package lists and install required packages
RUN apt-get update && apt-get install -y \
    kali-desktop-xfce \
    kali-linux-large \
    tightvncserver \
    git \
    && apt-get clean

# Install noVNC and websockify
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone https://github.com/novnc/websockify.git /opt/novnc/utils/websockify

# Set up root VNC user
RUN mkdir -p /root/.vnc && \
    echo "rootpassword" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Create .Xauthority file for root
RUN touch /root/.Xauthority && \
    chown root:root /root/.Xauthority

# Set up VNC startup script for root
RUN echo '#!/bin/sh\nstartxfce4 &' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Expose necessary ports (VNC and noVNC)
EXPOSE 5901 6080

# Set the USER environment variable for root
ENV USER=root

# Start VNC server and noVNC on container start
CMD ["bash", "-c", "\
    vncserver :1 -geometry 1360x760 -depth 24 && \
    /opt/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080"]
