# Rotating Dot Man

Ruby와 SDL2로 만든 작은 3D 점군 데모입니다. 사람 모양의 점들을 실제 3D 좌표로 구성한 다음 Y축으로 회전시키고, 원근 투영해서 2D 창에 표시합니다. 점의 무지개색은 회전이 멈춰 있어도 계속 흐릅니다.

## 조작

- `Space`: 회전 시작 / 현재 각도에서 일시 정지
- `Esc`: 종료
- 창 닫기 버튼: 종료

프로그램은 회전이 멈춘 상태로 시작합니다. 화면에는 조작 안내나 회전축을 표시하지 않습니다.

## 설치

Ruby 3.1 이상과 SDL2 네이티브 라이브러리가 필요합니다.

macOS(Homebrew):

```sh
brew install sdl2
bundle install
```

Ubuntu/Debian:

```sh
sudo apt install libsdl2-dev
bundle install
```

`ruby-sdl2` 설치 중 SDL_image, SDL_mixer, SDL_ttf 관련 기능이 필요한 환경에서는 해당 개발 패키지도 함께 설치할 수 있습니다. 이 데모 자체는 기본 SDL2 비디오/이벤트 기능만 사용합니다.

## 실행

```sh
bundle exec ruby bin/dot_man
```

## 테스트

SDL 창을 띄우지 않고 점군 생성, 회전, 원근 투영, 색상 계산을 테스트합니다.

```sh
bundle exec rake test
```

## 주요 설정

- 창 크기: `800 x 600`
- 목표 프레임: `60 FPS`
- 회전 속도: 한 바퀴에 약 4초
- 렌더링: 깊이순 정렬, 원근 크기 변화, 깊이에 따른 밝기/투명도 변화
