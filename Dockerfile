FROM alpine:3.7 as builder

RUN apk --no-cache add \
		bash \
		curl \
		g++ \
		git \
		make \
		openssl-dev

RUN mkdir -p /usr/src/udr \
	&& git clone https://github.com/LabAdvComp/UDR.git /usr/src/udr \
	&& cd /usr/src/udr \
	&& make -e os=LINUX arch=AMD64



FROM alpine:3.7

RUN apk --no-cache add \
		bash \
		curl \
		libcrypto1.0 \
		libgcc \
		libstdc++ \
		openssh-server \
		openssh-client \
		python \
		rsync \
		supervisor \
		tini

RUN mkdir -p /udr /workspace /root/.ssh

COPY --from=builder /usr/src/udr/src/udr /bin/
COPY --from=builder /usr/src/udr/server/daemon.py /udr/
COPY --from=builder /usr/src/udr/server/udrserver.py /udr/

RUN sed -i s/#PermitRootLogin.*/PermitRootLogin\ without-password/ /etc/ssh/sshd_config \
 && sed -i s/#PasswordAuthentication.*/PasswordAuthentication\ no/ /etc/ssh/sshd_config

COPY docker-entrypoint.sh /

ENV KEYS_URL https://github.com/jtilander.keys

WORKDIR /workspace

EXPOSE 22
EXPOSE 9000/udp

ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
CMD ["daemon"]
