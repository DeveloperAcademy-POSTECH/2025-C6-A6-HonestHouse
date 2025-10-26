### **1. 개요 (Overview)**

*   **프로젝트 명:** Bracket
*   **플랫폼 & 언어:** iOS (Swift, SwiftUI)
*   **앱 소개:** 캐논 카메라 사용자가 앱에 프리셋을 미리 설정하면 셔터를 누를 때 설정이 자동 변경되며 연속 촬영하여 수동 조작의 불편함을 덜어준다. 또한 연속 촬영으로 늘어난 사진들은 시공간적·시각적 유사도 기준으로 자동 그룹화하여 편하게 검토하고 아카이빙할 수 있다.

### **2. 페르소나 (Persona)**

*   **사용자:** 콘서트, 공연 등 조명이 수시로 변하는 환경에서 DSLR로 아티스트의 순간을 포착하는 사진가.
*   **사용 목표:** 급변하는 조명 아래에서도 놓치고 싶지 않은 순간을 원하는 색감과 설정으로 빠르게 담아내고, 결과물을 신속하게 모바일에서 확인 및 공유하는 것.
*   **주요 과업:**
    1.  무대 조명 변화에 맞춰 카메라의 조리개(Aperture), 셔터 속도(Shutter Speed), ISO, 화이트 밸런스(White Balance) 등 복잡한 설정을 실시간으로 변경.
    2.  결정적인 순간을 놓치지 않기 위해 다양한 설정으로 여러 장의 사진을 촬영.
    3.  촬영된 수많은 사진 중 '베스트 컷'을 선별하여 모바일로 전송 및 업로드.

### **3. 고충 (Pain Points)**

*   **번거로운 설정 변경:** 포착한 순간을 가장 잘 표현할 수 있는 색감으로 담아내고 싶지만, 매번 카메라 설정을 수동으로 바꾸며 원하는 색감을 찾는 과정이 번거롭고 시간이 오래 걸린다.
*   **사진 선별의 어려움:** 원하는 결과물을 얻기 위해 비슷한 장면을 다른 설정으로 반복 촬영하다 보니 사진 개수가 기하급수적으로 늘어나, 나중에 베스트 컷을 선별하고 관리하기가 매우 불편하다.

### **4. 솔루션 (Solution): "Tri-shot" 기능**

*   카메라의 '브라케팅(Bracketing)' 기능에서 아이디어를 얻었습니다. 브라케팅은 노출처럼 하나의 값을 다르게 조절하여 3장을 연속 촬영하는 방식입니다.
*   `Bracket` 앱은 이를 확장하여, 사용자가 조리개, 셔터 속도, ISO 등 여러 값을 조합한 **프리셋**을 미리 만들어두고, 셔터 한 번에 이 프리셋들이 적용된 사진 3장을 연속으로 촬영하는 **"Tri-shot"** 기능을 제공합니다. 이를 통해 사용자는 수동 조작 없이 한 번의 촬영으로 다양한 결과물을 얻을 수 있습니다.

### **5. 핵심 기능 (Main Features)**

*   **Tri-shot 촬영:** 사용자가 직접 설정한 커스텀 프리셋 또는 카메라 내장 필터를 이용하여 브라케팅 방식의 연속 촬영을 지원합니다.
*   **지능형 사진 그룹화 및 아카이빙:** 촬영된 사진들을 시공간적 정보와 이미지 시각적 유사도를 기준으로 자동 그룹화하여, 사용자가 유사한 사진들을 한눈에 비교하고 쉽게 베스트 컷을 선택하여 아카이빙할 수 있도록 돕습니다.

---

### **6. 프로젝트 폴더 구조**

```markdown
- .github/
  - ISSUE_TEMPLATE/
  - workflows/
- docs/
- HonestHouse/
  - HonestHouse/
    - Resources/
      - Color/
        - Color.swift
      - Font/
        - Font.swift
      - Image/
        - Assets.xcassets/
    - Sources/
      - App/
        - ContentView.swift
        - HonestHouseApp.swift
      - Core/
        - Managers/
          - Error/
            - VisionError.swift
          - VisionManager.swift
          - VisionManagerType.swift
        - Model/
          - 4.9. Shooting Settings/
          - AnalyzedPhoto.swift
          - Photo.swift
          - SimilarPhotoGroup.swift
        - Network/
          - CCAPI/
            - 4.9. Shooting Settings/
          - DigestAuth/
          - DTO/
            - Protocol/
            - Request/
            - Response/
          - Error/
          - Foundation/
          - Tri/
          - ImageLoader.swift
      - Extension/
        - Font+Extension.swift
      - General/
        - DIContainer.swift
        - Navigation/
      - Presentation/
        - Archive/
          - Component/
          - Shared/
          - View/
          - ViewModel/
        - Common/
        - RemoteController/
          - Component/
          - View/
          - ViewModel/
        - Trishoot/
          - Component/
          - View/
          - ViewModel/
      - Service/
        - CCAPI/
        - Services.swift
      - Type/
        - VersionType.swift
  - HonestHouse.xcodeproj/
- .coderabbit.yaml
- .gitignore
- PRD.md
- README.md
```

---

### 7. 핵심 기능과 기술 스택 (Core Features & Tech Stack)

이 섹션은 프로젝트의 핵심 기능들이 어떤 기술을 통해 구현되는지 명확히 정의하여, Gemini와 개발자 간의 원활한 소통과 협업을 돕기 위해 작성되었습니다.

#### 7.1. Tri-shot 연속 촬영 (Remote Shooting)

-   **설명:** 사용자가 정의한 여러 촬영 설정(프리셋)을 한 번의 셔터로 연속 촬영하게 하는 핵심 기능입니다.
-   **주요 기술:**
    -   **네트워킹 (`URLSession`, `Digest Authentication`):** Canon 카메라와의 실시간 통신(CCAPI)을 담당합니다.
    -   **UI (`SwiftUI`):** 촬영 프리셋 설정 및 원격 촬영을 위한 사용자 인터페이스를 제공합니다.
    -   **상태 관리 (`MVVM`):** 사용자의 인터랙션과 촬영 프로세스의 상태를 관리합니다.
-   **핵심 파일:**
    -   `Presentation/Trishoot/TrishootView.swift`: 사용자가 프리셋을 선택하고 촬영을 시작하는 메인 화면.
    -   `Presentation/Trishoot/TrishootViewModel.swift`: View의 상태를 관리하고, Service를 통해 카메라 제어 명령을 전달.
    -   `Service/CCAPI/ShootingSettingsService.swift`: 실제 카메라 촬영 및 설정을 제어하는 비즈니스 로직.
    -   `Core/Network/CCAPI/`: 카메라 제어를 위한 API 엔드포인트 및 요청/응답 정의.
-   **동작 흐름:**
    1.  **View:** 사용자가 `TrishootView`에서 촬영 버튼을 누릅니다.
    2.  **ViewModel:** `TrishootViewModel`이 정의된 프리셋 목록을 확인합니다.
    3.  **Service:** `ShootingSettingsService`를 통해 각 프리셋에 맞는 촬영 설정 변경 및 촬영 명령을 `CCAPI`로 순차적으로 전송합니다.

#### 7.2. 지능형 사진 그룹화 (Intelligent Grouping & Archiving)

-   **설명:** 연속 촬영으로 생성된 다수의 사진을 시공간적, 시각적 유사도를 기준으로 자동 그룹화하여 사용자의 사진 선별 작업을 돕는 기능입니다.
-   **주요 기술:**
    -   **이미지 분석 (`Vision Framework`):** 사진 간의 시각적 유사도를 계산하는 데 사용됩니다.
    -   **데이터 모델링 (`Swift Structs`):** 분석된 사진과 그룹의 정보를 구조화합니다.
    -   **UI (`SwiftUI`):** 그룹화된 사진을 효과적으로 보여주고 사용자가 선택할 수 있는 인터페이스를 제공합니다.
-   **핵심 파일:**
    -   `Core/Managers/VisionManager.swift`: Apple의 Vision 프레임워크를 사용하여 이미지의 특징(Feature Print)을 추출하고 비교하는 핵심 로직.
    -   `Core/Model/SimilarPhotoGroup.swift`: 유사한 사진들의 그룹을 나타내는 데이터 모델.
    -   `Presentation/Archive/GroupedPhotosView.swift`: 유사도에 따라 그룹화된 사진 앨범을 보여주는 뷰.
    -   `Presentation/Archive/PhotoSelectionView.swift`: 특정 그룹 내에서 베스트 컷을 확대하고 비교/선택하는 뷰.
-   **동작 흐름:**
    1.  **Manager:** `VisionManager`가 촬영된 사진들을 가져와 분석을 시작합니다.
    2.  **Analysis:** 각 사진의 생성 시간, GPS 정보(시공간적)와 Vision Feature Print(시각적)를 추출하여 유사도를 계산합니다.
    3.  **Model:** 유사도가 높은 사진들을 `SimilarPhotoGroup` 객체로 묶습니다.
    4.  **ViewModel & View:** `GroupedPhotosViewModel`이 이 그룹 데이터를 받아 `GroupedPhotosView`에 시각적으로 표시합니다.

---

### 8. AI 협업 가이드라인

#### 핵심 원칙

- **프로젝트 우선 원칙**: 모든 기술적 결정, 코드 생성, 답변은 이 PRD에 정의된 프로젝트의 목표와 명세를 근본적으로 기반해야 합니다.

#### CLI 컨텍스트 가이드라인

##### 코드 품질 및 원칙

- **SOLID 원칙 준수**: SOLID 원칙을 준수합니다.
- **코드 주석 정책**: 최종 코드 및 예시 코드에는 주석을 사용하지 않습니다. (단, 로깅을 위한 간단한 영문 에러 메시지는 예외)
- **데이터 사용**: Mock 데이터는 테스트 환경에서만 사용합니다.

##### 기술 스택 관리

- **핵심 기술 스택**: Swift, SwiftUI를 고정 기술 스택으로 사용하며, 사용자의 명시적인 요청 없이는 대안 기술을 제안하거나 사용하지 않습니다.
- **기술 스택 일관성**: 사용자 승인 없이 기술 스택을 변경하지 않으며, 호환되지 않는 의존성을 도입하지 않습니다.

##### 워크플로우 및 프로세스

- **테스트 전략**: 주요 기능에 대한 전체 테스트 커버리지를 목표로 하며, 예외 케이스를 포함한 테스트를 작성합니다.
- **코드 수정 워크플로우**:
    - **AI (제안자)**: AI는 코드 변경을 분석하고 제안합니다. AI는 'TO-BE' 코드를 제시하지만 파일에 직접 쓰지 않습니다.
    - **사용자 (구현자)**: 사용자는 AI의 제안에 따라 코드를 수정하는 유일한 주체입니다.
    - **검증 루프**: 사용자가 수정 완료를 확인하면, AI는 다음 단계로 진행하기 전에 파일 내용을 다시 읽어 변경사항이 올바르게 적용되었는지 확인해야 합니다.
- **컨텍스트 요약 워크플로우**:
    - AI 또는 사용자의 요청에 따라 컨텍스트 요약을 진행합니다.
    - 요약 내용은 Notion과 로컬 `context-summary.md` 파일에 저장되며, 이후 AI는 이 요약 파일을 기준으로 작업을 진행합니다.

#### 커뮤니케이션 원칙

- **AI-사용자 상호작용**: 모든 AI 응답은 컨텍스트를 이해했음을 확인하는 의미로 `🍎` 이모지로 시작해야 합니다.
- **계획 및 승인**: 아키텍처 변경 등 큰 변경 작업 전에는 구현 계획을 먼저 제시하고 승인을 받습니다.
- **진행 상황 추적**: 완료된 작업, 진행 중인 작업, 다음 작업을 명확히 구분하여 상태를 투명하게 공유합니다.

#### 실행 가이드라인

- **응답 형식**:
```
🍎

## 현재 상태
- 완료: [완료된 작업 목록]
- 진행 중: [현재 작업]
- 대기: [다음 작업]

## 구현
[실제 구현 또는 계획]

## 다음 단계
[예정된 작업]
```
- **품질 체크리스트**:
  - [ ] SOLID 원칙 준수
  - [ ] 테스트 케이스 포함
  - [ ] 기술 스택 일관성 유지
  - [ ] 사용자 승인 요구사항 확인
