# Amazon Nova Integration — CycleGlow Product Scanner

## Overview

CycleGlow uses **Amazon Nova Lite** (multimodal) via **Amazon Bedrock** to analyze skincare product photos. The AI reads ingredient labels from product photos and the app cross-references ingredients against a cycle-phase compatibility database.

## Architecture

```
┌─────────────┐    HTTPS/JSON    ┌──────────────┐    Bedrock API    ┌────────────────┐
│  iOS App    │ ───────────────→ │ API Gateway  │ ──────────────→  │ Amazon Nova    │
│ (SwiftUI)   │ ←─────────────── │ + Lambda     │ ←──────────────  │ Lite v1        │
└─────────────┘    ingredients   └──────────────┘    analysis      └────────────────┘
       │
       ▼
┌─────────────────────┐
│ Local Ingredient DB  │
│ (CyclePhase compat) │
└─────────────────────┘
```

## How It Works

1. **User captures photo** of skincare product (camera or photo library)
2. **Image sent to API Gateway** → Lambda function → Amazon Bedrock
3. **Nova Lite analyzes** the product photo and extracts ingredients
4. **App cross-references** each ingredient against the cycle phase database
5. **Traffic light display**: 🟢 Great / 🟡 Okay / 🔴 Avoid for current phase

## Amazon Nova Model

- **Model**: `amazon.nova-lite-v1:0` (Nova Lite)
- **Type**: Multimodal (text + image input → text output)
- **Region**: us-east-1
- **Why Nova Lite**: Very low cost, fast inference, good at reading text in images

## Pricing (Free Tier)

- New AWS accounts get **$100 credits** + up to $100 more via onboarding tasks
- Nova Lite pricing: ~$0.00006/input token, ~$0.00024/output token
- **Estimated cost per scan**: ~$0.002-0.005 (image + prompt + response)
- **~20,000-50,000 scans** within free credits
- Credits valid for 6 months

## Files Added

### iOS App
| File | Purpose |
|------|---------|
| `Models/ProductAnalysis.swift` | Data models for scan results + ingredient database |
| `Services/NovaAPIService.swift` | API service (Nova API + local fallback) |
| `Views/ProductScannerView.swift` | Scanner UI with camera, results, traffic lights |
| `Views/CameraView.swift` | AVFoundation camera wrapper |
| `Views/MainTabView.swift` | Updated — added Scanner tab |

### Backend
| File | Purpose |
|------|---------|
| `backend/lambda_function.py` | Lambda function for Bedrock Nova calls |

## Ingredient Database

30+ skincare ingredients mapped across all 4 cycle phases:

| Category | Examples | Logic |
|----------|----------|-------|
| **Actives** | Retinol, Vitamin C, Niacinamide | Avoid harsh actives during menstrual; OK during follicular |
| **Exfoliants** | Salicylic Acid, AHA/BHA | Avoid menstrual; recommend luteal (prevents breakouts) |
| **Moisturizers** | Hyaluronic Acid, Ceramides | Generally safe; avoid heavy oils during ovulatory/luteal |
| **Anti-inflammatory** | Aloe, Centella, Tea Tree | Recommended across phases |
| **Sunscreen** | SPF, Zinc Oxide | Always recommended |
| **Irritants** | Fragrance, Alcohol | Avoid during sensitive phases |

## Demo Mode

When no API endpoint is configured, the app runs in **demo mode**:
- Simulates scanning with 6 realistic product profiles
- Uses the full ingredient database for accurate phase-based recommendations
- Perfect for hackathon demo without AWS deployment

To enable live API:
1. Deploy `backend/lambda_function.py` to AWS Lambda
2. Create API Gateway endpoint
3. Add endpoint URL to `NovaAPIService.apiEndpoint` or `NOVA_API_ENDPOINT` in Info.plist

## Permissions

- **NSCameraUsageDescription**: Camera access for product photo scanning
- **NSPhotoLibraryUsageDescription**: Photo library for selecting product images

## Hackathon Notes

- Built for **CU Boulder Hackathon** (March 16, 2026 deadline)
- Bundle ID: `com.narissarah.cycleglow` (configured as `Onalyst.CycleGlow` in Xcode)
- Follows existing SwiftUI + `@Observable` patterns
- Zero third-party dependencies — pure Swift + AVFoundation
