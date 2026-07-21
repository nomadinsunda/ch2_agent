# 사용된 리눅스 커맨드 설명

이 문서는 `Dockerfile`과 `watcher.sh`에서 사용된 모든 리눅스 커맨드/셸 구문을 순서대로 설명합니다. 이 이미지는 `busybox` 베이스이므로, 각 명령어는 GNU coreutils가 아닌 **BusyBox의 내장(applet) 버전**으로 동작합니다. 옵션이 일부만 지원될 수 있다는 점을 참고하세요.

## Dockerfile

### `adduser -DHs /bin/sh example`

새 사용자 계정을 만드는 명령어입니다. 컨테이너를 root가 아닌 별도 계정으로 실행하기 위해 사용합니다.

- `-D` : 비밀번호 없이 계정을 생성합니다 (Disabled password). 컨테이너 안에서는 로그인 인증이 필요 없으므로 비밀번호를 두지 않습니다.
- `-H` : 홈 디렉터리를 만들지 않습니다 (No Home). 이 계정은 셸 스크립트 하나만 실행하면 되므로 홈 디렉터리가 불필요합니다.
- `-s /bin/sh` : 로그인 셸을 `/bin/sh`로 지정합니다. BusyBox 이미지에는 `/bin/bash`가 없으므로 반드시 실제 존재하는 셸을 지정해야 합니다.
- `example` : 생성할 사용자 이름입니다.

### `chown example watcher.sh`

`watcher.sh` 파일의 소유자를 `example` 사용자로 바꿉니다. 이후 `USER example`로 전환해서 실행할 것이므로, 그 계정이 파일을 읽고 실행할 수 있어야 합니다.

### `chmod a+x watcher.sh`

`watcher.sh`에 실행 권한을 부여합니다.

- `a+x` : all(모든 사용자)에게 실행(execute) 권한을 추가합니다.

### `USER example`

이후의 `RUN`/`CMD` 명령이 root가 아닌 `example` 계정 권한으로 실행되도록 지정합니다. 불필요하게 root 권한으로 컨테이너를 띄우지 않기 위한 보안 관례입니다.

## watcher.sh

### `#!/bin/sh`

셔뱅(shebang) 라인입니다. 이 스크립트를 `/bin/sh`(BusyBox의 ash 셸)로 실행하라는 뜻입니다.

### `while true; do ... done`

셸의 무한 루프 구문입니다. `true` 명령은 항상 성공(종료 코드 0)을 반환하므로, `done`을 만날 때까지의 블록이 계속 반복 실행됩니다. 워처(watcher)답게 서비스를 계속 감시하기 위한 구조입니다.

### `printf "GET / HTTP/1.0\r\n\r\n"`

문자열을 표준출력으로 출력하는 명령어입니다. `echo`와 비슷하지만 형식 문자열을 명시적으로 다루기 때문에 이스케이프 시퀀스(`\r\n`)를 안정적으로 넣을 수 있습니다. 여기서는 HTTP/1.0 GET 요청 메시지를 사람이 직접 조립해서 만들고 있습니다 (`\r\n\r\n`은 HTTP 요청의 헤더 종료를 의미하는 CRLF 두 번).

### `timeout 2 nc insideweb 80`

- `timeout 2 <명령어>` : 뒤에 오는 명령어를 최대 2초 동안만 실행하고, 초과하면 강제 종료합니다. 응답이 없는 서버 때문에 스크립트가 무한정 멈추는 것을 방지합니다.
- `nc insideweb 80` (netcat) : `insideweb`라는 호스트의 80번 포트로 TCP 연결을 맺는 명령어입니다. 파이프(`|`)로 들어온 입력(GET 요청 문자열)을 그대로 전송하고, 서버 응답을 표준출력으로 받아옵니다. 여기서 `insideweb`는 `docker run --link web:insideweb`로 생성되는 `/etc/hosts`상의 별칭입니다.

### `grep -q '200 OK'`

입력에서 `200 OK` 문자열을 찾는 명령어입니다.

- `-q` : quiet 모드로, 찾은 결과를 출력하지 않고 매치 여부만 종료 코드로 반환합니다 (찾으면 0, 못 찾으면 1). `if` 조건문에서 이 종료 코드를 그대로 참/거짓 판단에 사용합니다.

### `if ... then ... else ... fi`

셸의 조건문 구문입니다. `if` 뒤에 오는 명령(여기서는 `printf | timeout ... | grep -q`로 이어지는 파이프라인)의 종료 코드가 0이면 `then` 블록을, 그렇지 않으면 `else` 블록을 실행합니다.

### `echo "System up."` / `echo "Alert sent."`

문자열을 표준출력에 출력해서 컨테이너 로그(`docker logs`)에 현재 상태를 남깁니다.

### `nc insidemailer 33333`

장애가 감지됐을 때 `insidemailer` 호스트의 33333번 포트로 알림 메시지를 전송합니다. `insideweb`와 마찬가지로 `--link mailer:insidemailer`로 생성된 별칭입니다.

### `sleep 1`

1초 대기합니다. 루프가 너무 빠르게 반복되며 CPU와 네트워크 자원을 낭비하지 않도록 매 검사 사이에 간격을 둡니다.

## 파이프(`|`)

여러 명령어를 연결할 때 쓰는 셸 연산자로, 앞 명령어의 표준출력을 뒤 명령어의 표준입력으로 그대로 흘려보냅니다. 이 스크립트에서는 `printf`(요청 생성) → `nc`(전송/수신) → `grep`(응답 검사)로 이어지는 파이프라인을 구성합니다.
