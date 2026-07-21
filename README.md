```shell
$ git clone https://github.com/nomadinsunda/ch2_agent.git
$ cd ch2_agent

$ docker login -u <username>

$ docker build -t docker.io/intheeast0305/ch2_agent:latest .
$ docker push docker.io/intheeast0305/ch2_agent:latest
```

## Windows에서 개행 문자(CRLF) 주의사항

`Dockerfile`과 `watcher.sh`는 유닉스 계열(LF) 개행 문자를 전제로 작성되어 있습니다. Windows에서 파일을 열어 수정하면 편집기가 자동으로 CRLF(`\r\n`)로 저장하는 경우가 많은데, 이렇게 되면 다음과 같은 문제가 발생할 수 있습니다.

- `watcher.sh`의 셔뱅(`#!/bin/sh`) 뒤에 `\r`이 섞여 컨테이너 실행 시 `no such file or directory` 등의 오류가 발생
- 스크립트 내 명령어 줄 끝에 `\r`이 붙어 `nc`, `timeout` 등 명령어가 제대로 파싱되지 않음

### Notepad++ 사용 시

1. 파일을 연 상태에서 상단 메뉴 **편집(Edit) → EOL 변환(Convert to EOL)** 또는 **줄바꿈 문자(Line Ending)** 메뉴로 이동합니다. (버전에 따라 메뉴명이 다를 수 있습니다.)
2. **Unix (LF)** 를 선택합니다.
3. 저장 후 `git diff`로 개행 문자가 CRLF로 바뀌지 않았는지 확인합니다.

새로 파일을 만들 때도 저장 전에 우측 하단 상태 표시줄에서 현재 EOL 모드가 **Unix (LF)** 로 되어 있는지 미리 확인하는 것이 안전합니다.

### 참고: Git 설정으로 방지하기

`git config core.autocrlf false` (또는 `input`)로 설정해두면 Git이 커밋/체크아웃 시 개행 문자를 임의로 변환하지 않아, 편집기 설정 실수로 인한 CRLF 유입을 줄일 수 있습니다.

## 사용된 리눅스 커맨드 설명

`Dockerfile`과 `watcher.sh`에 등장하는 모든 리눅스 커맨드에 대한 설명은 [COMMANDS.md](./COMMANDS.md)를 참고하세요.
