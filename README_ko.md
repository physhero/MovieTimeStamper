# MovieTimeStamper 🕒🎬

[🇺🇸 English](README.md) | 🇰🇷 한국어

> **macOS 전용 독립형 동영상 타임스탬프 자동 각인 도구 (Droplet Utility)**  
> 복잡한 터미널 명령어와 별도 프로그램 설치 없이, 동영상을 끌어다 놓기만 하면 촬영 일시를 영상 상단에 정밀하게 합성합니다.

[![Platform](https://img.shields.io/badge/Platform-macOS%20%28Apple%20Silicon%20%2F%20Intel%29-blue?logo=apple)]()
[![Engine](https://img.shields.io/badge/Engine-FFmpeg%20%28Bundled%29-green?logo=ffmpeg)]()
[![Support](https://img.shields.io/badge/Support-ed.or.kr-orange)](https://ed.or.kr/2026/10/18/movietimestamper01/)

---

## 📌 주요 특징

* **무설치 독립형 번들 (Zero Dependency)**  
  Homebrew나 MacPorts 같은 패키지 매니저나 FFmpeg를 별도로 설치할 필요가 없습니다. 앱 내부에 고정(Static) 바이너리가 포함되어 있어 다운로드 즉시 구동됩니다.
* **스마트 메타데이터 추출 및 KST 자동 보정**  
  `ffprobe`를 통해 영상 컨테이너의 표준 생성 시각(`creation_time`, UTC)을 읽어 한국 표준시(KST, UTC+9)로 자동 환산합니다. 메타데이터가 없는 파일은 파일 자체의 생성/수정 시각을 대체값으로 사용합니다.
* **Apple Silicon / Intel 하드웨어 가속**  
  macOS 네이티브 `h264_videotoolbox` 인코더를 활용하여 CPU 점유율을 최소화하고 초고속으로 인코딩합니다. (`-pix_fmt yuv420p` 호환성 적용으로 10-bit 및 HDR 영상 변환 오류 방지)
* **직관적인 드롭릿(Droplet) UI**  
  앱 창 위로 단일 파일 또는 여러 개의 동영상을 한꺼번에 드래그 앤 드롭하면 순차적으로 일괄 변환(Batch Processing)됩니다.
* **권한 자동 진단**  
  macOS 보안 정책상 필수적인 '전체 디스크 접근 권한(Full Disk Access)' 유무를 스스로 검사하여 설정 창으로 바로 연결해 줍니다.
* **고정폭(Monospace) 폰트 각인**  
  Apple 시스템 서체인 `Menlo`와 반투명 배경 박스를 적용하여 초 단위가 변경될 때 글자 떨림(Jittering) 현상 없이 깔끔하게 각인됩니다.

---

## 💻 시스템 요구 사양

* **운영체제**: macOS 11.0 (Big Sur) 이상 권장
* **아키텍처**: Apple Silicon (M1/M2/M3/M4) 및 Intel x86_64 지원
* **필수 권한**: 시스템 설정 > 개인정보 보호 및 보안 > **전체 디스크 접근 권한**

---

## 🚀 다운로드 및 설치 방법

### 1. 앱 다운로드
우측 사이드바의 **[Releases]** 탭에서 최신 버전의 `MovieTimeStamper.zip`을 다운로드하고 압축을 해제합니다.

### 2. '확인되지 않은 개발자' 경고 해결 (최초 1회)
Apple 공인 인증서 없이 서명된 개인 빌드 앱이므로, 다운로드 후 더블클릭 시 보안 경고가 뜰 수 있습니다.
* **방법 A**: 앱 아이콘을 **우클릭(또는 Control + 클릭)**한 뒤 **[열기]**를 선택하고, 팝업 창에서 다시 **[열기]**를 클릭합니다.
* **방법 B (권장)**: 터미널을 열고 격리 속성(Quarantine)을 제거합니다.
  ```bash
  xattr -cr /path/to/MovieTimeStamper.app
  ```

### 3. 전체 디스크 접근 권한 부여
앱을 처음 실행하면 권한 안내 대화상자가 표시됩니다.
1. 안내 팝업에서 **[Open Settings]**를 클릭합니다.
2. Mac 시스템 설정의 `개인정보 보호 및 보안 > 전체 디스크 접근 권한` 목록으로 이동합니다.
3. `MovieTimeStamper` 스위치를 **켬(활성화)** 상태로 변경합니다. (목록에 없다면 하단 `+` 버튼으로 앱 추가)
4. 앱을 완전히 종료(`Command + Q`)한 후 다시 실행합니다.

---

## 📖 사용 방법

1. `MovieTimeStamper.app`을 실행합니다.
2. 진행 창에 `Ready! Drag and drop video files onto this window.` 문구가 표시됩니다.
3. 타임스탬프를 입힐 영상 파일들을 마우스로 잡고 **진행 창 내부로 끌어다 놓습니다**.
4. 자동으로 하단 상세 로그 서랍(`Details`)이 펼쳐지며 인코딩 진행률과 세부 정보가 출력됩니다.
5. 변환이 완료되면 원본 파일과 동일한 폴더에 `[파일명]_timestamped.mp4` 파일이 생성됩니다.

---

## 🛠 기술적 워크플로우

```text
[동영상 파일 드롭] 
       │
       ▼
[ffprobe] creation_time 메타데이터 파싱
       │
       ├── 메타데이터 존재: UTC 파싱 후 +32400초 (KST 보정)
       └── 메타데이터 부재: macOS stat 명령어로 파일 생성/수정일 보정
       │
       ▼
[ffmpeg drawtext 필터 합성]
  - 서체: /System/Library/Fonts/Menlo.ttc (28pt, White)
  - 배경: 반투명 블랙 박스 (Box Alpha 0.5)
  - 위치: 상단 중앙 (x=(w-text_w)/2, y=20)
       │
       ▼
[하드웨어 인코딩]
  - 비디오 코덱: h264_videotoolbox (비트레이트: 5Mbps, yuv420p)
  - 오디오 코덱: 원본 스트림 복사 (-c:a copy)
       │
       ▼
[완료 대화상자 호출 및 피드백 링크 제공]
```

---

## ❓ 문제 해결 (Troubleshooting)

* **변환 진행 바가 차오르지 않고 바로 멈추는 경우**  
  전체 디스크 접근 권한이 적용되지 않았을 가능성이 높습니다. 시스템 설정에서 권한을 껐다 다시 켜고 앱을 재실행해 보세요.
* **변환 실패 안내창이 떴을 때**  
  바탕화면(`~/Desktop`)에 생성된 `FFmpeg_Error_Log.txt` 파일을 열면 상세한 FFmpeg 로그를 확인할 수 있습니다. 영상 코덱 파손 여부나 파일 손상 상태를 점검하세요.

---

## 💬 문의 및 피드백

버그 제보, 기능 개선 아이디어, 사용 중 발생한 문의 사항은 공식 서포트 블로그 페이지에 남겨주시면 확인 후 답변을 드립니다.

* **공식 서포트 및 질문 게시판**: [https://ed.or.kr/2026/10/18/movietimestamper01/](https://ed.or.kr/2026/10/18/movietimestamper01/)

---

## 📄 라이선스 (License)

* 본 프로젝트의 래퍼 스크립트 및 UI 패키징은 오픈소스로 자유롭게 수정 및 참고할 수 있습니다.
* 번들링된 **FFmpeg** 및 **ffprobe** 바이너리는 [FFmpeg 프로젝트](https://ffmpeg.org/)의 LGPL/GPL 라이선스를 준수합니다.