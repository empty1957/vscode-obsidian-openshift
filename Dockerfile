<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
FROM squidfunk/mkdocs-material

COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
=======
=======
>>>>>>> theirs
=======
>>>>>>> theirs
=======
>>>>>>> theirs
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    KUBECONFIG=/etc/rancher/k3s/k3s.yaml \
    PATH=/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      bash ca-certificates curl iproute2 iptables jq less nano procps vim \
    && curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_START=true sh - \
    && ln -sf /usr/local/bin/kubectl /usr/bin/kubectl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY lab/ /opt/cka-sim/
RUN chmod +x /opt/cka-sim/*.sh \
    && ln -sf /opt/cka-sim/questions.sh /usr/local/bin/questions \
    && ln -sf /opt/cka-sim/grade.sh /usr/local/bin/grade \
    && ln -sf /opt/cka-sim/reset.sh /usr/local/bin/reset-lab \
    && ln -sf /opt/cka-sim/status.sh /usr/local/bin/status

WORKDIR /root
ENTRYPOINT ["/opt/cka-sim/entrypoint.sh"]
<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
>>>>>>> theirs
=======
>>>>>>> theirs
=======
>>>>>>> theirs
=======
>>>>>>> theirs
