#!/bin/sh
while true
do
    # 1. printf에 \r\n (CRLF) 적용
    # 2. nc의 -w 2 대신 timeout 2 명령어 활용
    if printf "GET / HTTP/1.0\r\n\r\n" | timeout 2 nc $INSIDEWEB_PORT_80_TCP_ADDR $INSIDEWEB_PORT_80_TCP_PORT | grep -q '200 OK'
    then
        echo "System up."
    else
        printf "To: admin@work Message: The service is down!" | nc $INSIDEMAILER_PORT_33333_TCP_ADDR $INSIDEMAILER_PORT_33333_TCP_PORT
        echo "Alert sent."
    fi

    sleep 1
done