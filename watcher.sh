#!/bin/sh
while true
do
    # 1. printf에 \r\n (CRLF) 적용
    # 2. nc의 -w 2 대신 timeout 2 명령어 활용
    if printf "GET / HTTP/1.0\r\n\r\n" | timeout 2 nc insideweb 80 | grep -q '200 OK'
    then
        echo "System up."
    else
        printf "To: admin@work Message: The service is down!" | nc insidemailer 33333
        echo "Alert sent."
    fi

    sleep 1
done